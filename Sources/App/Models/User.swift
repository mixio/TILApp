//
//  User.swift
//  App
//
//  Created by jj on 11/08/2018.
//

import Foundation
import Vapor
import FluentSQLite
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    var twitterURL: String?

    init(name: String, username: String, password: String, twitterURL: String? = nil) {
        self.name = name
        self.username = username
        self.password = password
        self.twitterURL = twitterURL
    }

}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.userID)
    }
    var posts: Children<User, Post> {
        return children(\.userID)
    }
}

// MARK: - Migration
extension User: Migration {
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            // Hand pick the initial fields to build.
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.name)
            builder.field(for: \.username)
            builder.field(for: \.password)
            // field \.twitterURL will be built by a later migration.
            builder.unique(on: \.username)
        }
    }
}

extension User: SQLiteUUIDModel { }

/// Conformance to protocol Parameter allows
/// the type to be used as dynamic route parameter.
extension User: Parameter { }

/// Conformance to protocol Content allows
/// encoding/decoding from http messages.
extension User: Content { }

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable { }
extension User: SessionAuthenticatable { }

// MARK: - Public

extension User {

    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        var twitterURL: String?
        init(id: UUID?, name: String, username: String, twitterURL: String? = nil) {
            self.id = id
            self.name = name
            self.username = username
            self.twitterURL = twitterURL
        }
    }

    func convertToPublic() -> User.Public {
        return User.Public(id: id, name: name, username: username, twitterURL: twitterURL)
    }

}

extension User.Public: Content { }

extension Future where T: User {

    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
    
}

// MARK - Admin user

struct AdminUser: Migration {
    typealias Database = SQLiteDatabase

    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        let password = try? BCrypt.hash("password")
        guard let hashedPassword = password else {
            fatalError("Failed to create admin user")
        }
        let user = User(name: "Admin", username: "admin", password: hashedPassword)
        return user.save(on: connection).transform(to: ())
    }

    static func revert(on connection: SQLiteConnection) -> Future<Void> {
        return .done(on: connection)
    }
}
