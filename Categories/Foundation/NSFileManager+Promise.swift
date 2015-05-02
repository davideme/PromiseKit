import Foundation.NSFileManager
import PromiseKit


private func dispatch_promise<T>(on: dispatch_queue_t = dispatch_get_global_queue(0, 0), body: () -> (T!, NSError!)) -> Promise<T> {
    return Promise{ (sealant: Sealant) -> Void in
        dispatch_async(on) { _ -> Void in
            let (a, b) = body()
            sealant.resolve(a, b)
        }
    }
}


extension NSFileManager {
    func removeItemAtPath(path: String) -> Promise<String> {
        return dispatch_promise() {
            var error: NSError?
            self.removeItemAtPath(path, error:&error)
            return (path, error)
        }
    }

    func copyItem(# from: String, to: String) -> Promise<String> {
        return dispatch_promise() {
            var error: NSError?
            self.copyItemAtPath(from, toPath:to, error:&error)
            return (to, error)
        }
    }

    func moveItem(# from: String, to: String) -> Promise<String> {
        return dispatch_promise() {
            var error: NSError?
            self.moveItemAtPath(from, toPath: to, error: &error)
            return (to, error)
        }
    }

    func createDirectoryAtPath(path: String, withIntermediateDirectories with: Bool = true, attributes: [NSObject : AnyObject]? = nil) -> Promise<String> {
        return dispatch_promise() {
            var error: NSError?
            self.createDirectoryAtPath(path, withIntermediateDirectories: with, attributes: attributes, error: &error)
            return (path, error)
        }
    }
}
