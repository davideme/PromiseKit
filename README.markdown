PromiseKit 2
============

This is a laboratory project.

Goals
=====
* Promises that can cross objective C and Swift without any compromises to Swift.
* Even more elegant syntax
* Easier Swift promises that compromise to the compiler to some extent
* Better modularity for Carthage with at least a split into two frameworks (won't affect CocoaPods)
* Higher performance (though PMK1 has *good* performance already so don't panic)


MUSTDO
======

* Wait for all pods that depend on PMK to merge your dependency correction PRs
* Offer pre-built binaries of 1.x and 2.x including a static archive for iOS 7 people (if possible). Deprecate 1.x Swift version (remove it even, it was never official)
* Fully document all methods
* Provide example of providing promises for a library (if it's objc, provide AnyPromise, if Swift, then Promise<T>) don't feel obligated to provide both.

NICETODO
========
* Grab Promises A+ JS tests and bridge to them so we run those tests and not our rewritten in Swift version
* Documentation has a complete index
* 100% test coverage including categories
* try to share PMKOperationQueue()
* handle resolving AnyPromise with Promise<T>, document that T must be AnyObject
* passing an object or a promise directly to AnyPromise then should work
* ErrorUnhandler is not thread safe. Nothing bad can really happen since it is just a bool, just potentially duped handlers.
* Add a 10 minute stress test because PMK1 had ARC not copying blocks issues
* Use delegate version of NSURLConnection to allow cancellation, allow user to access the NSURLConnection so they can cancel it
* Should test all designated initializers for each test

DISCUSSION
==========
//CONSIDER would be better to have Promise derive AnyPromise as then you could
// use them interchangeably. Either that or conform to `thennable` like JS promises do
// but this would lead to autocompletion having a crappy then too
//EXAMPLE repeat function could just take AnyPromise
//ALSO since AnyObject is like a generic type for any-object, we would be more like Swift in general and
// doing the pattern as people would expect
//NOPE: Thennable would not help with Swift Promises being type-safe which is the whole point


2 vs 1 RATIONALEs
=================
No Exceptions are caught
------------------------
* It is not objective c to catch exceptions (almost) all exceptions that Apple throws are programmer errors that should not make it to production. It is true that catching these exceptions is harder in asynchronous code, but some of the exceptions are serious and could lead to incorrect code. For example if we exceed the bounds of an array that is part of the broader state machine (eg, a property of a view controller) then catching that exception in a promise chain could lead to the out of bounds error getting propogated beyond the realm of that task. Ideally we'd catch any exceptions that operate only on objects that are encapsulated by the chain, but this is impossible to determine.
  Ultimately it was decided that exceptions are rare and the benefits good, but not good enough to risk potentially serious integrity errors.
* We make an effort to catch some exceptions. Eg. decoding JSON can throw if the data is bad. This shouldn't really be an exception in our opinion, we catch it and reject the relevant promises.
* This also follows the apparent choices for Swift: where it is impossible to catch exceptions even though Cocoa will still throw them as per objc, implying Apple don't think we should even be able to do it.
* This is inconvenient when before you could quickly reject a chain with a simple `@throw @"error message"`, now one must return an error. For this reason we provide a Promise initializer that makes it easy to return a pre-rejected promise with a simple string error message that is converted into a proper NSError. However generally it is *better* to create detailed error messages so your eventual logs and user-facing error messages are better.
* Also having reviewed our code we found many of the times we threw a string to reject a chain indicated bad chain design (we should have gone with rightward drift instead or split up the chain more) or due to some promise being canceled (we have introduced a new cancellation system to get around this, see below)

Cancellation
============
* It was decided to standardize cancellation. Cocoa sometimes treats cancellation as an error, and sometimes not. For example, cancelling a CLGeocoder causes its completionHandler to be called with an error and cancelling an NSURLConnection (with a delegation system) causes it to error, while cancelling an MFMailViewController will cause it to complete with a Cancelled enum. * Generally the divide is errors for non-UI objects and enums for UI objects, but this isn't always the case.
* PromiseKit categories now intercept non-error cancellations and generate errors
* However cancellation is intercepted at the catch stage and… ignored. If you really want to catch a cancellation you must specify as such in the catch: `catch(includeCancellation: true) { /*…*/ }`.
* The rationale here is cancellation is always instigated by you or the user, it is not an error, and it is not a success either, it is a “nothing”. The cancellation causes the chain to resolve rejected, but no catch is called unless you want it, the net effect should result in the UI being returned to the state before your chain, and if your chain is designed sensibly this should happen via a finally, eg. a typical pattern would look like this:

    spinner.hidden = false

    fetchSomeJSON().then {
        // show json
    }.catch { err in
        // show error
    }.finally {
        spinner.hidden = true
    }
    
 With this arrangement the finally will always undo the transitional UI, the then will update the UI with the new JSON, the catch will advise the user that an error occurred and if you or the user cancelled anything in the `fetchSomeJSON` promise, the spinner will be stopped and that’s it.
* To facilitate this UIAlertView and UIActionSheet cancellation results in the chain being rejected-cancelled. Reviewing our code this improved all our promise chains. Promise chains should flow, success to success. If you put an alert view in there and the user says "NO", then having an if statement in the middle of the chain and having to branch it (or worse, rejecting the chain with a sucky-error) sucks.
* This particular feature is perhaps ill-advised, we gave it much thought and *hope* it is a good movement forwards. Please open tickets to discuss the feature if you disagree or have more food for the thinking pot.
* If the decision miffs you then just make sure to always handle cancellation in your catches. Before PromiseKit you would always have to handle such situations manually after all, so for you nothing has changed.

Cancellation is only ever triggered either by the user (that explicits chooses to cancel the operation) or you (by calling an explicitly named function named like: `cancel`). Thus it is always a flow that should not complete a chain, nor be considered a typical error. With this system cancellation behaves like an error but does not typically engage your error handler so the user will not see the error message.

The unhandler error handler is still called, but the default unhandled error handler does not log cancellations. Override it if you want them logged or something else.

Recover **always** receives cancellations. It is up to you to detect the error is a cancellation (use the cancelled bool property) and then to decide if the cancellation can be recovered.


2 vs 1 differences
==================
* Cancellation
* PMKPromise join has an extra initial parameter
