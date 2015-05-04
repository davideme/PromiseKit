import PromiseKit
import MessageUI.MFMailComposeViewController
import UIKit.UIViewController

/**
 To import this `UIViewController` category:

    pod "PromiseKit/MessagesUI"

 And then in your sources:

    import PromiseKit
*/
extension UIViewController {
    public func promiseViewController(vc: MFMailComposeViewController, animated: Bool = true, completion:(() -> Void)? = nil) -> Promise<MFMailComposeResult> {
        let proxy = MFMailComposeViewControllerProxy()
        vc.mailComposeDelegate = proxy
        presentViewController(vc, animated: animated, completion: completion)
        proxy.promise.finally {
            proxy.description
            vc.dismissViewControllerAnimated(animated, completion: nil)
        }
        return proxy.promise
    }
}

public let MFOperationCancelled = 1000

private class MFMailComposeViewControllerProxy: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    let (promise, fulfill, reject) = Promise<MFMailComposeResult>.defer()

    @objc func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if error != nil {
            reject(error)
        } else if result.value == MFMailComposeResultCancelled.value {
            var info = [NSObject: AnyObject]()
            info[NSLocalizedDescriptionKey] = "The operation was canceled"
            reject(NSError(domain: MFMailComposeErrorDomain, code: MFOperationCancelled, userInfo: info))
        } else {
            fulfill(result)
        }
    }
}
