//
//  User.swift
//  App
//
//  Created by jj on 11/08/2018.
//

import Foundation
import Vapor
//import  FluentPostgreSQL
import FluentSQLite

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String

    init(name: String, username: String) {
        self.name = name
        self.username = username
    }
}

//    extensions User: PostgreSQLUUIDModel { }
extension User: SQLiteUUIDModel { }

extension User: Content { }
extension User: Migration { }
extension User: Parameter { }
