#import <MapKit/MKDirections.h>
#import <PromiseKit/AnyPromise.h>

/**
 To import the `MKDirections` category:

    pod "PromiseKit/MKDirections"

 Or you can import all categories on `MapKit`:

    pod "PromiseKit/MapKit"
*/
@interface MKDirections (PromiseKit)

/**
 Begins calculating the requested route information asynchronously.

 @param request The request object containing the start and end points of the route.

 @return A promise that fulfills with a `MKDirectionsResponse`.
*/
- (AnyPromise *)calculateDirections;

/**
 Begins calculating the requested travel-time information asynchronously.

 @param request The request object containing the start and end points of the route.

 @return A promise that fulfills with a `MKETAResponse`.
*/
- (AnyPromise *)calculateETA;

@end
