import PromiseKit
import MessageUI.MFMailComposeViewController
import UIKit.UIViewController

class MFMailComposeViewControllerProxy: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {

    let (promise, fulfill, reject) = Promise<MFMailComposeResult>.defer()

    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if error != nil {
            reject(error)
        } else if result.value == MFMailComposeResultCancelled.value {
            var info = [NSObject: AnyObject]()
            info[NSLocalizedDescriptionKey] = "The operation was canceled"
            reject(NSError(domain: MFMailComposeErrorDomain, code: PMKOperationCancelled, userInfo: info))
        } else {
            fulfill(result)
        }
    }
}

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
