//
//  LibraryViewModelTests.swift
//  ivy-challengeTests
//
//  Created by Ali Ersöz on 2/24/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import Foundation


@testable import ivy_challenge

enum ApiError: Error {
	case randomError
    case none
}

class MockApiClient: ApiClientProtocol {
    var shouldReturnError = false
    func fetchBooks(_ completionHandler: @escaping (Result<[Book]>) -> Void) {
        if shouldReturnError {
            completionHandler(Result.failure(ApiError.randomError))
            return
        }
        
        let result = Result<[Book]>(value: {
            return [dummyBook]
        })
        
        completionHandler(result)
    }
    
    func addBook(author: String, title: String, categories: String, publisher: String, _ completionHandler: @escaping (Result<Book>) -> Void) {
        if shouldReturnError {
            completionHandler(Result.failure(ApiError.randomError))
            return
        }
        
        let book = createBook(title: title, author: author, categories: categories, publisher: publisher)
        let result = Result<Book>(value: {
            return book
        })
        
        completionHandler(result)
    }
    
    func checkout(book: Book, by: String, _ completionHandler: @escaping (Result<Book>) -> Void) {
        if shouldReturnError {
            completionHandler(Result.failure(ApiError.randomError))
            return
        }
        
        book.lastCheckedOutBy = by
        book.lastCheckedOut = Date()
        
        let result = Result<Book>(value: {
            return book
        })
        
        completionHandler(result)
    }
    
    func delete(book: Book, _ completionHandler: @escaping (Bool) -> Void) {
        if shouldReturnError {
            completionHandler(false)
            return
        }
        
        completionHandler(true)
    }
    
    func deleteAllBooks(_ completionHandler: @escaping (Bool) -> Void) {
        if shouldReturnError {
            completionHandler(false)
            return
        }
        
        completionHandler(true)
    }
    
    var dummyBook: Book {
        let map = Map(mappingType: .fromJSON, JSON: [
            "author": "Ash Maurya",
            "categories": "process",
            "id": 1,
            "publisher": "O'REILLY",
            "title": "Running Lean" ])
        
        let book = try! Book(map: map)
        return book
    }
    
    var dummyBook2: Book {
        let map = Map(mappingType: .fromJSON, JSON: [
            "author": "Jim Collins",
            "categories": "business",
            "id": 2,
            "publisher": "HarperBusiness; 1 edition",
            "title": "Good to Great: Why Some Companies Make the Leap...And Others Don't"
            ])
        
        let book = try! Book(map: map)
        return book
    }
    
    func createBook(title: String, author: String, categories: String, publisher: String) -> Book {
        let map = Map(mappingType: .fromJSON, JSON: [
            "author": author,
            "categories": categories,
            "id": Int(arc4random_uniform(10000)),
            "publisher": publisher,
            "title": title
            ])
        
        let book = try! Book(map: map)
        return book
    }
}

class LibraryViewModelTests: XCTestCase {
    
