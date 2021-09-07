//
//  CoreOperationTests.swift
//  OperationFuturesTests
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import XCTest
@testable import OperationFutures

final class CoreOperationTests: XCTestCase {
    
    // MARK: - Properties
    private let operation = CoreOperation<String, Void>(in: OperationQueue())
    private let dependency = Operation()
    private let queue = OperationQueue()
    
    // MARK: - Life Cycle
    override func tearDown() {
        operation.removeDependency(dependency)
        super.tearDown()
    }
    
    // MARK: - State tests
    func testReadyState() {
        // Given
        XCTAssert(operation.isReady, "'isReady' status has wrong value")
        
        // When
        operation.addDependency(dependency)
        XCTAssertFalse(operation.isReady, "'isReady' status has wrong value")
        
        // Then
        dependency.start()
        XCTAssert(operation.isReady, "'isReady' status has wrong value")
    }
    
    func testExecutingState() {
        // Given
        let unfinished = UnfinishedOperation(in: queue)
        XCTAssertFalse(unfinished.isExecuting, "'isExecuting' status has wrong value")
        
        // When
        unfinished.start()
        
        // Then
        XCTAssert(unfinished.isExecuting, "'isExecuting' status has wrong value")
    }
    
    func testFinishedState() {
        // Given
        let operation = CoreOperation<String, String>(in: queue)
        XCTAssertFalse(operation.isFinished, "'isFinished' status has wrong value")
        
        // When
        let executionExpectation = expectation(description: "'executionHandler' has failed")
        operation.completionBlock = {
            XCTAssert(operation.isFinished, "'isFinished' status has wrong value")
            executionExpectation.fulfill()
        }
        queue.addOperation(operation)
        
        // Then
        wait(for: [executionExpectation], timeout: 0.0001)
    }
    
    func testCancelState() {
        // Given
        let unfinished = UnfinishedOperation(in: queue)
        XCTAssertFalse(unfinished.isCancelled, "'isCancelled' status has wrong value")
        
        // When
        unfinished.start()
        unfinished.cancel()
        
        // Then
        XCTAssert(unfinished.isCancelled, "'isCancelled' status has wrong value")
    }
    
    // MARK: - Actions Tests
    
    func testStart() {
        // Given
        let unfinished = UnfinishedOperation(in: queue)
        unfinished.cancel()
        
        // When
        unfinished.start()
        
        // Then
        XCTAssert(unfinished.isFinished, "'isFinished' status must be setted when an operations starts")
    }
    
    func testCancel() {
        // Given
        let unfinished = UnfinishedOperation(in: queue)
        unfinished.input = .success("some text")
        XCTAssertFalse(unfinished.isCancelled)
        
        // When
        unfinished.start()
        unfinished.cancel()
        
        // Then
        XCTAssertTrue(unfinished.isCancelled)
        XCTAssert(unfinished.output.isFailurable, "The Operation must propagate an error")
    }
    
    func testDoubleCancelation() {
        // Given
        let unfinished = UnfinishedOperation(in: queue)
        unfinished.input = .success("some text")
        unfinished.start()
        
        // When
        XCTAssertFalse(unfinished.output.isFailurable, "Output is invalid after cancelation")
        unfinished.cancel()
        
        // Then
        XCTAssertTrue(unfinished.output.isFailurable, "Output is invalid after cancelation")
        unfinished.output = .success(())
        unfinished.cancel()
        XCTAssertFalse(unfinished.output.isFailurable, "Output is invalid after double cancelation")
    }
    
    func testCanProceed() {
        // Given
        XCTAssertTrue(operation.canProceed())
        XCTAssertTrue(operation.isExecuting)
        
        // When
        operation.cancel()
        
        // Then
        XCTAssertFalse(operation.canProceed())
        XCTAssertFalse(operation.isExecuting)
    }
    
    func testFinished() {
        // Given
        let expect = expectation(description: "'executionHandler' has failed")
        operation.completed = {
            expect.fulfill()
        }
        XCTAssertFalse(operation.isFinished)
        
        // When
        operation.finished()
        
        // Then
        XCTAssertTrue(operation.isFinished)
        wait(for: [expect], timeout: 0.0)
    }
    
    func testOutputCasting() {
        // Given
        let data = "some data"
        let operationA = CoreOperation<String, String>(in: queue)
        operationA.input = .success(data)
        let operationB = CoreOperation<String, Void>(in: queue)
        
        // When
        let chain = operationA.then(operationB)
        let expect = expectation(description: "")
        chain.completed = {
            XCTAssert(chain.output.isFailurable, "Wrong data")
            expect.fulfill()
        }
        queue.addOperationChain(chain)
        
        // Then
        wait(for: [expect], timeout: 0.001)
    }
}
