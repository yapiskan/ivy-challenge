//
//  Book.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/23/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import ObjectMapper

let kDateFormat = "yyyy-MM-dd HH:mm:ss zzz"

final class Book: ImmutableMappable {
    var id: Int
    var title: String
    var author: String
    var publisher: String
    var categories: String
    var lastCheckedOut: Date?
    var lastCheckedOutBy: String?
    
    required init(map: Map) throws {
        id = try map.value("id")
        title = try map.value("title")
        author = try map.value("author")
        publisher = try map.value("publisher")
        categories = try map.value("categories")
        lastCheckedOut = try? map.value("lastCheckedOut", using: CustomDateFormatTransform(formatString: kDateFormat))
        lastCheckedOutBy = try? map.value("lastCheckedOutBy")
    }
    
    func mapping(map: Map) {
        id >>> map["id"]
        title >>> map["title"]
        author >>> map["author"]
        publisher >>> map["publisher"]
        categories >>> map["categories"]
        lastCheckedOut >>> map["lastCheckedOut"]
        lastCheckedOutBy >>> map["lastCheckedOutBy"]
    }
}

