#import <dispatch/queue.h>
#import <Foundation/NSObject.h>
#import <PromiseKit/AnyPromise.h>
#import <PromiseKit/Swift.h>
#import <PromiseKit/Umbrella.h>



#define PMKJSONDeserializationOptions ((NSJSONReadingOptions)(NSJSONReadingAllowFragments | NSJSONReadingMutableContainers))

#define PMKHTTPURLResponseIsJSON(rsp) [@[@"application/json", @"text/json", @"text/javascript"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsImage(rsp) [@[@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsText(rsp) [[rsp MIMEType] hasPrefix:@"text/"]



#if COCOAPODS
// causes all subspec headers to be included
#import <PromiseKit/Pods-PromiseKit-umbrella.h>
#endif
