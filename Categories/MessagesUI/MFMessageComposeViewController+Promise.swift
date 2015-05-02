import PromiseKit
import MessageUI.MFMessageComposeViewController
import UIKit.UIViewController

class MFMessageComposeViewControllerProxy: NSObject, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {

    let (promise, fulfill, reject) = Promise<Void>.defer()

    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {

        switch result.value {
        case MessageComposeResultSent.value:
            fulfill()
        case MessageComposeResultFailed.value:
            var info = [NSObject: AnyObject]()
            info[NSLocalizedDescriptionKey] = "The attempt to save or send the message was unsuccessful."
            reject(NSError(domain: PMKErrorDomain, code: PMKOperationFailed, userInfo: info))
        case MessageComposeResultCancelled.value:
            reject(NSError.cancelledError())
        default:
            fatalError("Swift Sucks")
        }
    }
}

extension UIViewController {
    public func promiseViewController(vc: MFMessageComposeViewController, animated: Bool = true, completion:(() -> Void)? = nil) -> Promise<Void> {
        let proxy = MFMessageComposeViewControllerProxy()
        vc.messageComposeDelegate = proxy
        presentViewController(vc, animated: animated, completion: completion)
        proxy.promise.finally {
            proxy.description
            vc.dismissViewControllerAnimated(animated, completion: nil)
        }
        return proxy.promise
    }
}
