import Foundation
import PromiseKit

//TODO get file system encoding from LANG as it may not be UTF8

private func generateError(description: String, stdout: NSData, stderr: NSData, task: NSTask) -> NSError {
    let info: [NSObject: AnyObject] = [
        NSLocalizedDescriptionKey: description,
        PMKTaskErrorLaunchPathKey: task.launchPath,
        PMKTaskErrorArgumentsKey: task.arguments,
        PMKTaskErrorStandardOutputKey: stdout,
        PMKTaskErrorStandardErrorKey: stderr,
        PMKTaskErrorExitStatusKey: Int(task.terminationStatus),
    ]
    return NSError(domain: PMKErrorDomain, code: PMKTaskError, userInfo: info)
}


extension NSTask {
    public func promise(encoding: NSStringEncoding = NSUTF8StringEncoding) -> Promise<(String, String, Int)> {
        return promise().then(on: waldo) { (stdout: NSData, stderr: NSData, terminationStatus: Int) -> Promise<(String, String, Int)> in
            if let out = NSString(data: stdout, encoding: encoding), err = NSString(data: stderr, encoding: encoding) {
                return Promise(out as String, err as String, terminationStatus)
            } else {
                return Promise(generateError("Could not decode command output into string.", stdout, stderr,
                    self))
            }
        }
    }

    public func promise() -> Promise<(NSData, NSData, Int)> {
        standardOutput = NSPipe()
        standardError = NSPipe()

        return Promise { fulfill, reject in
            launch()

            dispatch_async(dispatch_get_global_queue(0, 0)) {
                self.waitUntilExit()

                let stdout = self.standardOutput.fileHandleForReading.readDataToEndOfFile()
                let stderr = self.standardError.fileHandleForReading.readDataToEndOfFile()

                if self.terminationReason == .Exit && self.terminationStatus == 0 {
                    fulfill(stdout, stderr, Int(self.terminationStatus))
                } else {
                    let cmd = " ".join([self.launchPath] + (self.arguments as! [String]))
                    reject(generateError("Failed executing: `\(cmd)`.", stdout, stderr, self))
                }
            }
        }
    }

    func promise() -> Promise<String> {
        return promise().then(on: zalgo) { (stdout: String, _, _) -> String in
            return stdout
        }
    }
}
