import Foundation.NSError

extension Promise {
    public var error: NSError? {
        switch state.get() {
        case .None:
            return nil
        case .Some(.Fulfilled):
            return nil
        case .Some(.Rejected(let error)):
            return error
        }
    }
    
    public var pending: Bool {
        return state.get() == nil
    }
    
    public var resolved: Bool {
        return !pending
    }
    
    public var fulfilled: Bool {
        return value != nil
    }
    
    public var rejected: Bool {
        return error != nil
    }
}
