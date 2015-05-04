#import <Foundation/NSDate.h>
#import <PromiseKit/AnyPromise.h>

typedef void (^PMKFulfiller)(id);
typedef void (^PMKRejecter)(NSError *);

#define PMKUnhandledExceptionError -1l
#define PMKUnderlyingExceptionKey @"PMKUnderlyingExceptionKey"


/**
 PMKPromise is provided for compatability with PromiseKit 1.x.
 
 It derives AnyPromise but modifies its behaviour subtley:
 
  1) Exceptions are caught in handlers and `new:`.
  2) `value` returns either resolution not just the fulfillment.

 Also we provide a number of 1.x functions that are not present or
 have been renamed in PromiseKit 2.
*/
@interface PMKPromise (objc)

/**
 Create a new promise that is fulfilled or rejected with the provided
 blocks.

 Use this method when wrapping asynchronous code that does *not* use
 promises so that this code can be used in promise chains.

 Don’t use this method if you already have promises! Instead, just
 return your promise.

 @param block The provided block is immediately executed, any exceptions that occur will be caught and cause the returned promise to be rejected.
   - @param fulfill fulfills the returned promise with the provided value
   - @param reject rejects the returned promise with the provided `NSError`

 Should you need to fulfill a promise but have no sensical value to use;
 your promise is a `void` promise: fulfill with `nil`.

 The block you pass is executed immediately on the calling thread.

 @return A new promise.

 @see http://promisekit.org/sealing-your-own-promises/
 @see http://promisekit.org/wrapping-delegation/
*/
+ (instancetype)new:(void(^)(PMKFulfiller fulfill, PMKRejecter reject))block;

/// @return `YES` if the promise has resolved (ie. is fulfilled or rejected) `NO` if it is pending.
- (BOOL)resolved;

/// @return `YES` if the promise is fulfilled, `NO` if it is rejected or pending.
- (BOOL)fulfilled;

/// @return `YES` if the promise is rejected, `NO` if it is fulfilled or pending.
- (BOOL)rejected;

@end



/**
 Executes the provided block on a background queue.

 dispatch_promise is a convenient way to start a promise chain where the
 first step needs to run synchronously on a background queue.

 @param block The block to be executed in the background. Returning an `NSError` will reject the promise, everything else (including void) fulfills the promise.

 @return A promise resolved with the provided block.

 @see dispatch_async
*/
PMKPromise *dispatch_promise(id block);

/**
 Executes the provided block on the specified queue.

 @see dispatch_promise
 @see dispatch_async
*/
PMKPromise *dispatch_promise_on(dispatch_queue_t q, id block);



@interface PMKPromise (Until)
/**
 Loops until one or more promises have resolved.

 Because Promises are single-shot, the block to until must return one or more promises. They are then `when`’d. If they succeed the until loop is concluded. If they fail then the @param `catch` handler is executed.

 If the `catch` throws or returns an `NSError` then the loop is ended.

 If the `catch` handler returns a Promise then re-execution of the loop is suspended upon resolution of that Promise. If the Promise succeeds then the loop continues. If it fails the loop ends.

 An example usage is an app starting up that must get data from the Internet before the main ViewController can be shown. You can `until` the poll Promise and in the catch handler decide if the poll should be reattempted or not, perhaps returning a `UIAlertView.promise` allowing the user to choose if they continue or not.
*/
+ (PMKPromise *)until:(id(^)(void))blockReturningPromiseOrArrayOfPromises catch:(id)catchHandler;

@end



@interface PMKPromise (Pause)
/**
 @param duration The duration in seconds to wait before resolving this promise.
 @return A promise that thens the duration it waited before resolving.
*/
+ (PMKPromise *)pause:(NSTimeInterval)duration;

@end
