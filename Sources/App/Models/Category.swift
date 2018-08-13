//
//  Category.swift
//  App
//
//  Created by jj on 12/08/2018.
//

import Vapor
import FluentSQLite

final class Category: Codable {
    var id: Int?
    var name: String
    var description: String?
    
    init(name: String) {
        self.name = name
    }
}

extension Category: SQLiteModel { }
extension Category: Migration { }
extension Category: Parameter { }
extension Category: Content { }

extension Category {
    var acronyms: Siblings<Category, Acronym, AcronymCategoryPivot> {
        return siblings()
    }
}
