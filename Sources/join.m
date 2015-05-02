#import "AnyPromise.h"
#import "__AnyPromise.h"

@implementation AnyPromise (join)

+ (AnyPromise *)join:(NSArray *)promises {
    if (promises.count == 0)
        return [self promiseWithValue:PMKManifold(promises, promises)];

    return [self promiseWithResolverBlock:^(PMKResolver resolve) {
        NSPointerArray *results = NSPointerArrayMake(promises.count);

        __block NSUInteger x = 0;

        [promises enumerateObjectsUsingBlock:^(AnyPromise *promise, NSUInteger ii, BOOL *stop) {
            [promise pipe:^(id value) {
                [results replacePointerAtIndex:ii withPointer:(__bridge void *)(value ?: [NSNull null])];
                if (++x == promises.count) {
                    id apples = results.allObjects;
                    id values = [NSMutableArray new];
                    id errors = [NSMutableArray new];
                    for (id apple in apples)
                        [IsError(apple) ? errors : values addObject:apple];
                    if ([errors count] == 0)
                        errors = nil;
                    resolve(PMKManifold(apples, values, errors));
                }
            }];
        }];
    }];
}

@end
