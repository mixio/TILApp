@testable import App
import FluentSQLite

extension User {
    static func create(
        name: String = "Luke",
        username: String = "luke",
        on connection: SQLiteConnection
        ) throws -> User {
        let user = User(name: name, username: username)
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

