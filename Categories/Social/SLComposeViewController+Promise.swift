import PromiseKit
import Social.SLComposeViewController

extension UIViewController {
    public func promiseViewController(vc: SLComposeViewController, animated: Bool = true, completion: (() -> Void)? = nil) -> Promise<SLComposeViewControllerResult> {
        presentViewController(vc, animated: animated, completion: completion)
        return Promise { vc.completionHandler = $0.resolve }
    }

}
