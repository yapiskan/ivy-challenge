//
//  BookCell.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/24/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class BookCell: BaseTableViewCell {
    static let kIdentifier = "BookCell"
    let titleLabel = UILabel()
    let authorLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contentView.addSubview(titleLabel)
        
        authorLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)
        contentView.addSubview(authorLabel)
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(10)
            make.top.equalTo(10)
        }
        
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}
