//
//  BookDetailViewController.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit

final class BookDetailViewController: BaseViewController {
    private let viewModel: LibraryViewModelProtocol
    private var book: Book
    
    fileprivate let titleLabel = UILabel()
    fileprivate let authorLabel = UILabel()
    fileprivate let publisherLabel = UILabel()
    fileprivate let tagsLabel = UILabel()
    fileprivate let lastCheckoutByLabel = UILabel()
    fileprivate let checkoutButton = LoadingButton()
    
    init(viewModel: LibraryViewModelProtocol, router: AppRouter, book: Book) {
        self.viewModel = viewModel
        self.book = book
        
        super.init(router: router)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        view.addSubview(titleLabel)
        
        authorLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.addSubview(authorLabel)
        
        publisherLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        view.addSubview(publisherLabel)
        
        tagsLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        view.addSubview(tagsLabel)
        
        lastCheckoutByLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lastCheckoutByLabel.numberOfLines = 2
        view.addSubview(lastCheckoutByLabel)
        
        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.tintColor = .black
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        view.addSubview(checkoutButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(shareButtonTapped))
        view.setNeedsUpdateConstraints()
        
        title = book.title
        bindData()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            titleLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(20)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(view.safeAreaInsets.top + 20)
            }
            
            authorLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(20)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(titleLabel.snp.bottom)
            }
            
            publisherLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(20)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(authorLabel.snp.bottom).offset(5)
            }
            
            tagsLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(20)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(publisherLabel.snp.bottom).offset(5)
            }
            
            lastCheckoutByLabel.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(20)
                make.left.equalToSuperview().offset(20)
                make.top.equalTo(tagsLabel.snp.bottom).offset(5)
            }
            
            checkoutButton.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(20)
                make.left.equalToSuperview().offset(20)
                make.height.equalTo(40)
                make.top.equalTo(lastCheckoutByLabel.snp.bottom).offset(20)
            }
            
            didSetupConstraints = true
        }
	
        super.updateViewConstraints()
    }
    
    private func bindData() {
        titleLabel.text = "\(book.title)"
        authorLabel.text = "\(book.author)"
        publisherLabel.text = "Publisher: \(book.publisher)"
        tagsLabel.text = "Tags: \(book.categories)"
        if let name = book.lastCheckedOutBy, let date = book.lastCheckedOut {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM, dd YYYY hh:mm a"
            let formattedDate = formatter.string(from: date)
        	lastCheckoutByLabel.text = "Last Checked Out:\n\(name) @ \(formattedDate)"
            checkoutButton.isHidden = true
        }
        else {
            lastCheckoutByLabel.text = ""
            checkoutButton.isHidden = false
        }
    }
    
    @objc
    private func checkoutTapped() {
        showCheckoutView { [weak self] (name) in
            guard let person = name else { return }
            guard let strongSelf = self else { return }
            
            strongSelf.checkoutButton.startLoading()
            strongSelf.viewModel.checkout(book: strongSelf.book, by: person) { [weak self] (book) in
                guard let strongSelf = self else { return }
                
                if let b = book {
                    strongSelf.book = b
                    DispatchQueue.main.async {
                        strongSelf.checkoutButton.stopLoading()
                        strongSelf.bindData()
                    }
                }
                else {
                    strongSelf.router.alert(message: "An error occurred while checking out the book", actions: [("OK", .default)])
                    DispatchQueue.main.async {
                        strongSelf.checkoutButton.stopLoading()
                    }
                }
            }
        }
    }
    
    @objc
    private func shareButtonTapped() {
        let items = [book.title, "by \(book.author)", "from \(book.publisher)"]
        let avc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(avc, animated: true, completion: nil)
    }
    
    private func showCheckoutView(_ completion: @escaping (String?) -> ()) {
        router.prompt(with: "Checkout the book", message: "Who is checking out?", placeholders: ["Name"], actions: [("OK", .default), ("Cancel", .destructive)]) { (success, info) in
            if success, let name = info?.first??.trimmingCharacters(in: .whitespaces), name.count > 0 {
                completion(name)
            }
        }
    }
}


