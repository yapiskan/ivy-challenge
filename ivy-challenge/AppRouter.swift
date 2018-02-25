//
//  AppDelegate.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import Swinject

final class AppRouter {
    var injector: Injector!
    private var navigationController: UINavigationController?
    
	var window: UIWindow {
		let window = UIWindow(frame: UIScreen.main.bounds)
		window.backgroundColor = UIColor.white
		window.rootViewController = entryViewController
		window.makeKeyAndVisible()
		
		return window
	}
    
	var entryViewController: UINavigationController {
		navigationController = UINavigationController(rootViewController: injector.container.resolve(BooksViewController.self)!)
        
        return navigationController!
	}
	
    func navigate(screen: Screens) {
        if let vc = resolveViewController(for: screen) {
        	navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func alert(with title: String? = nil, message: String, actions: [(String, UIAlertActionStyle)] = [("OK", .default)], _ completion: ((Bool) -> ())? = nil) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (i, action) in actions.enumerated() {
            avc.addAction(UIAlertAction(title: action.0, style: action.1, handler: { (action) in
                completion?(i == 0)
            }))
        }
        
        navigationController?.present(avc, animated: true, completion: nil)
    }
    
    func prompt(with title: String? = nil, message: String, placeholders:[String], actions: [(String, UIAlertActionStyle)], _ completion: ((Bool, [String?]?) -> ())? = nil) {
        let avc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for placeholder in placeholders {
            avc.addTextField { (tf) in
                tf.placeholder = placeholder
            }
        }
        
        for (i, action) in actions.enumerated() {
            avc.addAction(UIAlertAction(title: action.0, style: action.1, handler: { (action) in
                let info = avc.textFields?.map({ (tf) -> String? in
                    return tf.text
                })
                
                completion?(i == 0, info)
            }))
        }
    
        navigationController?.present(avc, animated: true, completion: nil)
    }
    
    private func resolveViewController(for screen: Screens) -> BaseViewController? {
        switch screen {
        case .books:
            return injector.container.resolve(BooksViewController.self)!
        case .bookDetail(let book, let viewModel):
            let vc = injector.container.resolve(BookDetailViewController.self, arguments: book, viewModel)!
            return vc
        case .editBook(_):
            return injector.container.resolve(EditBookViewController.self)!
        case .addBook(let viewModel):
            return injector.container.resolve(EditBookViewController.self, argument: viewModel)!
        }
    }
}

enum Screens {
    case books
    case bookDetail(book: Book, viewModel: LibraryViewModelProtocol?)
    case editBook(book: Book)
    case addBook(viewModel: LibraryViewModelProtocol?)
}
