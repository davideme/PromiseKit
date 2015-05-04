import Foundation.NSError

/**
 AnyPromise is a Promise that can be used in Objective-C code

 Swift code can only convert Promises to AnyPromises or vice versa.

 Libraries that only provide promises will require you to write a
 small Swift function that can convert those promises into AnyPromises
 as you require them.

 To effectively use AnyPromise in Objective-C code you must use `#import`
 rather than `@import PromiseKit;`

     #import <PromiseKit/PromiseKit.h>
*/

/**
 Resolution.Fulfilled takes an Any. When retrieving the Any you cannot
 convert it into an AnyObject?. By giving Fulfilled an object that has
 an AnyObject? property we never have to cast and everything is fine.
*/
private class Box {
    let obj: AnyObject?
    
    init(_ obj: AnyObject?) {
        self.obj = obj
    }
}

private func box(obj: AnyObject?) -> Resolution {
    if let error = obj as? NSError {
        unconsume(error)
        return .Rejected(error)
    } else {
        return .Fulfilled(Box(obj))
    }
}

private func unbox(resolution: Resolution) -> AnyObject? {
    switch resolution {
    case .Fulfilled(let box):
        return (box as! Box).obj
    case .Rejected(let error):
        return error
    }
}



@objc public class AnyPromise: NSObject {
    var state: State

    /**
     @return A new AnyPromise bound to an existing Promise.

     The two promises represent the same task, any changes to either
     will instantly reflect on both.
    */
    public init<T: AnyObject>(bound: Promise<T>) {
        //WARNING copy pasta from below. FIXME how?
        var resolve: ((Resolution) -> Void)!
        state = UnsealedState(resolver: &resolve)
        bound.pipe { resolution in
            switch resolution {
            case .Fulfilled:
                resolve(box(bound.value))
            case .Rejected(let error):
                resolve(box(error))
            }
        }
    }

    public init<T: AnyObject>(bound: Promise<T?>) {
        //WARNING copy pasta from above. FIXME how?
        var resolve: ((Resolution) -> Void)!
        state = UnsealedState(resolver: &resolve)
        bound.pipe { resolution in
            switch resolution {
            case .Fulfilled:
                resolve(box(bound.value!))
            case .Rejected(let error):
                resolve(box(error))
            }
        }
    }

    convenience public init(bound: Promise<Int>) {
        self.init(bound: bound.then(on: zalgo) { NSNumber(integer: $0) })
    }

    convenience public init(bound: Promise<Void>) {
        self.init(bound: bound.then(on: zalgo) { _ -> AnyObject? in return nil })
    }

    @objc init(@noescape bridge: ((AnyObject?) -> Void) -> Void) {
        var resolve: ((Resolution) -> Void)!
        state = UnsealedState(resolver: &resolve)
        bridge { result in
            func preresolve(obj: AnyObject?) {
                resolve(box(obj))
            }
            if let next = result as? AnyPromise {
                next.pipe(preresolve)
            } else {
                preresolve(result)
            }
        }
    }

    @objc func pipe(body: (AnyObject?) -> Void) {
        state.get { seal in
            func prebody(resolution: Resolution) {
                body(unbox(resolution))
            }
            switch seal {
            case .Pending(let handlers):
                handlers.append(prebody)
            case .Resolved(let resolution):
                prebody(resolution)
            }
        }
    }

    @objc var __value: AnyObject? {
        let resolution = state.get()
        switch resolution {
        case .Some(.Fulfilled):
            return unbox(resolution!)
        default:
            return nil
        }
    }

    @objc var ____value: AnyObject? {
        if let resolution = state.get() {
            return unbox(resolution)
        } else {
            return nil
        }
    }

    @objc var pending: Bool {
        return state.get() == nil
    }

    @objc class func __wrap(body: () -> AnyObject?) -> AnyObject? {
        return body()
    }
}



extension AnyPromise {
    // because you can’t access top-level Swift functions in objc
    @objc public class func setUnhandledErrorHandler(body: (NSError) -> Void) {
        PMKUnhandledErrorHandler = body
    }
}



extension AnyPromise: DebugPrintable {
    override public var debugDescription: String {
        return "AnyPromise: \(state)"
    }
}



@objc public class PMKPromise: AnyPromise
{}
