#import <dispatch/object.h>
#import <dispatch/queue.h>
#import <Foundation/NSObject.h>
#import <PromiseKit/Swift.h>

typedef void (^PMKResolver)(id);

typedef NS_ENUM(NSInteger, PMKCatchPolicy) {
    PMKCatchPolicyAllErrors,
    PMKCatchPolicyAllErrorsExceptCancellation
};


/**
 @see AnyPromise.swift
*/
@interface AnyPromise (objc)

- (AnyPromise *(^)(id))then;
- (AnyPromise *(^)(id))thenInBackground;
- (AnyPromise *(^)(dispatch_queue_t, id))thenOn;

#ifndef __cplusplus
- (AnyPromise *(^)(id))catch;
#endif
- (AnyPromise *(^)(PMKCatchPolicy, id))catchWithPolicy;

- (AnyPromise *(^)(dispatch_block_t))finally;
- (AnyPromise *(^)(dispatch_queue_t, dispatch_block_t))finallyOn;

+ (instancetype)promiseWithValue:(id)value;
+ (instancetype)promiseWithResolver:(PMKResolver __strong *)resolver;
+ (instancetype)promiseWithResolverBlock:(void (^)(PMKResolver resolve))resolverBlock;

@property (nonatomic, readonly) id value;

@end



typedef void (^PMKAdapter)(id, NSError *);
typedef void (^PMKIntegerAdapter)(NSInteger, NSError *);
typedef void (^PMKBooleanAdapter)(BOOL, NSError *);

@interface AnyPromise (Adapters)

/**
 Create a new promise by adapting an existing asynchronous system.

 The pattern of a completion block that passes two parameters, the first
 the result and the second an `NSError` object is so common that we
 provide this convenience adapter to make wrapping such systems more
 elegant.

    return [PMKPromise promiseWithAdapter:^(PMKAdapter adapter){
        PFQuery *query = [PFQuery …];
        [query findObjectsInBackgroundWithBlock:adapter];
    }];

 @warning *Important* If both parameters are nil, the promise fulfills,
 if both are non-nil the promise rejects. This is per the convention.

 @see http://promisekit.org/sealing-your-own-promises/
 */
+ (instancetype)promiseWithAdapterBlock:(void (^)(PMKAdapter adapter))block;

/**
 Create a new promise by adapting an existing asynchronous system.

 Adapts asynchronous systems that complete with `^(NSInteger, NSError *)`.
 NSInteger will cast to enums provided the enum has been wrapped with
 `NS_ENUM`. All of Apple’s enums are, so if you find one that hasn’t you
 may need to make a pull-request.

 @see promiseWithAdapter
 */
+ (instancetype)promiseWithIntegerAdapterBlock:(void (^)(PMKIntegerAdapter adapter))block;

/**
 Create a new promise by adapting an existing asynchronous system.

 Adapts asynchronous systems that complete with `^(BOOL, NSError *)`.

 @see promiseWithAdapter
 */
+ (instancetype)promiseWithBooleanAdapterBlock:(void (^)(PMKBooleanAdapter adapter))block;

@end



@interface AnyPromise (when)
+ (instancetype)when:(id)input;
@end

@interface AnyPromise (join)
+ (instancetype)join:(NSArray *)promises;
@end

@interface AnyPromise (hang)
+ (instancetype)hang:(AnyPromise *)promise;
@end



/**
 Whenever resolving a promise you may resolve with a tuple, eg.
 returning from a `then` or `catch` handler or resolving a new promise.

 Consumers of your Promise are not compelled to consume any arguments and
 in fact will often only consume the first parameter. Thus ensure the
 order of parameters is: from most-important to least-important.

 Currently PromiseKit limits you to THREE parameters to the manifold.
*/
#define PMKManifold(...) __PMKManifold(__VA_ARGS__, 3, 2, 1)
#define __PMKManifold(_1, _2, _3, N, ...) __PMKArrayWithCount(N, _1, _2, _3)
extern id __PMKArrayWithCount(NSUInteger, ...);


#ifndef PMKNoBackCompat
#import <PromiseKit/PMKPromise.h>
#endif
