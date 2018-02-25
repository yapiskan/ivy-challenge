//
//  Injector.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import Swinject

final class Injector {
    let container: Container = {
        let container = Container()
        
        // AppRouter
        container.register(AppRouter.self) { _ in AppRouter() }.inObjectScope(.container)
        
        // Api
        container.register(ApiClientProtocol.self) { _ in ApiClient() }
        // View Models
        container.register(LibraryViewModelProtocol.self) { r in
            LibraryViewModel(apiClient: r.resolve(ApiClientProtocol.self)!)
        }
        // View Controllers
        container.register(BooksViewController.self) { r in
            var vc = BooksViewController(viewModel: r.resolve(LibraryViewModelProtocol.self)!, router: r.resolve(AppRouter.self)!)
            return vc
        }
        
        container.register(BookDetailViewController.self) { (r, book: Book, viewModel: LibraryViewModelProtocol?) in
            let vm = viewModel ?? r.resolve(LibraryViewModelProtocol.self)!
            var vc = BookDetailViewController(viewModel: vm, router:
                r.resolve(AppRouter.self)!, book: book)
            return vc
        }
        
        container.register(EditBookViewController.self) { (r, viewModel: LibraryViewModelProtocol?) in
            let vm = viewModel ?? r.resolve(LibraryViewModelProtocol.self)!
            var vc = EditBookViewController(viewModel: vm, router: r.resolve(AppRouter.self)!)
            return vc
        }
        
        return container
    }()
}
