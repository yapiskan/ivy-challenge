//
//  ApiClientTests.swift
//  ivy-challengeTests
//
//  Created by Ali Ersöz on 2/24/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import XCTest

import OHHTTPStubs
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
@testable import ivy_challenge

class ApiClientTests: XCTestCase {

    var subject: ApiClient!
    override func setUp() {
        super.setUp()
        subject = ApiClient()
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testFetchBooksSuccess() {
        stub(condition: isPath("/books")) { request in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("books.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        let expectation = self.expectation(description: "fetch books")
        
        subject.fetchBooks { response in
            XCTAssertNotNil(response.value)
            XCTAssertNil(response.error)
            
            XCTAssertTrue(response.value?.count == 3, "invalid # of books")
            let firstBook = response.value!.first!
            XCTAssertTrue(firstBook.title == "Running Lean", "invalid title")
            XCTAssertTrue(firstBook.author == "Ash Maurya", "invalid author")
            XCTAssertTrue(firstBook.publisher == "O'REILLY", "invalid publisher")
            XCTAssertTrue(firstBook.categories == "process", "invalid categories")
            XCTAssertTrue(firstBook.id == 1, "invalid id")
            XCTAssertNil(firstBook.lastCheckedOut, "invalid lastCheckedOut")
            XCTAssertNil(firstBook.lastCheckedOutBy, "invalid lastCheckedOutBy")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testFetchBooksFailure() {
        stub(condition: isPath("/books")) { request in
            let obj = ["error":"something bad happened"]
            
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 503, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "fetch books failure")
        
        subject.fetchBooks { response in
            XCTAssertNotNil(response.error)
            XCTAssertNil(response.value)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testAddBookSuccess() {
        let author = "Ash Maurya"
        let title = "Running Lean"
        let publisher = "O'REILLY"
        let categories = "process"
        
        stub(condition: isPath("/books")) { request in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("addBook.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "add books success")
        subject.addBook(author: author, title: title, categories: categories, publisher: publisher, { (response) in
            XCTAssertNotNil(response.value)
            XCTAssertNil(response.error)
            
            let firstBook = response.value!
            XCTAssertTrue(firstBook.title == "Running Lean", "invalid title")
            XCTAssertTrue(firstBook.author == "Ash Maurya", "invalid author")
            XCTAssertTrue(firstBook.publisher == "O'REILLY", "invalid publisher")
            XCTAssertTrue(firstBook.categories == "process", "invalid categories")
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testAddBookFailure() {
        stub(condition: isPath("/books")) { request in
            let obj = ["error":"something bad happened"]
            
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 503, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "add book failure")
        
        subject.addBook(author: "x", title: "y", categories: "z", publisher: "t", { (response) in
            XCTAssertNotNil(response.error)
            XCTAssertNil(response.value)
            
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testUpdateBookSuccess() {
        stub(condition: isPath("/books/42")) { request in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("updateBook.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "update books success")
        let map = Map(mappingType: .fromJSON, JSON: [
            "author": "Ash Maurya",
            "categories": "process",
            "id": 42,
            "publisher": "O'REILLY",
            "title": "Running Lean" ])
        
        guard let book = try? Book(map: map) else { XCTAssert(false, "mapping error"); return }
        let person = "Prolific Pablo"
        subject.checkout(book: book, by: person) { (response) in
            XCTAssertNotNil(response.value)
            XCTAssertNil(response.error)
            
            let firstBook = response.value!
            XCTAssertTrue(firstBook.title == "Running Lean", "invalid title")
            XCTAssertTrue(firstBook.lastCheckedOutBy == person, "invalid checkout by")
            XCTAssertNotNil(firstBook.lastCheckedOut, "invalid checkout date")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testUpdateBookFailure() {
        stub(condition: isPath("/books")) { request in
            let obj = ["error":"something bad happened"]
            
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 503, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "update book failure")
        let map = Map(mappingType: .fromJSON, JSON: [
            "author": "Ash Maurya",
            "categories": "process",
            "id": 42,
            "publisher": "O'REILLY",
            "title": "Running Lean" ])
        
        guard let book = try? Book(map: map) else { XCTAssert(false, "mapping error"); return }
        
        subject.checkout(book: book, by: "") { (response) in
            XCTAssertNotNil(response.error)
            XCTAssertNil(response.value)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteBookSuccess() {
        stub(condition: isPath("/books/42")) { request in
            return OHHTTPStubsResponse(fileAtPath: OHPathForFile("updateBook.json", type(of: self))!,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "delete books success")
        let map = Map(mappingType: .fromJSON, JSON: [
            "author": "Ash Maurya",
            "categories": "process",
            "id": 42,
            "publisher": "O'REILLY",
            "title": "Running Lean" ])
        
        guard let book = try? Book(map: map) else { XCTAssert(false, "mapping error"); return }
        subject.delete(book: book) { (success) in
            XCTAssertTrue(success, "invalid response")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteBookFailure() {
        stub(condition: isPath("/books/42")) { request in
            let obj = ["error":"something bad happened"]
            
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 503, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "delete book failure")
        let map = Map(mappingType: .fromJSON, JSON: [
            "author": "Ash Maurya",
            "categories": "process",
            "id": 42,
            "publisher": "O'REILLY",
            "title": "Running Lean" ])
        
        guard let book = try? Book(map: map) else { XCTAssert(false, "mapping error"); return }
        
        subject.delete(book: book) { (success) in
            XCTAssertFalse(success, "invalid response")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteAllBooksSuccess() {
        stub(condition: isPath("/clean")) { request in
            let obj = ["error":"something bad happened"]
            
            return OHHTTPStubsResponse(jsonObject: obj,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "delete all books success")
        subject.deleteAllBooks { (success) in
            XCTAssertTrue(success, "invalid response")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteAllBooksFailure() {
        stub(condition: isPath("/clean")) { request in
            let obj = ["error":"something bad happened"]
            
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 503, headers: ["Content-Type":"application/json"])
        }
        
        let expectation = self.expectation(description: "delete all book failure")
        subject.deleteAllBooks { (success) in
            XCTAssertFalse(success, "invalid response")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
}
