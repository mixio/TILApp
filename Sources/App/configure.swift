import FluentSQLite
//import FluentMySQL
//import FluentPostgreSQL
import Vapor
import Leaf
import JJTools

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
        //try services.register(FluentMySQLProvider())
        break
    case .psql:
        //try services.register(FluentPostgreSQLProvider())
        break
    }

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Commands.
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)

    /// Register middleware
    var middlewares = MiddlewareConfig()    // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self)    // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self)   // Catches errors and converts to HTTP response
    services.register(middlewares)

    let dirConfig = DirectoryConfig.detect()

    //let path = FileManager.default.currentDirectoryPath

    var databases = DatabasesConfig()

    switch databaseType {
    case .sqlite:
        // let sqlite = try SQLiteDatabase(storage: .memory)
        let databaseFilepath: String
        if env == .testing {
            databaseFilepath = dirConfig.workDir + "SQLite/TILApp_test.sqlite"
        } else {
            databaseFilepath = dirConfig.workDir + "SQLite/TIlApp.sqlite"
        }
        jjprint(databaseFilepath)                // "/path/to/workdir/SQLite/databasefilename.sqlite"

        let sqlite = try SQLiteDatabase(storage: .file(path: databaseFilepath))
        databases.add(database: sqlite, as: .sqlite)
    case .mysql:
//        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
//        let username = Environment.get("DATABASE_USER") ?? "vapor"
//        let password = Environment.get("DATABASE_PASSWORD") ?? "password"
//
//        let databaseName: String
//        let databasePort: Int
//        if env == .testing {
//            databaseName = "vapor-test"
//            databasePort = 3306
//        } else {
//            databaseName = "vapor"
//            databasePort = 3307
//        }
//
//        let databaseConfig = MySQLDatabaseConfig(
//            hostname: hostname,
//            port: databasePort,
//            username: username,
//            password: password,
//            database: databaseName
//        )
//        let database = MySQLDatabase(config: databaseConfig)
//        databases.add(database: database, as: .mysql)
        break
    case .psql:
//        let hostname = Environment.get("DATABASE_HOSTNAME") ?? "localhost"
//        let username = Environment.get("DATABASE_USER") ?? "vapor"
//        let password = Environment.get("DATABASE_PASSWORD") ?? "password"
//
//        let databaseName: String
//        let databasePort: Int
//        if env == .testing {
//            databaseName = "vapor-test"
//            databasePort = 5433
//        } else {
//            databaseName = "vapor"
//            databasePort = 5432
//        }
//
//        let databaseConfig = PostgreSQLDatabaseConfig(
//            hostname: hostname,
//            port: databasePort,
//            username: username,
//            database: databaseName,
//            password: password
//        )
//        let database = PostgreSQLDatabase(config: databaseConfig)
//        databases.add(database: database, as: .psql)
        break
    }

    switch databaseType {
    case .sqlite:
        databases.enableLogging(on: .sqlite)
        databases.enableReferences(on: .sqlite)
    case .mysql:
        //databases.enableLogging(on: .mysql)
        break
    case .psql:
        //databases.enableLogging(on: .psql)
        break
    }

    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    switch databaseType {
    case .sqlite:
        migrations.add(model: User.self, database: .sqlite) // Order matters. User has to be before Acronym.
        migrations.add(model: Acronym.self, database: .sqlite)
        migrations.add(model: Category.self, database: .sqlite)
        migrations.add(model: AcronymCategoryPivot.self, database: .sqlite)
        migrations.add(model: Post.self, database: .sqlite)
        migrations.add(model: PostResponse.self, database: .sqlite)
    case .mysql:
        // migration.add(model: User.self, database: .mysql)
        // migrations.add(model: Acronym.self, database: .mysql)
        break
    case .psql:
        // migration.add(model: User.self, database: .psql)
        // migrations.add(model: Acronym.self, database: .psql)
        break
    }
    services.register(migrations)

    // Leaf.
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}
