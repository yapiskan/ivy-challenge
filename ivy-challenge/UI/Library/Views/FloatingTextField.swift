//
//  FloatingTextField.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/24/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class FloatingTextField: UITextField {
    private var titleLabel = UILabel()
    private var lineView = UIView()
    private var topConstraint: Constraint?
    
    override var placeholder: String? {
        didSet {
            titleLabel.text = placeholder?.uppercased()
        }
    }
    
    var isValid: Bool {
        guard let t = text else { return false }
        return t.trimmingCharacters(in: .whitespacesAndNewlines).count > 0
    }
    
    var isEmpty: Bool {
        guard let t = text else { return true }
        return t.trimmingCharacters(in: .whitespacesAndNewlines).count == 0
    }
    
    var trimmedText: String {
        guard let t = text else { return "" }
        return t.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTarget(self, action: #selector(didEditText), for: .editingChanged)
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.alpha = 0
        addSubview(titleLabel)
        
        lineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        addSubview(lineView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            topConstraint = make.centerY.equalToSuperview().offset(0).constraint
            make.height.equalTo(24)
        }
        
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func didEditText() {
        var alpha: CGFloat = 1
        var topMargin: CGFloat = -24
        if text?.count == 0 {
            alpha = 0
            topMargin = 0
        }
        
        topConstraint?.update(offset: topMargin)
        setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.titleLabel.alpha = alpha
        }
    }
    
    func clear() {
        text = nil
        didEditText()
    }
}
