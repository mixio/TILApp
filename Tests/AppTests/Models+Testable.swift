@testable import App
import FluentSQLite
import Crypto

extension User {
    static func create(name: String = "Luke", username: String? = nil, on connection: SQLiteConnection) throws -> User {
        var createdUsername: String
        if let suppliedUsername = username {
            createdUsername = suppliedUsername
        } else {
            createdUsername = UUID().uuidString
        }
        let password = try BCrypt.hash("password")
        let user = User(name: name, username: createdUsername, password: password)
        return try user.save(on: connection).wait()
    }
}

extension Acronym {
    static func create(
        short: String = "TIL",
        long: String = "Today I Learned",
        user: User? = nil,
        on connection: SQLiteConnection
        ) throws -> Acronym {
        var acronymsUser = user

        if acronymsUser == nil {
            acronymsUser = try User.create(on: connection)
        }
        let acronym = Acronym(
            short: short,
            long: long,
            userID: acronymsUser!.id!
        )
        return try acronym.save(on: connection).wait()
    }
}

extension App.Category {
    static func create(
        name: String = "Random",
        on connection: SQLiteConnection
        ) throws -> App.Category {
        let category = Category(name: name)
        return try category.save(on: connection).wait()
    }
}

