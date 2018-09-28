//
//  20180822-103701-MakeCategoriesUnique.swift
//  App
//
//  Created by jj on 22/08/2018.
//

import FluentSQLite
import Vapor

struct MakeCategoriesUnique: Migration {
    typealias Database = SQLiteDatabase
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.update(Category.self, on: connection) { builder in
            builder.unique(on: \.name)
        }
    }
    static func revert(on connection: SQLiteConnection) -> Future<Void> {
        return Database.update(Category.self, on: connection) { builder in
            builder.deleteUnique(from: \.name)
        }
    }
}
