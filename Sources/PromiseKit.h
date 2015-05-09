#import <dispatch/queue.h>
#import <Foundation/NSObject.h>
#import <PromiseKit/AnyPromise.h>
#import <PromiseKit/Swift.h>
#import <PromiseKit/Umbrella.h>


/**
 @return A new promise that resolves after the specified duration.

 @parameter duration The duration in seconds to wait before this promise is resolve.

 For example:

    PMKAfter(1).then(^{
        //…
    });
*/
extern AnyPromise *PMKAfter(NSTimeInterval duration);


/**
 `when` is a mechanism for waiting more than one asynchronous task and responding when they are all complete.

 `PMKWhen` accepts varied input. If an array is passed then when those promises fulfill, when’s promise fulfills with an array of fulfillment values. If a dictionary is passed then the same occurs, but when’s promise fulfills with a dictionary of fulfillments keyed as per the input.

 Interestingly, if a single promise is passed then when waits on that single promise, and if a single non-promise object is passed then when fulfills immediately with that object. If the array or dictionary that is passed contains objects that are not promises, then these objects are considered fulfilled promises. The reason we do this is to allow a pattern know as "abstracting away asynchronicity".

 If *any* of the provided promises reject, the returned promise is immediately rejected with that promise’s rejection error. The error’s `userInfo` object is supplemented with `PMKFailingPromiseIndexKey`.

 For example:

    PMKWhen(@[promise1, promise2]).then(^(NSArray *results){
        //…
    });

 @param input The input upon which to wait before resolving this promise.

 @return A promise that is resolved with either:

  1. An array of values from the provided array of promises.
  2. The value from the provided promise.
  3. The provided non-promise object.
*/
extern AnyPromise *PMKWhen(id input);


/**
 Creates a new promise that resolves only when all provided promises have resolved.

 Typically, you should use `PMKWhen`.

 This promise is not rejectable.

 For example:

    PMKJoin(@[promise1, promise2]).then(^(NSArray *results, NSArray *values, NSArray *errors){
        //…
    });

 @param promises An array of promises.

 @return A promise that thens three parameters:

  1) An array of mixed values and errors from the resolved input.
  2) An array of values from the promises that fulfilled.
  3) An array of errors from the promises that rejected or nil if all promises fulfilled.

 @see when
*/
AnyPromise *PMKJoin(NSArray *promises);


/**
 Literally hangs this thread until the promise has resolved.
 
 Do not use hang… unless you are testing, playing or debugging.
 
 If you use it in production code I will literally and honestly cry like a child.
 
 @return The resolved value of the promise.

 @warning T SAFE. IT IS NOT SAFE. IT IS NOT SAFE. IT IS NOT SAFE. IT IS NO
*/
extern id PMKHang(AnyPromise *promise);


typedef void (^PMKUnhandledErrorHandler)(NSError *);
/**
 Sets the unhandled error handler.

 If a promise is rejected and no catch handler is called in its chain,
 this handler is called. The default handler logs the error.

 @warning *Important* The provided handler is executed on an undefined
 queue.
 
 @return The previous unhandled error handler.
*/
extern PMKUnhandledErrorHandler PMKSetUnhandledErrorHandler(PMKUnhandledErrorHandler handler);


/**
 Executes the provided block on a background queue.

 dispatch_promise is a convenient way to start a promise chain where the
 first step needs to run synchronously on a background queue.

    dispatch_promise(^{
        return md5(input);
    }).then(^(NSString *md5){
        NSLog(@"md5: %@", md5);
    });

 @param block The block to be executed in the background. Returning an `NSError` will reject the promise, everything else (including void) fulfills the promise.

 @return A promise resolved with the return value of the provided block.

 @see dispatch_async
*/
extern AnyPromise *dispatch_promise(id block);


/**
 Executes the provided block on the specified background queue.

    dispatch_promise_on(myDispatchQueue, ^{
        return md5(input);
    }).then(^(NSString *md5){
        NSLog(@"md5: %@", md5);
    });

 @param block The block to be executed in the background. Returning an `NSError` will reject the promise, everything else (including void) fulfills the promise.

 @return A promise resolved with the return value of the provided block.

 @see dispatch_promise
*/
extern AnyPromise *dispatch_promise_on(dispatch_queue_t queue, id block);



#define PMKJSONDeserializationOptions ((NSJSONReadingOptions)(NSJSONReadingAllowFragments | NSJSONReadingMutableContainers))

#define PMKHTTPURLResponseIsJSON(rsp) [@[@"application/json", @"text/json", @"text/javascript"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsImage(rsp) [@[@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsText(rsp) [[rsp MIMEType] hasPrefix:@"text/"]



#if defined(__has_include)
  #if __has_include(<PromiseKit/ACAccountStore+AnyPromise.h>)
    #import <PromiseKit/ACAccountStore+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/AVAudioSession+AnyPromise.h>)
    #import <PromiseKit/AVAudioSession+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CKContainer+AnyPromise.h>)
    #import <PromiseKit/CKContainer+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CKDatabase+AnyPromise.h>)
    #import <PromiseKit/CKDatabase+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CLGeocoder+AnyPromise.h>)
    #import <PromiseKit/CLGeocoder+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CLLocationManager+AnyPromise.h>)
    #import <PromiseKit/CLLocationManager+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/NSNotificationCenter+AnyPromise.h>)
    #import <PromiseKit/NSNotificationCenter+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/NSTask+AnyPromise.h>)
    #import <PromiseKit/NSTask+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/NSURLConnection+AnyPromise.h>)
    #import <PromiseKit/NSURLConnection+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/MKDirections+AnyPromise.h>)
    #import <PromiseKit/MKDirections+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/MKMapSnapshotter+AnyPromise.h>)
    #import <PromiseKit/MKMapSnapshotter+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CALayer+AnyPromise.h>)
    #import <PromiseKit/CALayer+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/SLRequest+AnyPromise.h>)
    #import <PromiseKit/SLRequest+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/SKRequest+AnyPromise.h>)
    #import <PromiseKit/SKRequest+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/SCNetworkReachability+AnyPromise.h>)
    #import <PromiseKit/SCNetworkReachability+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIActionSheet+AnyPromise.h>)
    #import <PromiseKit/UIActionSheet+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIAlertView+AnyPromise.h>)
    #import <PromiseKit/UIAlertView+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIView+AnyPromise.h>)
    #import <PromiseKit/UIView+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIViewController+AnyPromise.h>)
    #import <PromiseKit/UIViewController+AnyPromise.h>
  #endif
#endif
