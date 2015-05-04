#import "PMKPromise.h"
#import "__AnyPromise.h"
#import "PromiseKit.h"

#ifndef PMKLog
#define PMKLog NSLog
#endif



static inline NSError *NSErrorFromNil() {
    PMKLog(@"PromiseKit: Warning: Promise rejected with nil");
    return [NSError errorWithDomain:PMKErrorDomain code:PMKInvalidUsageError userInfo:nil];
}

static inline NSError *NSErrorFromException(id exception) {
    if (!exception)
        return NSErrorFromNil();

    id userInfo = @{
        PMKUnderlyingExceptionKey: exception,
        NSLocalizedDescriptionKey: [exception isKindOfClass:[NSException class]]
            ? [exception reason]
            : [exception description]
    };
    return [NSError errorWithDomain:PMKErrorDomain code:PMKUnhandledExceptionError userInfo:userInfo];
}



@implementation PMKPromise (objc)

+ (instancetype)new:(void(^)(PMKFulfiller, PMKRejecter))block {
    return [self promiseWithResolverBlock:^(PMKResolver resolve) {
        id rejecter = ^(id error){
            if (error == nil) {
                error = NSErrorFromNil();
            } else if (IsPromise(error) && [error rejected]) {
                // this is safe, acceptable and (basically) valid
            } else if (!IsError(error)) {
                id userInfo = @{
                    NSLocalizedDescriptionKey: [error description],
                    PMKUnderlyingExceptionKey: error
                };
                error = [NSError errorWithDomain:PMKErrorDomain code:PMKInvalidUsageError userInfo:userInfo];
            }
            resolve(error);
        };

        id fulfiller = ^(id result){
            if (IsError(result))
                PMKLog(@"PromiseKit: Warning: PMKFulfiller called with NSError.");
            resolve(result);
        };

        @try {
            block(fulfiller, rejecter);
        } @catch (id thrown) {
            resolve(NSErrorFromException(thrown));
        }
    }];
}

- (BOOL)resolved {
    return !self.pending;
}

- (BOOL)fulfilled {
    return self.resolved && !self.rejected;
}

- (BOOL)rejected {
    return [self.value isKindOfClass:[NSError class]];
}

+ (id)__wrap:(id (^)(void))block {
    @try {
        return block();
    } @catch (id thrown) {
        return NSErrorFromException(thrown);
    }
}

- (id)__value {
    return [self valueForKey:@"____value"];
}

@end



PMKPromise *dispatch_promise(id block) {
    return dispatch_promise_on(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

PMKPromise *dispatch_promise_on(dispatch_queue_t queue, id block) {
    return (id)[PMKPromise promiseWithValue:nil].thenOn(queue, block);
}



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

@implementation PMKPromise (Until)

+ (PMKPromise *)until:(id (^)(void))blockReturningPromises catch:(id)failHandler {
    return [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve){
        __block void (^block)() = ^{
            PMKPromise *next = [self when:blockReturningPromises()];
            next.then(^(id o){
                resolve(o);
                block = nil;  // break retain cycle
            });
            next.catch(^(NSError *error){
                [PMKPromise promiseWithValue:error].catch(failHandler).then(block).catch(^{
                    resolve(error);
                    block = nil;  // break retain cycle
                });
            });
        };
        block();
    }];
}

@end

#pragma clang diagnostic pop



@implementation PMKPromise (Pause)

+ (PMKPromise *)pause:(NSTimeInterval)duration {
    return [self promiseWithResolverBlock:^(PMKResolver resolve) {
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC));
        dispatch_after(time, dispatch_get_global_queue(0, 0), ^{
            resolve(@(duration));
        });
    }];
}

@end
