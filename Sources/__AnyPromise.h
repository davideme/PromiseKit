#if TARGET_OS_IPHONE
    #define NSPointerArrayMake(N) ({ \
        NSPointerArray *aa = [NSPointerArray strongObjectsPointerArray]; \
        aa.count = N; \
        aa; \
    })
#else
    static inline NSPointerArray *NSPointerArrayMake(NSUInteger count) {
      #pragma clang diagnostic push
      #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSPointerArray *aa = [[NSPointerArray class] respondsToSelector:@selector(strongObjectsPointerArray)]
            ? [NSPointerArray strongObjectsPointerArray]
            : [NSPointerArray pointerArrayWithStrongObjects];
      #pragma clang diagnostic pop
        aa.count = count;
        return aa;
    }
#endif

@interface AnyPromise (Swift)
- (void)pipe:(void (^)(id))body;
- (AnyPromise *)initWithBridge:(void (^)(PMKResolver))resolver;
+ (void)__consume:(id)obj;
+ (id)__wrap:(id (^)(void))block;
@end

#define IsError(o) [o isKindOfClass:[NSError class]]
#define IsPromise(o) [o isKindOfClass:[AnyPromise class]]
