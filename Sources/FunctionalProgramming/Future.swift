/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import Dispatch

//: Simple Future implementation, no errors, no composition
//: Leaks memory, most likely

// MARK: - first, basic future without ResultOrError

public class Future<Outcome> {
    private typealias Reader = (Outcome) -> Void
    private var outcomeIfKnown: Outcome?
    private var readerIfKnown: Reader?
    
    
    private let racePrevention = DispatchSemaphore(value: 1)
    private func oneAtATime(_ fn: () -> Void) {
        defer { racePrevention.signal() }
        racePrevention.wait()
        fn()
    }
    
    
    public init() {}
    
    public convenience init(outcome: Outcome) {
        self.init()
        write(outcome)
    }
    
    
    public func write(_ outcome: Outcome) -> Void {
        oneAtATime {
            if let reader = self.readerIfKnown {
                DispatchQueue(label: "Future reader", qos: .userInitiated)
                .async {
                    reader(outcome)
                }
            }
            else {
                self.outcomeIfKnown = outcome
            }
        }
    }
    
    public func then<NewOutcome>(
        qos: FutureQOS = .userInitiated,
        _ fn: @escaping (Outcome) -> Future<NewOutcome>
        )
        -> Future<NewOutcome>
    {
        let future = Future<NewOutcome>()
        finally(qos: qos) {
            fn($0).finally(future.write)
        }
        return future
    }
    
    public func then<NewOutcome>(
        qos: FutureQOS = .userInitiated,
        _ fn: @escaping (Outcome) -> NewOutcome
        )
        -> Future<NewOutcome>
    {
        let future = Future<NewOutcome>()
        finally(qos: qos) {
            fn($0) |> future.write
        }
        return future
    }
    
    public func finally(
        qos: FutureQOS = .userInitiated,
        _ reader: @escaping (Outcome) -> Void
        )
    {
        oneAtATime {
            if let outcome = self.outcomeIfKnown {
                DispatchQueue(label: "Future reader", qos: .userInitiated)
                .async {
                    reader(outcome)
                }
            }
            else {
                self.readerIfKnown = reader
            }
        }
    }
}


// MARK: - constructors with result or error. Not easily coded as constructors

extension Future {

    public static func with<Result>(result: Result) -> Future<ResultOrError<Result>>  {
        return Future<ResultOrError<Result>>(outcome: .success( result ))
    }
    public static func with<Result>(error: Error) -> Future<ResultOrError<Result>>  {
        return Future<ResultOrError<Result>>(outcome: .failure( error ))
    }
    
    public static func catching<Result>(_ fn: () throws -> Future<Result>)  ->  Future<ResultOrError<Result>> {
        typealias MyFuture = Future<ResultOrError<Result>>
        do {
            return try fn().then (with(result:))
        }
        catch {
            return with(error: error)
        }
    }
}


// MARK: - members when outcome is result or error. Finagling with protocols to do it.

public protocol ResultOrErrorProtocol {
    associatedtype Result
    var asResultOrError: ResultOrError<Result> { get }
}
extension ResultOrError: ResultOrErrorProtocol {
    public var asResultOrError: ResultOrError { return self }
}

public extension Future where Outcome: ResultOrErrorProtocol {
    
    
    // Consuming function produces a Future:
    public func thenIfSuccess<NewResult>( _ fn: @escaping (Outcome.Result) -> Future<ResultOrError<NewResult>>) -> Future<ResultOrError<NewResult>> {
        let future = Future<ResultOrError<NewResult>>()
        finally {
            switch $0.asResultOrError {
            case .success(let result):  fn(result).finally( future.write )
            case .failure(let error ):  future.write( .failure(error) )
            }
        }
        return future
    }
    
    // Consuming function produces a new result type:
    public func thenIfSuccess<NewResult>( _ fn: @escaping (Outcome.Result) -> NewResult) -> Future<ResultOrError<NewResult>> {
        let future = Future<ResultOrError<NewResult>>()
        finally {
            switch $0.asResultOrError {
            case .success(let result):  future.write( .success( fn(result) ) )
            case .failure(let error ):  future.write( .failure(error)        )
            }
        }
        return future
    }
    
    // Consuming function consumes error, produces nothing:
    public func thenIfFailure( _ fn: @escaping (Error) -> Void) -> Future<ResultOrError<Outcome.Result>> {
        let future = Future<ResultOrError<Outcome.Result>>()
        finally {
            switch $0.asResultOrError {
            case .success: future.write($0.asResultOrError)
            case .failure(let error):
                fn(error)
                future.write(.failure(AlreadyHandledError(error: error)))
            }
        }
        return future
    }
}
