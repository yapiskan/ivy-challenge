//
//  BaseViewController.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    var didSetupConstraints = false
    var router: AppRouter
    
    init(router: AppRouter) {
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
    }
}

class BaseView: UIView {
    var didSetupConstraints = false
}

class BaseTableViewCell: UITableViewCell {
    var didSetupConstraints = false
}
