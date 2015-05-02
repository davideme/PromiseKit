#import <PromiseKit/AnyPromise.h>

/**
 If we can already reach the Internet, resolves immediately,
 otherwise resolves as soon as the Internet is accessible.
*/
AnyPromise *SCNetworkReachability();
