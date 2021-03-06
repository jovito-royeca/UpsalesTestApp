//
//  UpsalesTestAppTests.swift
//  UpsalesTestAppTests
//
//  Created by Jovito Royeca on 11/02/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import XCTest

@testable import UpsalesTestApp

class UpsalesTestAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchClients() {
        let expectation = self.expectation(description: "fetch clients")
        
        UpsalesAPI.sharedInstance.fetchAccounts(ofUser: 1, completion: { error in
            XCTAssert(error != nil)
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
