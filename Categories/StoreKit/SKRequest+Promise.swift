import StoreKit
import PromiseKit

private class SKRequestProxy: NSObject, SKRequestDelegate {
    let (promise, fulfill, reject) = Promise<SKRequest>.defer()

    func requestDidFinish(request: SKRequest!) {
        fulfill(request)
    }

    func request(request: SKRequest!, didFailWithError error: NSError!) {
        reject(error)
    }

    @objc override class func initialize() {
        NSError.registerCancelledErrorDomain(SKErrorDomain, code: SKErrorPaymentCancelled)
    }
}

extension SKRequest {
    //TODO rename if we can avoid ambiguity
    public func __promise() -> Promise<SKRequest> {
        let proxy = SKRequestProxy()
        delegate = proxy
        proxy.promise.finally {
            proxy.description
        }
        start()
        return proxy.promise
    }
}

private class SKProductsRequestProxy: NSObject, SKProductsRequestDelegate {
    let (promise, fulfill, reject) = Promise<SKProductsResponse>.defer()

    @objc func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        fulfill(response)
    }

    @objc func request(request: SKRequest!, didFailWithError error: NSError!) {
        reject(error)
    }

    @objc override class func initialize() {
        NSError.registerCancelledErrorDomain(SKErrorDomain, code: SKErrorPaymentCancelled)
    }
}

extension SKProductsRequest {
    public func promise() -> Promise<SKProductsResponse> {
        let proxy = SKProductsRequestProxy()
        delegate = proxy
        proxy.promise.finally {
            proxy.description
        }
        start()
        return proxy.promise
    }
}
