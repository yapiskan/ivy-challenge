//
//  LibraryViewModel.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation

protocol LibraryViewModelProtocol {
    var books: [Book] {get set}
    
    func fetchBooks(refresh: Bool, _ completion: ((Bool) -> ())?)
    func addBook(author: String, title: String, categories: String, publisher: String, _ completion: @escaping (Book?) -> ())
    func checkout(book: Book, by: String, _ completion: @escaping (Book?) -> ())
    func delete(book: Book, _ completion: @escaping (Bool) -> ())
    func deleteAll(_ completion: @escaping (Bool) -> ())
}

final class LibraryViewModel: LibraryViewModelProtocol {
    private var api: ApiClientProtocol
    private var isLoading = false
    private var onUpdate: ((Bool) -> ())?
    
    var books = [Book]()
    
    init(apiClient: ApiClientProtocol) {
        api = apiClient
    }
    
    func fetchBooks(refresh: Bool = true, _ completion: ((Bool)-> ())? = nil) {
        if isLoading {
            return
        }
        
        let isRefreshing = refresh
        if let onUpdateCallback = completion {
        	onUpdate = onUpdateCallback
        }
        
        isLoading = true
        api.fetchBooks { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            
            switch result {
            case .success(let data):
                if isRefreshing {
                    strongSelf.books.removeAll()
                }
                
                strongSelf.books.append(contentsOf: data)
                strongSelf.onUpdate?(true)
            case .failure(let error):
                print("failed fetch \(error.localizedDescription)")
                strongSelf.onUpdate?(false)
            }
        }
    }
    
    func addBook(author: String, title: String, categories: String, publisher: String, _ completion: @escaping (Book?) -> ()) {
        api.addBook(author: author, title: title, categories: categories, publisher: publisher) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let data):
                let book = data
                strongSelf.books.append(book)
                completion(book)
                strongSelf.onUpdate?(true)
            case .failure(let error):
                print("failed add \(error.localizedDescription)")
                completion(nil)
                strongSelf.onUpdate?(false)
            }
        }
    }
    
    func checkout(book: Book, by: String, _ completion: @escaping (Book?) -> ()) {
        api.checkout(book: book, by: by) { [weak self] (result) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let data):
                let book = data
                if let bookInStore = strongSelf.books.first(where: { $0.id == book.id }) {
                	bookInStore.lastCheckedOut = book.lastCheckedOut
                    bookInStore.lastCheckedOutBy = book.lastCheckedOutBy
                }
                
                completion(book)
                strongSelf.onUpdate?(true)
            case .failure(let error):
                print("failed checkout \(error.localizedDescription)")
                completion(nil)
                strongSelf.onUpdate?(false)
            }
        }
    }
    
    func delete(book: Book, _ completion: @escaping (Bool) -> ()) {
        let index = books.index(where: { $0.id == book.id })
        books.remove(at: index!)
        
        api.delete(book: book) { [weak self] (success) in
            guard let strongSelf = self else { return }
            
            if !success {
                strongSelf.books.insert(book, at: index!)
                strongSelf.onUpdate?(true)
            }
            
            completion(success)
        }
    }
    
    func deleteAll(_ completion: @escaping (Bool) -> ()) {
        api.deleteAllBooks() { [weak self] (success) in
            guard let strongSelf = self else { return }
            
            if success {
            	strongSelf.books.removeAll()
                strongSelf.onUpdate?(success)
            }
            
            completion(success)
        }
    }
}
