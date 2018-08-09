import Vapor
import FluentSQLite

final class Acronym: Codable {
    var id: Int?
    var short: String
    var long: String
    init(short: String, long: String) {
        self.short = short
        self.long = long
    }
}

/// https://api.vapor.codes/fluent-sqlite/latest/FluentSQLite/Protocols/SQLiteModel.html
/// public protocol SQLiteModel : _SQLiteModel where Self.ID == Int
/// https://api.vapor.codes/fluent-sqlite/latest/FluentSQLite/Protocols.html#/s:12FluentSQLite01_B5ModelP
/// public protocol _SQLiteModel : Model, SQLiteTable where Self.Database == SQLiteDatabase
/// https://api.vapor.codes/fluent/latest/Fluent/Protocols/Model.html
/// public protocol Model : Reflectable, AnyModel
/// A SQLite database model. See Fluent.Model.
extension Acronym: SQLiteModel { }

/// https://api.vapor.codes/fluent/latest/Fluent/Protocols/Migration.html
/// public protocol Migration : AnyMigration
/// Types conforming to this protocol can be registered with MigrationConfig to
/// prepare the database before your application runs.
extension Acronym: Migration { }

/// https://api.vapor.codes/vapor/latest/Vapor/Protocols/Content.html
/// public protocol Content: Codable, ResponseCodable, RequestCodable
/// Convertible to / from content in an HTTP message.
extension Acronym: Content { }
