//<sqlite> import FluentSQLite
//<mysql> import FluentMySQL
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    //<sqlite> try services.register(FluentSQLiteProvider())
    //<mysql> try services.register(FluentMySQLProvider())
    try services.register(FluentPostgreSQLProvider())

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

    //<sqlite> Configure a SQLite database
    //<sqlite> let sqlite = try SQLiteDatabase(storage: .memory)

    var databases = DatabasesConfig()

    //<sqlite> /// Register the configured SQLite database to the database config.
    //<sqlite> let sqlite = try SQLiteDatabase(storage: .file(path: dirConfig.workDir + "acronyms.sqlite"))
    //<sqlite> databases.add(database: sqlite, as: .sqlite)

    //<mysql> /// Register the configured MySQL database to the database config.
    //<mysql> let databaseConfig = MySQLDatabaseConfig(
    //<mysql>     hostname: "localhost",
    //<mysql>     username: "vapor",
    //<mysql>     password: "password",
    //<mysql>     database: "vapor"
    //<mysql> )
    //<mysql> let database = MySQLDatabase(config: databaseConfig)
    //<mysql> databases.add(database: database, as: .mysql)

    let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
    let username = Environment.get("DATABASE_USER") ?? "vapor"
    let databaseName = Environment.get("DATABASE_DB") ?? "vapor"
    let password = Environment.get("DATABASE_PASSWORD") ?? "password"

    let databaseConfig = PostgreSQLDatabaseConfig(
        hostname: hostname,
        username: username,
        database: databaseName,
        password: password
    )
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)

    if env != .testing {
        //<sqlite> databases.enableLogging(on: .sqlite)
        //<mysql> databases.enableLogging(on: .mysql)
        databases.enableLogging(on: .psql)
    }

    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    //<sqlite> migrations.add(model: Acronym.self, database: .sqlite)
    //<mysql> migrations.add(model: Acronym.self, database: .mysql)
    migrations.add(model: Acronym.self, database: .psql)
    services.register(migrations)

}
