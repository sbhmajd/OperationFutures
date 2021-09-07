//
//  UseCaseTests.swift
//  OperationFuturesTests
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import XCTest
@testable import OperationFutures

final class UseCaseTests: XCTestCase {
    
    // MARK: - Tests
    func testSuccess() {
        // Given
        let operation = CoreOperation<String, String>(in: OperationQueue())
        operation.input = .success("some data")
        let successfulExpectation = expectation(description: "Success closure is failed")
        
        // When
        let useCase = UseCase<String>()
        useCase.prepareExecution(for: operation, notify: OperationQueue())
        useCase.success { result in
                XCTAssertEqual(result, "some data")
                successfulExpectation.fulfill()
            }.perform()
    
        // Then
        wait(for: [successfulExpectation], timeout: 0.001)
    }
    
    func testAlways() {
        // Given
        let operationA = CoreOperation<String, String>(in: OperationQueue())
        operationA.input = .success("some data")
        let operationB = CoreOperation<String, String>(in: OperationQueue())
        let expect = expectation(description: "'always' closure is not handled")
        
        // When
        let chain = operationA.then(operationB)
        let useCase = UseCase<String>()
        useCase.prepareExecution(for: chain, notify: OperationQueue())
        useCase.always {
            expect.fulfill()
        }.perform()
        
        // Then
        wait(for: [expect], timeout: 0.0001)
    }
    
    func testSuccessAlwaysChain() {
        // Given
        let operationA = CoreOperation<String, String>(in: OperationQueue())
        operationA.input = .success("some data")
        let operationB = CoreOperation<String, String>(in: OperationQueue())
        
        // When
        let chain = operationA.then(operationB)
        let useCase = UseCase<String>()
        
        let expectSuccess = expectation(description: "'success' closure is not handled")
        let expectAlways = expectation(description: "'always' closure is not handled with 'success' one")
        useCase.prepareExecution(for: chain, notify: OperationQueue())
        useCase.success { result in
                XCTAssertEqual(result, "some data")
                expectSuccess.fulfill()
            }
            .always {
                expectAlways.fulfill()
            }.perform()
        
        // Then
        wait(for: [expectSuccess, expectAlways], timeout: 0.01)
    }
    
    func testError() {
        // Given
        let operation = CoreOperation<String, String>(in: OperationQueue())
        operation.input = .failure(UseCaseError.kernel)
        let errorExpectation = expectation(description: "Error expectation is failed")
        
        // When
        let useCase = UseCase<String>()
        useCase.prepareExecution(for: operation, notify: OperationQueue())
        useCase.error { error in
                errorExpectation.fulfill()
            }.perform()
        
        // Then
        wait(for: [errorExpectation], timeout: 0.1)
    }
    
    func testPropagateError() {
        // Given
        let operationA = CoreOperation<String, String>(in: OperationQueue())
        operationA.input = .success("some data")
        let operationB = CoreOperation<String, String>(in: OperationQueue())
        let errorExpectation = expectation(description: "PropagateError expectation is failed")
        
        // When
        let chain = operationA.then(operationB)
        let useCase = UseCase<String>()
        
        useCase.prepareExecution(for: chain, notify: OperationQueue())
        useCase.error { _ in
            errorExpectation.fulfill()
        }
        useCase.propagate(error: UseCaseError.kernel)
        
        // Then
        wait(for: [errorExpectation], timeout: 0.001)
    }
    
    func testIsExecuting() {
        // Given
        let operation = UnfinishedOperation(in: OperationQueue())
        
        // When
        let useCase = UseCase<Void>()
        useCase.prepareExecution(for: operation, notify: OperationQueue())
        useCase.perform()
        
        // Then
        XCTAssertTrue(useCase.isExecuting(), "'isExecuting' is not handled properly")
    }
    
    func testCancelAllOperations() {
        // Given
        let operationA = UnfinishedOperation(in: OperationQueue())
        let operationB = CoreOperation<String, Void>(in: OperationQueue())
        
        // When
        let chain = operationA.then(operationB)
        let useCase = UseCase<Void>()
        useCase.prepareExecution(for: chain, notify: OperationQueue())
        useCase.perform()
        useCase.cancelAllOperations()
        
        // Then
        XCTAssertTrue(operationB.isCancelled, "'isCancelled' is not handled properly")
    }
    
    func testErrorChainAndStopTheRestOfOperations() {
        // Given
        let queue = OperationQueue()
        let executionExpectation = expectation(description: "Closure Operation")
        var isOperationCExecuted = false
        
        let operationA = CoreOperationClosure<String, String>(with: "", in: queue) { result in
            print("operationA")
            return .success("")
        }
        
        let operationB = CoreOperationClosure<String, String>(in: queue) { result in
            print("operationB")
            return Result {
                throw UseCaseError.kernel
            }
        }
        
        let operationC = CoreOperationClosure<String, String>(in: queue) { result in
            print("operationC")
            isOperationCExecuted = true
            return .success("")
        }
        
        // When
        let useCase = UseCase<String>()
        useCase.prepareExecution(for: operationA.then(operationB).then(operationC), notify: queue)
        useCase.error { error in
            print("error: ", error)
            executionExpectation.fulfill()
        }
        .perform()
        
        // Then
        wait(for: [executionExpectation], timeout: 1.0)
        XCTAssertFalse(isOperationCExecuted)
    }
}

// MARK: - Errors
extension UseCaseTests {

    private enum UseCaseError: Error {
        case kernel
    }
}
