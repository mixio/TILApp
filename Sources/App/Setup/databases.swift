//
//  databases.swift
//  App
//
//  Created by jj on 28/09/2018.
//

import JJTools
import FluentSQLite
//import FluentMySQL
//import FluentPostgreSQL

public func setupDatabases(config: inout DatabasesConfig, env: inout Environment) throws {

    let dirConfig = DirectoryConfig.detect()
    //let path = FileManager.default.currentDirectoryPath

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
        config.add(database: sqlite, as: .sqlite)
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
        //        config.add(database: database, as: .mysql)
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
        //        config.add(database: database, as: .psql)
        break
    }

    switch databaseType {
    case .sqlite:
        config.enableLogging(on: .sqlite)
        config.enableReferences(on: .sqlite)
    case .mysql:
        //config.enableLogging(on: .mysql)
        break
    case .psql:
        //config.enableLogging(on: .psql)
        break
    }

}
