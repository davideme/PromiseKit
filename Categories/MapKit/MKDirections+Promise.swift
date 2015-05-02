import PromiseKit
import MapKit

extension MKDirections {
    /**
     Calling cancel on an MKDirections instance does nothing. The API is a
     lie. Consequently this PromiseKit extension does not support
     cancellation.
    */
    public func promise() -> Promise<MKDirectionsResponse> {
        return Promise { calculateDirectionsWithCompletionHandler($0.resolve) }
    }

    public func promise() -> Promise<MKETAResponse> {
        return Promise { calculateETAWithCompletionHandler($0.resolve) }
    }
}
