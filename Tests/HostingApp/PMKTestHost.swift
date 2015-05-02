import UIKit

@UIApplicationMain
class App: UIViewController, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = self
        window!.backgroundColor = UIColor.grayColor()
        window!.makeKeyAndVisible()
        return true
    }
}
