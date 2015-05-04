#import <MapKit/MKMapSnapshotter.h>
#import <PromiseKit/AnyPromise.h>

/**
 To import the `MKSnapshotter` category:

    pod "PromiseKit/MapKit"

 And then in your sources:

    #import <PromiseKit/PromiseKit.h>
*/
@interface MKMapSnapshotter (PromiseKit)

/**
 Starts generating the snapshot using the options set in this object.

 @return A promise that fulfills with the generated `MKMapSnapshot` object.
*/
- (AnyPromise *)promise;

@end
