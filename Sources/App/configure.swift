import FluentSQLite
import FluentMySQL
import FluentPostgreSQL
import Vapor

enum DatabaseType {
    case sqlite
    case mysql
    case psql
}

var databaseType: DatabaseType = .sqlite

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    switch databaseType {
    case .sqlite:
        try services.register(FluentSQLiteProvider())
    case .mysql:
        try services.register(FluentMySQLProvider())
    case .psql:
        try services.register(FluentPostgreSQLProvider())
    }

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    let dirConfig = DirectoryConfig.detect()
    print(dirConfig.workDir) // "/path/to/workdir"

    //let path = FileManager.default.currentDirectoryPath

    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"

    var databases = DatabasesConfig()

    switch databaseType {
    case .sqlite:
        // let sqlite = try SQLiteDatabase(storage: .memory)
        let sqlite = try SQLiteDatabase(storage: .file(path: dirConfig.workDir + "acronyms.sqlite"))
        databases.add(database: sqlite, as: .sqlite)
    case .mysql:
        /// Register the configured MySQL database to the database config.
        let databaseConfig = MySQLDatabaseConfig(
            hostname: "localhost",
            username: "vapor",
            password: "password",
            database: "vapor"
        )
        let database = MySQLDatabase(config: databaseConfig)
        databases.add(database: database, as: .mysql)
    case .psql:
        let databaseConfig = PostgreSQLDatabaseConfig(
            hostname: hostname,
            username: username,
            database: databaseName,
            password: password
        )
        let database = PostgreSQLDatabase(config: databaseConfig)
        databases.add(database: database, as: .psql)
    }

    if env != .testing {
        switch databaseType {
        case .sqlite:
            databases.enableLogging(on: .sqlite)
        case .mysql:
            databases.enableLogging(on: .mysql)
        case .psql:
            databases.enableLogging(on: .psql)
        }
    }

    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    //<sqlite>
    switch databaseType {
    case .sqlite:
        migrations.add(model: Acronym.self, database: .sqlite)
    case .mysql:
        //migrations.add(model: Acronym.self, database: .mysql)
        break
    case .psql:
        //migrations.add(model: Acronym.self, database: .psql)
        break
    }
    services.register(migrations)

}
