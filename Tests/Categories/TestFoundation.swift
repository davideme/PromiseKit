import Foundation
import OHHTTPStubs
import PromiseKit
import XCTest

private let PMKTestNotification = "PMKTestNotification"


class TestNSNotificationCenter: XCTestCase {
    func test() {
        let ex = expectationWithDescription("")
        let userInfo: [NSObject: AnyObject] = ["a": 1]

        NSNotificationCenter.once(PMKTestNotification).then { (d: [NSObject: AnyObject]) -> Void in
            //XCTAssertEqual(d, userInfo) FIXME swift won't compile this!
            ex.fulfill()
        }

        NSNotificationCenter.defaultCenter().postNotificationName(PMKTestNotification, object: nil, userInfo: userInfo)

        waitForExpectationsWithTimeout(1, handler: nil)
    }
}


#if os(OSX)
class TestNSTask: XCTestCase {
    func test1() {
        let ex = expectationWithDescription("")
        let task = NSTask()
        task.launchPath = "/usr/bin/basename"
        task.arguments = ["/foo/doe/bar"]
        task.promise().then { (stdout: String) -> Void in
            XCTAssertEqual(stdout, "bar\n")
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }

    func test2() {
        let ex = expectationWithDescription("")
        let dir = "PMKAbsentDirectory"

        let task = NSTask()
        task.launchPath = "/bin/ls"
        task.arguments = [dir]

        task.promise().then { (stdout: String, stderr: String, exitStatus: Int) -> Void in
            XCTFail()
            }.catch { err in
                let userInfo = err.userInfo!
                let expectedStderrData = "ls: \(dir): No such file or directory\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

                XCTAssertEqual(userInfo[PMKTaskErrorLaunchPathKey] as! String, task.launchPath)
                XCTAssertEqual(userInfo[PMKTaskErrorArgumentsKey] as! [String], task.arguments as! [String])
                XCTAssertEqual(userInfo[PMKTaskErrorStandardErrorKey] as! NSData, expectedStderrData)
                XCTAssertEqual(userInfo[PMKTaskErrorExitStatusKey] as! Int, 1)
                XCTAssertEqual((userInfo[PMKTaskErrorStandardOutputKey] as! NSData).length, 0)
                ex.fulfill()
        }
        waitForExpectationsWithTimeout(10, handler: nil)
    }
}
#endif

class TestNSURLConnection: XCTestCase {
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
    }

    func test1() {
        let json = ["key1": "value1", "key2": ["value2A", "value2B"]]

        OHHTTPStubs.stubRequestsPassingTest({ $0.URL!.host == "example.com" }) { _ in
            return OHHTTPStubsResponse(JSONObject: json, statusCode: 200, headers: nil)
        }

        let ex = expectationWithDescription("")
        NSURLConnection.GET("http://example.com").then { (rsp: NSDictionary) -> Void in
            XCTAssertEqual(json, rsp)
            ex.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
