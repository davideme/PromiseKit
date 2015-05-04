import Foundation
import PromiseKit

private class KVOProxy: NSObject {
    var retainCycle: KVOProxy?
    let fulfill: (AnyObject?) -> Void

    init(observee: NSObject, keyPath: String, resolve: (AnyObject?) -> Void) {
        fulfill = resolve
        super.init()
        retainCycle = self
        observee.addObserver(self, forKeyPath: keyPath, options: NSKeyValueObservingOptions.New, context: nil)
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        fulfill(change[NSKeyValueChangeNewKey])
        object.removeObserver(self, forKeyPath: keyPath)
        retainCycle = nil
    }
}

extension NSObject {
    public func observe<T>(keyPath: String) -> Promise<T> {
        let (promise, fulfill, reject) = Promise<T>.defer()
        KVOProxy(observee: self, keyPath: keyPath) { obj in
            if let obj = obj as? T {
                fulfill(obj)
            } else {
                let info = [NSLocalizedDescriptionKey: "The observed property was not of the requested type."]
                reject(NSError(domain: PMKErrorDomain, code: PMKInvalidUsageError, userInfo: info))
            }
        }
        return promise
    }
}
