import Foundation
import PromiseKit
import UIKit.UIAlertView


class UIAlertViewProxy: NSObject, UIAlertViewDelegate {
    let (promise, fulfill, reject) = Promise<Int>.defer()

    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            fulfill(buttonIndex)
        } else {
            reject(NSError.cancelledError())
        }
    }
}


extension UIAlertView {
    public func promise() -> Promise<Int> {
        let proxy = UIAlertViewProxy()
        delegate = proxy
        show()
        proxy.promise.finally {
            proxy.description
        }
        return proxy.promise
    }
}
