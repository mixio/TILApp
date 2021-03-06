import Vapor
//<sqlite>
import FluentSQLite
//<mysql> import FluentMySQL
//<psql> import FluentPostgreSQL

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    var userID: User.ID

    init(short: String, long: String, userID: User.ID) {
        self.short = short
        self.long = long
        self.userID = userID
    }
}

extension Acronym {
    var user: Parent<Acronym, User> {
        return parent(\.userID)
    }
    var categories: Siblings<Acronym, Category, AcronymCategoryPivot> {
        return siblings()  
    }
}

/*<sqlite>*/
/// https://api.vapor.codes/fluent-sqlite/latest/FluentSQLite/Protocols/SQLiteModel.html
/// public protocol SQLiteModel : _SQLiteModel where Self.ID == Int
/// https://api.vapor.codes/fluent-sqlite/latest/FluentSQLite/Protocols.html#/s:12FluentSQLite01_B5ModelP
/// public protocol _SQLiteModel : Model, SQLiteTable where Self.Database == SQLiteDatabase
/// https://api.vapor.codes/fluent/latest/Fluent/Protocols/Model.html
/// public protocol Model : Reflectable, AnyModel
/// A SQLite database model. See Fluent.Model.
extension Acronym: SQLiteModel { }

/*<mysql>
 extension Acronym: MySQLModel { }
 */
/*<psql>
 extension Acronym: PostgreSQLModel { }
 */

/// https://api.vapor.codes/vapor/latest/Vapor/Protocols/Content.html
/// public protocol Content: Codable, ResponseCodable, RequestCodable
/// Convertible to / from content in an HTTP message.
extension Acronym: Content { }

/// https://api.vapor.codes/routing/latest/Routing/Protocols/Parameter.html
/// public protocol Parameter
/// A type that is capable of being used as a dynamic route parameter.
extension Acronym: Parameter { }

/// https://api.vapor.codes/fluent/latest/Fluent/Protocols/Migration.html
/// public protocol Migration : AnyMigration
/// Types conforming to this protocol can be registered with MigrationConfig to
/// prepare the database before your application runs.
extension Acronym: Migration {
    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

