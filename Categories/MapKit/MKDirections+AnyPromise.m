#import "MKDirections+AnyPromise.h"
#import <PromiseKit/PromiseKit.h>


@implementation MKDirections (PromiseKit)

- (AnyPromise *)calculateDirections {
    PMKResolver resolve;
    AnyPromise *promise = [AnyPromise promiseWithResolver:&resolve];
    [self calculateDirectionsWithCompletionHandler:^(id rsp, id err){
        resolve(err ?: rsp);
    }];
    return promise;
}

- (AnyPromise *)calculateETA {
    PMKResolver resolve;
    AnyPromise *promise = [AnyPromise promiseWithResolver:&resolve];
    [self calculateETAWithCompletionHandler:^(id rsp, id err){
        resolve(err ?: rsp);
    }];
    return promise;
}

@end
