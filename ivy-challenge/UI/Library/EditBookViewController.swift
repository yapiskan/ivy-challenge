//
//  EditBookViewController.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MBProgressHUD

final class EditBookViewController: BaseViewController {
    private let viewModel: LibraryViewModelProtocol
    private var book: Book?
    
    private let stackView = UIStackView()
    private let titleTextField = FloatingTextField()
    private let authorTextField = FloatingTextField()
    private let publisherTextField = FloatingTextField()
    private let tagsTextField = FloatingTextField()
    private let saveButton = LoadingButton()
    private let statusLabel = UILabel()
    
    private var canClose: Bool {
        return titleTextField.isEmpty &&
        publisherTextField.isEmpty &&
        authorTextField.isEmpty &&
        tagsTextField.isEmpty
    }
    
    private var isValid: Bool {
        return titleTextField.isValid &&
            publisherTextField.isValid &&
            authorTextField.isValid &&
            tagsTextField.isValid
    }
    
    init(viewModel: LibraryViewModelProtocol, router: AppRouter) {
        self.viewModel = viewModel
        
        super.init(router: router)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        title = "Add Book"
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        view .addSubview(stackView)
        
        titleTextField.placeholder = "Title"
        titleTextField.delegate = self
        titleTextField.returnKeyType = .next
        stackView.addArrangedSubview(titleTextField)
        
        authorTextField.placeholder = "Author"
        authorTextField.delegate = self
        authorTextField.returnKeyType = .next
        stackView.addArrangedSubview(authorTextField)
        
        publisherTextField.placeholder = "Publisher"
        publisherTextField.delegate = self
        publisherTextField.returnKeyType = .next
        stackView.addArrangedSubview(publisherTextField)
        
        tagsTextField.placeholder = "Tags"
        tagsTextField.delegate = self
        tagsTextField.returnKeyType = .join
        stackView.addArrangedSubview(tagsTextField)
        
        statusLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        stackView.addArrangedSubview(statusLabel)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.tintColor = .black
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        view.addSubview(saveButton)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        
		view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        if !didSetupConstraints {
            titleTextField.translatesAutoresizingMaskIntoConstraints = false
            authorTextField.translatesAutoresizingMaskIntoConstraints = false
            publisherTextField.translatesAutoresizingMaskIntoConstraints = false
            tagsTextField.translatesAutoresizingMaskIntoConstraints = false
            saveButton.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().inset(20)
                make.top.equalTo(view.safeAreaInsets.top + 20)
            })
        
            titleTextField.snp.makeConstraints({ (make) in
                make.height.equalTo(60)
            })
 			
            saveButton.snp.makeConstraints({ (make) in
                make.top.equalTo(stackView.snp.bottom).offset(20)
                make.width.equalTo(240)
                make.height.equalTo(40)
                make.centerX.equalToSuperview()
            })
            
            
        	didSetupConstraints = true
    	}
        
        super.updateViewConstraints()
    }
    
    private func resetUI() {
        titleTextField.clear()
        authorTextField.clear()
        publisherTextField.clear()
        tagsTextField.clear()
        
        titleTextField.becomeFirstResponder()
    }
    
    @objc
    private func saveButtonTapped() {
        if !isValid {
            router.alert(with: "Missing fields", message: "Please enter missing fields.", actions: [("OK", .cancel)])
            return
        }
        
        let title = titleTextField.trimmedText
        let publisher = publisherTextField.trimmedText
        let author = authorTextField.trimmedText
        let tags = tagsTextField.trimmedText
        
        saveButton.startLoading()
        viewModel.addBook(author: author, title: title, categories: tags, publisher: publisher) { [weak self] (book) in
            guard let strongSelf = self else { return }
            let success = book != nil
            DispatchQueue.main.async {
                strongSelf.saveButton.stopLoading()
                strongSelf.showHUD(text: success ? "Saved!" : "An error occurred")
                if success {
                    strongSelf.resetUI()
                }
            }
        }
    }
    
    @objc
    private func doneButtonTapped() {
        if canClose {
        	router.goBack()
        }
        else {
            router.alert(with: "Discard changes", message: "You will lose the entered data. Would you like to continue?", actions: [("Yes", .destructive), ("No", .cancel)]) { [unowned self] (success) in
                if success {
                    self.router.goBack()
                }
            }
        }
    }
    
    private func showHUD(text: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = text
        hud.hide(animated: true, afterDelay: 1.5)
    }
}

// MARK: UITextFieldDelegate
extension EditBookViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleTextField:
            authorTextField.becomeFirstResponder()
        case authorTextField:
            publisherTextField.becomeFirstResponder()
        case publisherTextField:
            tagsTextField.becomeFirstResponder()
        case tagsTextField:
            saveButton.sendActions(for: .touchUpInside)
            return true
        default:
            return false
        }
        
        return false
    }
}


