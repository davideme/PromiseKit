import MessageUI
import PromiseKit
import UIKit
import XCTest
import KIFFramework

class TestPromisableViewController: UIKitTestCase {

    private class MyViewController: UIViewController, Promisable {
        @objc var promise: AnyObject! = nil

        var appeared = false

        private override func viewDidAppear(animated: Bool) {
            appeared = true
        }
    }

    // fails if promised ViewController has no promise property
    func test1a() {
        let ex = expectationWithDescription("")
        let p: Promise<Int> = rootvc.promiseViewController(UIViewController(), animated: false)
        p.catch { err in
            XCTAssertEqual(err.domain, PMKErrorDomain)
            XCTAssertEqual(err.code, PMKInvalidUsageError)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // fails if promised ViewController has nil promise property
    func test1b() {
        let ex = expectationWithDescription("")
        let p: Promise<Int> = rootvc.promiseViewController(MyViewController(), animated: false)
        p.catch { err in
            XCTAssertEqual(err.domain, PMKErrorDomain)
            XCTAssertEqual(err.code, PMKInvalidUsageError)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // fails if promised ViewController has promise property of wrong specialization
    func test1c() {
        let ex = expectationWithDescription("")
        let my = MyViewController()
        my.promise = Promise(true)
        let p: Promise<Int> = rootvc.promiseViewController(my, animated: false)
        p.catch { err in
            XCTAssertEqual(err.domain, PMKErrorDomain)
            XCTAssertEqual(err.code, PMKInvalidUsageError)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // A ViewController with a resolved promise does not appear
    func test2a() {
        let ex = expectationWithDescription("")
        let my = MyViewController()
        my.promise = Promise(dummy)
        rootvc.promiseViewController(my, animated: false).then { (x: Int) -> Void in
            XCTAssertFalse(my.appeared)
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // A ViewController with an unresolved promise appears and disappears once resolved
    func test2b() {
        let ex = expectationWithDescription("")
        let my = MyViewController()
        let (promise, resolve, _) = Promise<Int>.defer()
        my.promise = promise
        rootvc.promiseViewController(my, animated: false).then { (x: Int) -> Void in
            XCTAssertTrue(my.appeared)
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }
        after(0).then {
            resolve(dummy)
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // promised nav controllers use their root vc’s promise property
    func test3() {
        let ex = expectationWithDescription("")
        let nc = UINavigationController()
        let my = MyViewController()
        my.promise = after(0.1).then{ dummy }
        nc.viewControllers = [my]
        rootvc.promiseViewController(nc, animated: false).then { (x: Int) -> Void in
            XCTAssertTrue(my.appeared)
            XCTAssertEqual(x, dummy)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}

class TestPromiseImagePickerController: UIKitTestCase {
    // UIImagePickerController fulfills with edited image
    func test1() {
        class Mock: UIViewController {
            var info = [NSObject:AnyObject]()

            override func presentViewController(vc: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                let ipc = vc as! UIImagePickerController
                after(0.05).finally {
                    ipc.delegate?.imagePickerController?(ipc, didFinishPickingMediaWithInfo: self.info)
                }
            }
        }

        let (originalImage, editedImage) = (UIImage(), UIImage())

        let mockvc = Mock()
        mockvc.info = [UIImagePickerControllerOriginalImage: originalImage, UIImagePickerControllerEditedImage: editedImage]

        let ex = expectationWithDescription("")
        mockvc.promiseViewController(UIImagePickerController(), animated: false).then { (x: UIImage) -> Void in
            XCTAssert(x == editedImage)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // UIImagePickerController fulfills with original image if no edited image available
    func test2() {
        class Mock: UIViewController {
            var info = [NSObject:AnyObject]()

            override func presentViewController(vc: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
                let ipc = vc as! UIImagePickerController
                after(0.05).finally {
                    ipc.delegate?.imagePickerController?(ipc, didFinishPickingMediaWithInfo: self.info)
                }
            }
        }

        let (originalImage, editedImage) = (UIImage(), UIImage())

        let mockvc = Mock()
        mockvc.info = [UIImagePickerControllerOriginalImage: originalImage]

        let ex = expectationWithDescription("")
        mockvc.promiseViewController(UIImagePickerController(), animated: false).then { (x: UIImage) -> Void in
            XCTAssert(x == originalImage)
            XCTAssert(x != editedImage)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    // cancelling picker cancels promise
    func test3() {
        let ex = expectationWithDescription("")
        let picker = UIImagePickerController()
        let promise: Promise<UIImage> = rootvc.promiseViewController(picker, animated: false, completion: {
            after(0.05).then { _ -> Void in
                let button = picker.viewControllers[0].navigationItem.rightBarButtonItem!
                UIControl().sendAction(button.action, to: button.target, forEvent: nil)
            }
        })
        promise.catch { _ -> Void in
            XCTFail()
        }
        promise.catch(policy: CatchPolicy.AllErrors) { _ -> Void in
            after(0.5).then(ex.fulfill)
        }
        waitForExpectationsWithTimeout(10, handler: nil)

        XCTAssertNil(rootvc.presentedViewController)
    }

    // can select image from picker
    func test4() {
        let ex = expectationWithDescription("")
        let picker = UIImagePickerController()
        let promise: Promise<UIImage> = rootvc.promiseViewController(picker, animated: false, completion: {
            after(0.05).then { _ -> Promise<Void> in
                let tv: UITableView = find(picker, UITableView.self)
                tv.visibleCells()[1].tap()
                return after(1.5)
            }.then { _ -> Void in
                let vcs = picker.viewControllers
                let cv: UICollectionView = find(picker.viewControllers[1] as! UIViewController, UICollectionView.self)
                let cell = cv.visibleCells()[0] as! UICollectionViewCell
                cell.tap()
            }
        })
        promise.then { img -> Void in
            XCTAssertTrue(img.size.width > 0)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)

        XCTAssertNil(rootvc.presentedViewController)
    }

    // can select data from picker
    func test5() {
        let ex = expectationWithDescription("")
        let picker = UIImagePickerController()
        let promise: Promise<NSData> = rootvc.promiseViewController(picker, animated: false, completion: {
            after(0.05).then { _ -> Promise<Void> in
                let tv: UITableView = find(picker, UITableView.self)
                tv.visibleCells()[1].tap()
                return after(1.5)
            }.then { _ -> Void in
                let vcs = picker.viewControllers
                let cv: UICollectionView = find(picker.viewControllers[1] as! UIViewController, UICollectionView.self)
                let cell = cv.visibleCells()[0] as! UICollectionViewCell
                cell.tap()
            }
        })
        promise.then { data -> Void in
            XCTAssertTrue(data.length > 0)
            XCTAssertNotNil(UIImage(data: data))
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)

        XCTAssertNil(rootvc.presentedViewController)
    }
}

class TestPromiseMailComposer: UIKitTestCase {
    // cancelling mail composer cancels promise
    func test7() {
        let ex = expectationWithDescription("")
        let mailer = MFMailComposeViewController()
        let promise = rootvc.promiseViewController(mailer, animated: false, completion: {
            after(0.05).then { _ -> Void in
                let button = mailer.viewControllers[0].navigationItem.leftBarButtonItem!

                let control: UIControl = UIControl()
                control.sendAction(button.action, to: button.target, forEvent: nil)
            }
        })
        promise.catch { _ -> Void in
            XCTFail()
        }
        promise.catch(policy: CatchPolicy.AllErrors) { _ -> Void in
            // seems necessary to give vc stack a bit of time
            after(0.5).then(ex.fulfill)
        }
        waitForExpectationsWithTimeout(10, handler: nil)

        XCTAssertNil(rootvc.presentedViewController)
    }
}



/////////////////////////////////////////////////////////////// resources

private let dummy = 1_234_765


class UIKitTestCase: XCTestCase {
    var rootvc: UIViewController {
        return UIApplication.sharedApplication().keyWindow!.rootViewController!
    }

    override func setUp() {
        UIApplication.sharedApplication().keyWindow!.rootViewController = UIViewController()
    }

    override func tearDown() {
        UIApplication.sharedApplication().keyWindow!.rootViewController = nil
    }
}

private func subviewsOf(v: UIView) -> [UIView] {
    var vv = v.subviews as! [UIView]
    for v in v.subviews as! [UIView] {
        vv += subviewsOf(v)
    }
    return vv
}

private func find<T>(vc: UIViewController, type: AnyClass) -> T! {
    return find(vc.view, type)
}

private func find<T>(view: UIView, type: AnyClass) -> T! {
    for x in subviewsOf(view) {
        if x is T {
            return x as! T
        }
    }
    return nil
}


extension XCTestCase {
    func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }

    func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
}
