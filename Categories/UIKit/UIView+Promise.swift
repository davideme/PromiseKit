import PromiseKit
import UIKit.UIView

extension UIView {
    public class func animate(duration: NSTimeInterval = 0.3, delay: NSTimeInterval = 0, options: UIViewAnimationOptions = UIViewAnimationOptions(), animations: () -> Void) -> Promise<Bool> {
        return Promise { sealant in
            self.animateWithDuration(duration, delay: delay, options: options, animations: animations, completion: sealant.resolve)
        }
    }
}
