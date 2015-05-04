@import MessageUI;
@import UIKit;
#import "UIViewController+AnyPromise.h"
@import XCTest;


@interface TestUIViewControllerM: XCTestCase @end @implementation TestUIViewControllerM

- (void)test {
    id ex = [self expectationWithDescription:@""];

    [MFMailComposeViewController new];


    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
