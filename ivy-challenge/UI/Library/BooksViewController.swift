//
//  BooksViewController.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import SnapKit

final class BooksViewController: BaseViewController {
    private var viewModel: LibraryViewModelProtocol
    
    private var tableView = UITableView()
    private var refreshControl = UIRefreshControl()

    init(viewModel: LibraryViewModelProtocol, router: AppRouter) {
        self.viewModel = viewModel
        
        super.init(router: router)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        title = "Books"
        
        tableView.register(BookCell.self, forCellReuseIdentifier: BookCell.kIdentifier)
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBookTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Delete All", style: .done, target: self, action: #selector(deleteAllTapped))
        
        setupConstraints()
        refreshControl.beginRefreshing()
        refresh()
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc
    private func refresh() {
        viewModel.fetchBooks(refresh: true, onDataUpdate(_:))
    }
    
    @objc
    private func addBookTapped() {
        router.navigate(screen: .addBook(viewModel: viewModel))
    }
    
    @objc
    private func deleteAllTapped() {
        router.alert(with: "Delete All", message: "Are you sure to delete all books?", actions: [("Yes", .destructive), ("No", .default)]) { [unowned self] (success) in
            if success {
                self.viewModel.deleteAll() { [weak self] success in
                    guard let strongSelf = self else { return }
                    if !success {
                        strongSelf.router.alert(message: "An error occurred while deleting books")
                    }
                }
            }
        }
    }
    
    private func onDataUpdate(_ success: Bool) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func delete(book: Book, atIndex index: Int) {
        viewModel.delete(book: book) { [weak self] success in
            guard let strongSelf = self else { return }
            if !success {
                strongSelf.router.alert(message: "An error occurred while deleting books")
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                strongSelf.tableView.endUpdates()
            }
        }
    }
}

extension BooksViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let book = viewModel.books[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        router.navigate(screen: .bookDetail(book: book, viewModel: viewModel))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    	let cell = tableView.dequeueReusableCell(withIdentifier: BookCell.kIdentifier, for: indexPath) as! BookCell
        
        let book = viewModel.books[indexPath.row]
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.author
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.books.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let book = viewModel.books[indexPath.row]
        if editingStyle == .delete {
            delete(book: book, atIndex: indexPath.row)
        }
    }
}


