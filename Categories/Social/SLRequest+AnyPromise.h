//
//  Created by merowing on 09/05/2014.
//
//
//

#import <PromiseKit/AnyPromise.h>
#import <Social/SLRequest.h>

/**
 To import the `SLRequest` category:

    pod "PromiseKit/SLRequest"

 Or you can import all categories on `Social`:

    pod "PromiseKit/Social"
*/
@interface SLRequest (PromiseKit)
/**
 Performs the request asynchronously.

 @return A promise that fulfills with three parameters:
 1) The response decoded as JSON.
 2) The `NSHTTPURLResponse`.
 3) The raw `NSData` response.

 @warning *Note* If PromiseKit determines the response is not JSON, the first
 parameter will instead be plain `NSData`.
*/
- (AnyPromise *)promise;

@end
