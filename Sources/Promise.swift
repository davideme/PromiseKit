import Foundation.NSError

public let PMKOperationQueue = NSOperationQueue()

public enum CatchPolicy {
    case AllErrors
    case AllErrorsExceptCancellation
}


public class Promise<T> {
    let state: State

    public convenience init(@noescape resolvers: (fulfill: (T) -> Void, reject: (NSError) -> Void) -> Void) {
        self.init(sealant: { sealant in
            resolvers(fulfill: sealant.resolve, reject: sealant.resolve)
        })
    }

    public init(@noescape sealant: (Sealant<T>) -> Void) {
        var resolve: ((Resolution) -> Void)!
        state = UnsealedState(resolver: &resolve)
        sealant(Sealant(body: resolve))
    }

    public init(_ value: T) {
        state = SealedState(resolution: .Fulfilled(value))
    }

    public init(_ error: NSError) {
        unconsume(error)
        state = SealedState(resolution: .Rejected(error))
    }

    /**
      I’d prefer this to be the designated initializer, but then there would be no
      public designated unsealed initializer! Making this convenience would be
      inefficient. Not very inefficient, but still it seems distasteful to me.
     */
    init(passthru: ((Resolution) -> Void) -> Void) {
        var resolve: ((Resolution) -> Void)!
        state = UnsealedState(resolver: &resolve)
        passthru(resolve)
    }

    public class func defer() -> (promise: Promise, fulfill: (T) -> Void, reject: (NSError) -> Void) {
        var sealant: Sealant<T>!
        let promise = Promise { sealant = $0 }
        return (promise, sealant.resolve, sealant.resolve)
    }

    func pipe(body: (Resolution) -> Void) {
        state.get { seal in
            switch seal {
            case .Pending(let handlers):
                handlers.append(body)
            case .Resolved(let resolution):
                body(resolution)
            }
        }
    }

    private convenience init<U>(when: Promise<U>, body: (Resolution, (Resolution) -> Void) -> Void) {
        self.init(passthru: { resolve in
            when.pipe{ body($0, resolve) }
        })
    }
    
    public func then<U>(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: (T) -> U) -> Promise<U> {
        return Promise<U>(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected:
                resolve(resolution)
            case .Fulfilled(let value):
                contain_zalgo(q) {
                    resolve(.Fulfilled(body(value as! T)))
                }
            }
        }
    }

    public func then<U>(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: (T) -> Promise<U>) -> Promise<U> {
        return Promise<U>(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected:
                resolve(resolution)
            case .Fulfilled(let value):
                contain_zalgo(q) {
                    body(value as! T).pipe(resolve)
                }
            }
        }
    }

    public func then(on q: dispatch_queue_t = dispatch_get_main_queue(), body: (T) -> AnyPromise) -> Promise<AnyObject?> {
        return Promise<AnyObject?>(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected:
                resolve(resolution)
            case .Fulfilled(let value):
                contain_zalgo(q) {
                    body(value as! T).pipe { obj in
                        if let error = obj as? NSError {
                            resolve(.Rejected(error))
                        } else {
                            resolve(.Fulfilled(obj))
                        }
                    }
                }
            }
        }
    }

    public func thenInBackground<U>(body: (T) -> U) -> Promise<U> {
        return then(on: dispatch_get_global_queue(0, 0), body)
    }

    public func thenInBackground<U>(body: (T) -> Promise<U>) -> Promise<U> {
        return then(on: dispatch_get_global_queue(0, 0), body)
    }

    public func catch(policy: CatchPolicy = .AllErrorsExceptCancellation, _ body: (NSError) -> Void) {
        pipe { resolution in
            switch resolution {
            case .Fulfilled:
                break
            case .Rejected(let error):
                if policy == .AllErrors || !error.cancelled {
                    dispatch_async(dispatch_get_main_queue()) {
                        consume(error)
                        body(error)
                    }
                }
            }
        }
    }

    public func recover(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: (NSError) -> Promise<T>) -> Promise<T> {
        return Promise(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected(let error):
                contain_zalgo(q) {
                    consume(error)
                    body(error).pipe(resolve)
                }
            case .Fulfilled:
                resolve(resolution)
            }
        }
    }

    public func finally(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: () -> Void) -> Promise<T> {
        return Promise(when: self) { resolution, resolve in
            contain_zalgo(q) {
                body()
                resolve(resolution)
            }
        }
    }
    
    //TODO move to +Properties. Currently here due to Swift link error otherwise.
    public var value: T? {
        switch state.get() {
        case .None:
            return nil
        case .Some(.Fulfilled(let value)):
            return (value as! T)
        case .Some(.Rejected):
            return nil
        }
    }
}


