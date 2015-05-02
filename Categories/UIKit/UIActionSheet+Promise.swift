import PromiseKit
import UIKit.UIActionSheet


class UIActionSheetProxy: NSObject, UIActionSheetDelegate {
    let (promise, fulfill, reject) = Promise<Int>.defer()
    var retainCycle: NSObject?

    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            fulfill(buttonIndex)
        } else {
            reject(NSError.cancelledError())
        }
        retainCycle = nil
    }
}


extension UIActionSheet {
    public func promiseInView(view: UIView) -> Promise<Int> {
        let proxy = UIActionSheetProxy()
        delegate = proxy
        proxy.retainCycle = proxy
        showInView(view)
        return proxy.promise
    }
}
