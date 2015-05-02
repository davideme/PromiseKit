#import <PromiseKit/PromiseKit.h>
#import <UIKit/UINavigationController.h>
#import <UIKit/UIImagePickerController.h>
#import "UIViewController+AnyPromise.h"

@interface PMKGenericDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
@public
    PMKResolver resolve;
}
+ (instancetype)delegateWithPromise:(AnyPromise **)promise;
@end


@implementation UIViewController (PromiseKit)

- (AnyPromise *)promiseViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))block
{
    AnyPromise *promise;

    [self presentViewController:vc animated:animated completion:block];

    if ([vc isKindOfClass:NSClassFromString(@"MFMailComposeViewController")]) {
        PMKGenericDelegate *delegate = [PMKGenericDelegate delegateWithPromise:&promise];
        [vc setValue:delegate forKey:@"mailComposeDelegate"];
    }
    else if ([vc isKindOfClass:NSClassFromString(@"MFMessageComposeViewController")]) {
        PMKGenericDelegate *delegate = [PMKGenericDelegate delegateWithPromise:&promise];
        [vc setValue:delegate forKey:@"messageComposeDelegate"];
    }
    else if ([vc isKindOfClass:NSClassFromString(@"UIImagePickerController")]) {
        PMKGenericDelegate *delegate = [PMKGenericDelegate new];
        ((UIImagePickerController *)vc).delegate = delegate;
    }
    else if ([vc isKindOfClass:NSClassFromString(@"SLComposeViewController")]) {
        PMKResolver resolve;
        promise = [AnyPromise promiseWithResolver:&resolve];
        [vc setValue:^(NSInteger result){
            resolve(@(result));
        } forKey:@"completionHandler"];
    }
    else if ([vc isKindOfClass:[UINavigationController class]])
        vc = [(id)vc viewControllers].firstObject;

    if (!vc) {
        id userInfo = @{NSLocalizedDescriptionKey: @"nil or effective nil passed to promiseViewController"};
        id err = [NSError errorWithDomain:PMKErrorDomain code:PMKInvalidUsageError userInfo:userInfo];
        return [AnyPromise promiseWithValue:err];
    }

    promise.finally(^{
        //TODO can we be more specific?
        [self dismissViewControllerAnimated:animated completion:nil];
    });

    return promise;
}

@end



@implementation PMKGenericDelegate {
    id retainCycle;
}

+ (instancetype)delegateWithPromise:(AnyPromise **)promise; {
    PMKGenericDelegate *d = [PMKGenericDelegate new];
    d->retainCycle = d;
    *promise = [AnyPromise promiseWithResolver:&d->resolve];
    return d;
}

- (void)mailComposeController:(id)controller didFinishWithResult:(int)result error:(NSError *)error {
    resolve(error ?: @(result));
    retainCycle = nil;
}

- (void)messageComposeViewController:(id)controller didFinishWithResult:(int)result {
    if (result == 2) {
        id userInfo = @{NSLocalizedDescriptionKey: @"The user’s attempt to save or send the message was unsuccessful."};
        id error = [NSError errorWithDomain:PMKErrorDomain code:PMKOperationFailed userInfo:userInfo];
        resolve(error);
    } else {
        resolve(@(result));
    }
    retainCycle = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    id img = info[UIImagePickerControllerEditedImage] ?: info[UIImagePickerControllerOriginalImage];
    resolve(PMKManifold(img, info));
    retainCycle = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    resolve(nil);
    retainCycle = nil;
    //TODO cancellation
}

@end
