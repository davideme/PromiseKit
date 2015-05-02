import MapKit
import PromiseKit

extension MKMapSnapshotter {
    /**
      Don’t cancel the Snapshotter, Apple never call the completionHandler if
      you do. Which means the promise will never resolve.
     */
    public func promise() -> Promise<MKMapSnapshot> {
        return Promise { startWithCompletionHandler($0.resolve) }
    }
}
