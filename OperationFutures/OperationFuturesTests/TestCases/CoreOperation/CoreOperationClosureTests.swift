//
//  CoreOperationClosureTests.swift
//  OperationFuturesTests
//
//  Created by Maksym Usenko on 3/25/19.
//  Copyright © 2019 SprinkleGroup. All rights reserved.
//

import XCTest
@testable import OperationFutures

final class CoreOperationClosureTests: XCTestCase {
    
    func testStart() {
        // Given
        let executionExpectation = expectation(description: "Closure Operation `start` has failed")
        
        let blockOperation = CoreOperationClosure<Void, Void>(in: OperationQueue()) { _ in
            executionExpectation.fulfill()
            return .success(())
        }
        
        // When
        blockOperation.start()
        
        // Then
        wait(for: [executionExpectation], timeout: 0.0)
    }
    
    func testMain() {
        // Given
        let queue = OperationQueue()
        let executionExpectation = expectation(description: "Closure Operation `main` has failed")
        let blockOperation = CoreOperationClosure<Void, Void>(in: OperationQueue()) { _ in
            executionExpectation.fulfill()
            return .success(())
        }
        
        // When
        queue.addOperation(blockOperation)
        
        // Then
        wait(for: [executionExpectation], timeout: 0.0)
    }
    
    func testCanProceed() {
        // Given
        let blockOperation = CoreOperationClosure<Void, Void>(in: OperationQueue()) { _ in
            // Then
            XCTFail()
            return .success(())
        }
        
        // When
        blockOperation.cancel()
        blockOperation.main()
    }
    
    func testError() {
        // Given
        let blockOperation = CoreOperationClosure<Void, Void>(in: OperationQueue()) { _ in
            return .failure(Errors.kernal)
        }
        
        // When
        blockOperation.start()
        
        // Then
        XCTAssert(blockOperation.output.isFailurable)
    }
}

extension CoreOperationClosureTests {
    
    enum Errors: Error {
        case kernal
    }
}
