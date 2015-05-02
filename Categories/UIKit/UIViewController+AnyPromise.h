#import <PromiseKit/AnyPromise.h>
#import <UIKit/UIViewController.h>

/**
 To import the `UIViewController` category:

    pod "PromiseKit/UIViewController"

 Or you can import all categories on `UIKit`:

    pod "PromiseKit/UIKit"

 Or `UIKit` is one of the categories imported by the umbrella pod:

    pod "PromiseKit"
*/
@interface UIViewController (PromiseKit)

/**
 Presents a view controller modally.

 If the view controller is one of the following:

  - MFMailComposeViewController
  - MFMessageComposeViewController
  - UIImagePickerController
  - SLComposeViewController

 Then PromiseKit presents the view controller returning a promise that is
 resolved as per the documentation for those classes. Eg. if you present a
 `UIImagePickerController` the view controller will be presented for you
 and the returned promise will resolve with the media the user selected.

 Otherwise PromiseKit expects your view controller to implement a
 `promise` property. This promise will be returned from this method and
 presentation and dismissal of the presented view controller will be
 managed for you.

 @return A promise that can be resolved by the presented view controller.
*/
- (AnyPromise *)promiseViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))block;

@end