/**
 Zalgo is dangerous.

 Pass as the `on` parameter for a `then`. Causes the handler to be executed
 as soon as it is resolved. That means it will be executed on the queue it
 is resolved. This means you cannot predict the queue.

 In the case that the promise is already resolved the handler will be
 executed immediately.

 zalgo is provided for libraries providing promises that have good tests
 that prove unleashing zalgo is safe. You can also use it in your
 application code in situations where performance is critical, but be
 careful: read the essay at the provided link to understand the risks.

 @see http://blog.izs.me/post/59142742143/designing-apis-for-asynchrony
*/
public let zalgo: dispatch_queue_t = dispatch_queue_create("Zalgo", nil)

/**
 Waldo is dangerous.

 Waldo is zalgo, unless the current queue is the main thread, in which case
 we dispatch to the default background queue.

 If your block is likely to take more than a few milliseconds to execute,
 then you should use waldo: 60fps means the main thread cannot hang longer
 than 17 milliseconds. Don’t contribute to UI lag.

 Conversely if your then block is trivial, use zalgo: GCD is not free and
 for whatever reason you may already be on the main thread so just do what
 you are doing quickly and pass on execution.

 It is considered good practice for asynchronous APIs to complete onto the
 main thread. Apple do not always honor this, nor do other developers.
 However, they *should*. In that respect waldo is a good choice if your
 then is going to take a while and doesn’t interact with the UI.

 Please note (again) that generally you should not use zalgo or waldo. The
 performance gains are neglible and we provide these functions only out of
 a misguided sense that library code should be as optimized as possible.
 If you use zalgo or waldo without tests proving their correctness you may
 unwillingly introduce horrendous, near-impossible-to-trace bugs.

 @see zalgo
*/
public let waldo: dispatch_queue_t = dispatch_queue_create("Waldo", nil)

func contain_zalgo(q: dispatch_queue_t, block: () -> Void) {
    if q === zalgo {
        block()
    } else if q === waldo {
        if NSThread.isMainThread() {
            dispatch_async(dispatch_get_global_queue(0, 0), block)
        } else {
            block()
        }
    } else {
        dispatch_async(q, block)
    }
}


extension Promise {
    public convenience init(error: String, code: Int = PMKUnexpectedError) {
        let error = NSError(domain: "PMKErrorDomain", code: code, userInfo: [NSLocalizedDescriptionKey: error])
        self.init(error)
    }
    
    /**
     Promise<Any> is more flexible, and often needed. However Swift won't cast
     <T> to <Any> directly. Once that is possible we will deprecate this
     function.
    */
    public func asAny() -> Promise<Any> {
        return Promise<Any>(passthru: pipe)
    }

    /**
     Promise<AnyObject> is more flexible, and often needed. However Swift won't
     cast <T> to <AnyObject> directly. Once that is possible we will deprecate
     this function.
    */
    public func asAnyObject() -> Promise<AnyObject> {
        return Promise<AnyObject>(passthru: pipe)
    }

    /**
     Swift seems to be much less fussy about Void promises.
    */
    public func asVoid() -> Promise<Void> {
        return then(on: zalgo) { _ in return }
    }
}


extension Promise: DebugPrintable {
    public var debugDescription: String {
        return "Promise: \(state)"
    }
}


public func firstly<T>(promise: () -> Promise<T>) -> Promise<T> {
    return promise()
}