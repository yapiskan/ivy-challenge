//
//  App.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation

final class App {
    private var injector = Injector()
    var router: AppRouter
    
    init() {
        router = injector.container.resolve(AppRouter.self)!
        router.injector = injector
    }
}
