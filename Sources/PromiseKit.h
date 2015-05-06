#import <dispatch/queue.h>
#import <Foundation/NSObject.h>
#import <PromiseKit/AnyPromise.h>
#import <PromiseKit/Swift.h>
#import <PromiseKit/Umbrella.h>



#define PMKJSONDeserializationOptions ((NSJSONReadingOptions)(NSJSONReadingAllowFragments | NSJSONReadingMutableContainers))

#define PMKHTTPURLResponseIsJSON(rsp) [@[@"application/json", @"text/json", @"text/javascript"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsImage(rsp) [@[@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsText(rsp) [[rsp MIMEType] hasPrefix:@"text/"]



#if COCOAPODS_POD_AVAILABLE_PromiseKit_Accounts
  #import <PromiseKit/ACAccountStore+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_AVFoundation
  #import <PromiseKit/AVAudioSession+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_CloudKit
  #import <PromiseKit/CKContainer+AnyPromise.h>
  #import <PromiseKit/CKDatabase+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_CoreLocation
  #import <PromiseKit/CLGeocoder+AnyPromise.h>
  #import <PromiseKit/CLLocationManager+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_Foundation
  #import <PromiseKit/NSNotificationCenter+AnyPromise.h>
  #if !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    #import <PromiseKit/NSTask+AnyPromise.h>
  #endif
  #import <PromiseKit/NSURLConnection+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_MapKit
  #import <PromiseKit/MKDirections+AnyPromise.h>
  #import <PromiseKit/MKMapSnapshotter+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_QuartzCore
  #import <PromiseKit/CALayer+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_Social
  #import <PromiseKit/SLRequest+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_StoreKit
  #import <PromiseKit/SKRequest+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_SystemConfiguration
  #import <PromiseKit/SCNetworkReachability+AnyPromise.h>
#endif
#if COCOAPODS_POD_AVAILABLE_PromiseKit_UIKit
  #if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    #import <PromiseKit/UIActionSheet+AnyPromise.h>
    #import <PromiseKit/UIAlertView+AnyPromise.h>
    #import <PromiseKit/UIView+AnyPromise.h>
    #import <PromiseKit/UIViewController+AnyPromise.h>
  #endif
#endif
