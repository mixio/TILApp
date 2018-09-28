//
//  migrations.swift
//  App
//
//  Created by jj on 26/09/2018.
//

import Vapor
import FluentSQLite
//import FluentMySQL
//import FluentPostgreSQL

public func setupMigrations(config: inout MigrationConfig, env: inout Environment) throws {
    switch databaseType {
    case .sqlite:
        config.add(model: User.self, database: .sqlite) // Order matters. User has to be before Acronym.
        config.add(model: Acronym.self, database: .sqlite)
        config.add(model: Category.self, database: .sqlite)
        config.add(model: AcronymCategoryPivot.self, database: .sqlite)
        config.add(model: Post.self, database: .sqlite)
        config.add(model: PostResponse.self, database: .sqlite)
        config.add(model: Token.self, database: .sqlite)
        switch env {
        case .development, .testing:
            config.add(migration: AdminUser.self, database: .sqlite)
        default:
            break
        }
        config.add(migration: AddTwitterURLToUser.self, database: .sqlite)
    //config.add(migration: MakeCategoriesUnique.self, database: .sqlite)
    case .mysql:
        // config.add(model: User.self, database: .mysql)
        // config.add(model: Acronym.self, database: .mysql)
        break
    case .psql:
        // config.add(model: User.self, database: .psql)
        // config.add(model: Acronym.self, database: .psql)
        break
    }
}
