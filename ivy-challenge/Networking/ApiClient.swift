//
//  ApiClient.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

protocol ApiClientProtocol {
    func fetchBooks(_ completionHandler: @escaping (Result<[Book]>) -> Void)
    func addBook(author: String, title: String, categories: String, publisher: String, _ completionHandler: @escaping (Result<Book>) -> Void)
    func checkout(book: Book, by: String, _ completionHandler: @escaping (Result<Book>) -> Void)
    func delete(book: Book, _ completionHandler: @escaping (Bool) -> Void)
    func deleteAllBooks(_ completionHandler: @escaping (Bool) -> Void)
}

final class ApiClient: ApiClientProtocol {
    func fetchBooks(_ completionHandler: @escaping (Result<[Book]>) -> Void) {
        Api.request(method: .get, path: "/books").responseArray(completionHandler: { (response: DataResponse<[Book]>) in
            completionHandler(response.result)
        })
    }
    
    func addBook(author: String, title: String, categories: String, publisher: String, _ completionHandler: @escaping (Result<Book>) -> Void) {
        let params = ["author": author, "title": title, "categories": categories, "publisher": publisher]
        Api.request(method: .post, path: "/books", params: params).responseObject { (response) in
            completionHandler(response.result)
        }
    }
    
    func checkout(book: Book, by name: String, _ completionHandler: @escaping (Result<Book>) -> Void) {
        let params = ["lastCheckedOutBy": name]
        Api.request(method: .put, path: "/books/\(book.id)", params: params).responseObject { (response) in
            completionHandler(response.result)
        }
    }
    
    func delete(book: Book, _ completionHandler: @escaping (Bool) -> Void) {
        Api.request(method: .delete, path: "/books/\(book.id)").responseJSON { (response) in
            guard let statusCode = response.response?.statusCode else { completionHandler(false); return }
            completionHandler(statusCode >= 200 && statusCode <= 204)
        }
    }
    
    func deleteAllBooks(_ completionHandler: @escaping (Bool) -> Void) {
        Api.request(method: .delete, path: "/clean").responseJSON { (response) in
            guard let statusCode = response.response?.statusCode else { completionHandler(false); return }
            completionHandler(statusCode >= 200 && statusCode <= 204)
        }
    }
}

class Api {
    static let basePopularPostsUrl = "https://ivy-ios-challenge.herokuapp.com"
    
    class func request(method: HTTPMethod, path: String, params: Parameters? = nil) -> DataRequest {
        let url: String = "\(basePopularPostsUrl)\(path)"
        return Alamofire.request(url, method: method, parameters: params, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: nil)
    }
}
