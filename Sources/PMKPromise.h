/**
 This is a compatability header for PMKPromise.h provided
 because #import <PromiseKit/Promise.h> would import PMKPromise
 in PromiseKit 1.x
 
 It will be marked deprecated at PromiseKit 2.1 and removed by 2.3.
*/

#import <PromiseKit/AnyPromise.h>


#define PMKPromise AnyPromise


typedef void (^PMKFulfiller)(id);
typedef void (^PMKRejecter)(NSError *);

typedef PMKFulfiller PMKPromiseFulfiller;
typedef PMKRejecter PMKPromiseRejecter;

#define PMKUnhandledExceptionError -1l
#define PMKUnderlyingExceptionKey @"PMKUnderlyingExceptionKey"


/**
 PMKPromise is provided for compatability with PromiseKit 1.x.

 It provides a few methods to ease porting, but is not identical
 to the previous version. Mostly you will get compile errors to
 help port, but you should note that exceptions are not caught in
 PromiseKit 2 (except within `+new:`).
*/
@interface PMKPromise (BackCompat)

/**
 Create a new promise that is fulfilled or rejected with the provided
 blocks.

 Use this method when wrapping asynchronous code that does *not* use
 promises so that this code can be used in promise chains.

 Don’t use this method if you already have promises! Instead, just
 return your promise.

 Should you need to fulfill a promise but have no sensical value to use;
 your promise is a `void` promise: fulfill with `nil`.

 The block you pass is executed immediately on the calling thread.

 @param block The provided block is immediately executed, any exceptions that occur will be caught and cause the returned promise to be rejected.

  - @param fulfill fulfills the returned promise with the provided value
  - @param reject rejects the returned promise with the provided `NSError`

 @return A new promise.

 @see http://promisekit.org/sealing-your-own-promises/
 @see http://promisekit.org/wrapping-delegation/
*/
+ (instancetype)new:(void(^)(PMKFulfiller fulfill, PMKRejecter reject))block __attribute__((deprecated("Use +promiseWithResolverBlock:")));


/**
 Loops until one or more promises have resolved.

 Because Promises are single-shot, the block to until must return one or more promises. They are then `when`’d. If they succeed the until loop is concluded. If they fail then the @param `catch` handler is executed.

 If the `catch` throws or returns an `NSError` then the loop is ended.

 If the `catch` handler returns a Promise then re-execution of the loop is suspended upon resolution of that Promise. If the Promise succeeds then the loop continues. If it fails the loop ends.

 An example usage is an app starting up that must get data from the Internet before the main ViewController can be shown. You can `until` the poll Promise and in the catch handler decide if the poll should be reattempted or not, perhaps returning a `UIAlertView.promise` allowing the user to choose if they continue or not.
*/
+ (PMKPromise *)until:(id (^)(void))blockReturningPromises catch:(id)failHandler;

@end
