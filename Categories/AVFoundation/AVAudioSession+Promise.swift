import AVFoundation.AVAudioSession
import Foundation
import PromiseKit


extension AVAudioSession {
    //TODO ambiguous?
    public func requestRecordPermission() -> Promise<Bool> {
        return Promise { fulfill, _ in
            requestRecordPermission(fulfill)
        }
    }
}
