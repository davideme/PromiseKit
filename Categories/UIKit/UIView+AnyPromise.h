#import <PromiseKit/AnyPromise.h>
#import <UIKit/UIView.h>

//  Created by Masafumi Yoshida on 2014/07/11.
//  Copyright (c) 2014年 DeNA. All rights reserved.

/**
 To import the `UIView` category:

    pod "PromiseKit/UIView"

 Or you can import all categories on `UIKit`:

    pod "PromiseKit/UIKit"

 Or `UIKit` is one of the categories imported by the umbrella pod:

    pod "PromiseKit"
*/
@interface UIView (PromiseKit)

/**
 Returns a new promise that fulfills when the properties changed in the
 provided block have completed animation over `duration` seconds.

 “Then”s the `BOOL` that the underlying `completion` block receives.
*/
+ (AnyPromise *)promiseWithDuration:(NSTimeInterval)duration animations:(void (^)(void))animations;

/**
 Returns a new promise that fulfills when the properties changed in the
 provided block have completed animation over `duration` seconds with
 initial `delay` and the provided animation `options`.

 “Then”s the `BOOL` that the underlying `completion` block receives.
*/
+ (AnyPromise *)promiseWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations;

/**
 Returns a new promise that fulfills when the properties changed in the
 provided block have completed animation over `duration` seconds with
 initial `delay`, the provided animation `options` and the provided
 spring physics constants applied.

 “Then”s the `BOOL` that the underlying `completion` block receives.
*/
+ (AnyPromise *)promiseWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations;

/**
 Returns a new promise that fulfills when the properties changed in the
 provided block have completed keyframe animation over `duration`
 seconds with initial `delay` and the provided keyframe animation
 `options` applied.

 “Then”s the `BOOL` that the underlying `completion` block receives.
*/
+ (AnyPromise *)promiseWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewKeyframeAnimationOptions)options keyframeAnimations:(void (^)(void))animations;

@end
