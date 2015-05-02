import PromiseKit
import Photos.PHPhotoLibrary

extension PHPhotoLibrary {
    public class func requestAuthorization() -> Promise<PHAuthorizationStatus> {
        return Promise { requestAuthorization($0.resolve) }
    }
}
