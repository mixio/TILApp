import FluentSQLite
//import FluentMySQL
//import FluentPostgreSQL
import Vapor
import Leaf
import JJTools
import Authentication

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

    // Register commands.
    var commandConfig = CommandConfig.default()
    try setupCommands(config: &commandConfig)
    services.register(commandConfig)

    /// Register middlewares.
    var middlewareConfig = MiddlewareConfig()
    try setupMiddlewares(config: &middlewareConfig)
    services.register(middlewareConfig)

    /// Register databases.
    var databasesConfig = DatabasesConfig()
    try setupDatabases(config: &databasesConfig, env: &env)
    services.register(databasesConfig)

    /// Register migrations
    var migrationConfig = MigrationConfig()
    try setupMigrations(config: &migrationConfig, env: &env)
    services.register(migrationConfig)

    // Leaf.
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    // Register Authentication.
    try services.register(AuthenticationProvider())

    // KeyedCache.
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)

    // Services
    services.register(JJService.self)

}