    var subject: LibraryViewModelProtocol!
    override func setUp() {
        super.setUp()
        subject = LibraryViewModel(apiClient: MockApiClient())
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    func testFetchBooks() {
        let expectation = self.expectation(description: "fetch books success")
        subject.fetchBooks(refresh: true) { (success) in
            XCTAssertTrue(success)
            XCTAssertTrue(self.subject.books.count == 1)
            let firstBook = self.subject.books.first!
            XCTAssertTrue(firstBook.title == "Running Lean")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testFetchBooksFailure() {
        let expectation = self.expectation(description: "fetch books failure")
        
        let apiClient = MockApiClient()
        apiClient.shouldReturnError = true
        subject = LibraryViewModel(apiClient: apiClient)
        subject.fetchBooks(refresh: true) { (success) in
            XCTAssertFalse(success)
            XCTAssertTrue(self.subject.books.count == 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testAddBook() {
        let expectation = self.expectation(description: "add book success")
        subject.addBook(author: "J.D. Salinger", title: "Cather in the Rye", categories: "American Classic", publisher: "Publisher") { (book) in
            XCTAssertNotNil(book)
            
            guard let b = book else { return }
            XCTAssertTrue(self.subject.books.count == 1)
            XCTAssertTrue(b.author == "J.D. Salinger")
            XCTAssertTrue(b.id > 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testAddBookFailure() {
        let expectation = self.expectation(description: "add book failure")
        
        let apiClient = MockApiClient()
        apiClient.shouldReturnError = true
        subject = LibraryViewModel(apiClient: apiClient)
        
        let book1 = MockApiClient().createBook(title: "T1", author: "A1", categories: "C1", publisher: "P1")
        let book2 = MockApiClient().createBook(title: "T2", author: "A2", categories: "C2", publisher: "P2")
        let book3 = MockApiClient().createBook(title: "T3", author: "A3", categories: "C3", publisher: "P3")
        subject.books = [book1, book2, book3]
        subject.addBook(author: "J.D. Salinger", title: "Cather in the Rye", categories: "American Classic", publisher: "Publisher") { (book) in
            XCTAssertNil(book)
            XCTAssertTrue(self.subject.books.count == 3)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testCheckoutBook() {
        let expectation = self.expectation(description: "checkout book success")
        
        let book1 = MockApiClient().createBook(title: "T1", author: "A1", categories: "C1", publisher: "P1")
        let book2 = MockApiClient().createBook(title: "T2", author: "A2", categories: "C2", publisher: "P2")
        let book3 = MockApiClient().createBook(title: "T3", author: "A3", categories: "C3", publisher: "P3")
        subject.books = [book1, book2, book3]
        
        subject.checkout(book: book1, by: "Ali") { (book) in
            XCTAssertNotNil(book)
            
            guard let b = book else { return }
            XCTAssertTrue(self.subject.books.count == 3)
            XCTAssertTrue(b.author == "A1")
            XCTAssertTrue(b.title == "T1")
            XCTAssertTrue(b.lastCheckedOutBy == "Ali")
            XCTAssertNotNil(b.lastCheckedOut)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testCheckoutBookFailure() {
        let expectation = self.expectation(description: "checkout book success")
        let apiClient = MockApiClient()
        apiClient.shouldReturnError = true
        subject = LibraryViewModel(apiClient: apiClient)
        
        let book1 = MockApiClient().createBook(title: "T1", author: "A1", categories: "C1", publisher: "P1")
        let book2 = MockApiClient().createBook(title: "T2", author: "A2", categories: "C2", publisher: "P2")
        let book3 = MockApiClient().createBook(title: "T3", author: "A3", categories: "C3", publisher: "P3")
        subject.books = [book1, book2, book3]
        
        subject.checkout(book: book1, by: "Ali") { (book) in
            XCTAssertNil(book)
            
            XCTAssertTrue(self.subject.books.count == 3)
            XCTAssertFalse(book1.lastCheckedOutBy == "Ali")
            XCTAssertNil(book1.lastCheckedOut)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteBook() {
        let expectation = self.expectation(description: "delete book success")
        let book1 = MockApiClient().createBook(title: "T1", author: "A1", categories: "C1", publisher: "P1")
        let book2 = MockApiClient().createBook(title: "T2", author: "A2", categories: "C2", publisher: "P2")
        let book3 = MockApiClient().createBook(title: "T3", author: "A3", categories: "C3", publisher: "P3")
        subject.books = [book1, book2, book3]
        
        subject.delete(book: book1) { (success) in
            XCTAssertTrue(success)
            
            XCTAssertTrue(self.subject.books.count == 2)
            guard let b = self.subject.books.first else { return }
            
            XCTAssertTrue(b.author == "A2")
            XCTAssertTrue(b.title == "T2")
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteBookFailure() {
        let expectation = self.expectation(description: "delete book failure")
        let apiClient = MockApiClient()
        apiClient.shouldReturnError = true
        subject = LibraryViewModel(apiClient: apiClient)
        
        let book1 = MockApiClient().createBook(title: "T1", author: "A1", categories: "C1", publisher: "P1")
        let book2 = MockApiClient().createBook(title: "T2", author: "A2", categories: "C2", publisher: "P2")
        let book3 = MockApiClient().createBook(title: "T3", author: "A3", categories: "C3", publisher: "P3")
        subject.books = [book1, book2, book3]
        
        subject.delete(book: book1) { (success) in
            XCTAssertFalse(success)
            XCTAssertTrue(self.subject.books.count == 3)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteAllBooks() {
        let expectation = self.expectation(description: "delete all books success")
        let book1 = MockApiClient().createBook(title: "T1", author: "A1", categories: "C1", publisher: "P1")
        let book2 = MockApiClient().createBook(title: "T2", author: "A2", categories: "C2", publisher: "P2")
        let book3 = MockApiClient().createBook(title: "T3", author: "A3", categories: "C3", publisher: "P3")
        subject.books = [book1, book2, book3]
        
        subject.deleteAll { (success) in
            XCTAssertTrue(success)
            XCTAssertTrue(self.subject.books.count == 0)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testDeleteAllBooksFailure() {
        let expectation = self.expectation(description: "delete all books failure")
        let apiClient = MockApiClient()
        apiClient.shouldReturnError = true
        subject = LibraryViewModel(apiClient: apiClient)
        
        let book1 = MockApiClient().createBook(title: "T1", author: "A1", categories: "C1", publisher: "P1")
        let book2 = MockApiClient().createBook(title: "T2", author: "A2", categories: "C2", publisher: "P2")
        let book3 = MockApiClient().createBook(title: "T3", author: "A3", categories: "C3", publisher: "P3")
        subject.books = [book1, book2, book3]

        subject.deleteAll { (success) in
            XCTAssertFalse(success)
            XCTAssertTrue(self.subject.books.count == 3)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
}
