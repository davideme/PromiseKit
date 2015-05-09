#import "PMKPromise.h"
#import "AnyPromise+Private.h"
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



@implementation PMKPromise (BackCompat)

+ (instancetype)new:(void(^)(PMKFulfiller, PMKRejecter))block {
    return [AnyPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        id rejecter = ^(id error){
            if (error == nil) {
                error = NSErrorFromNil();
            } else if (IsPromise(error) && ![error pending] && ![error value]) {
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

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"

+ (PMKPromise *)until:(id (^)(void))blockReturningPromises catch:(id)failHandler {
    return [PMKPromise promiseWithResolverBlock:^(PMKResolver resolve) {
        __block void (^block)() = ^{
            AnyPromise *next = PMKWhen(blockReturningPromises());
            next.then(^(id o){
                resolve(o);
                block = nil;
            });
            next.catch(^(NSError *error){
                [AnyPromise promiseWithValue:error].catch(failHandler).then(block).catch(^{
                    resolve(error);
                    block = nil;
                });
            });
        };
        block();
    }];
}

#pragma clang diagnostic pop

@end
