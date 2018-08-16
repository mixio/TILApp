import Vapor
import Fluent
import FluentSQL

/// Register your application's routes here.
public func routes(_ router: Router) throws {

    let acronymsController = AcronymsController()
    try router.register(collection: acronymsController)

    let usersController = UsersController()
    try router.register(collection: usersController)

    let categoriesController = CategoriesController()
    try router.register(collection: categoriesController)

    let postsController = PostsController()
    try router.register(collection: postsController)

    let postResponsesController = PostResponsesController()
    try router.register(collection: postResponsesController)


    router.get("sqlite", "version") { req in
        return req.withPooledConnection(to: .sqlite) { conn in
            return conn.select()
                .column(function: "sqlite_version", as: "version")
                .all(decoding: SQLiteVersion.self)
            }.map { rows in
                return rows[0].version
        }
    }

}
