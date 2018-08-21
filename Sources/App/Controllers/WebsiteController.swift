//
//  WebsiteController.swift
//  App
//
//  Created by jj on 16/08/2018.
//
import JJTools
import Foundation
import Vapor
import Leaf
import Fluent
import Authentication

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {

        let authRoutes = router.grouped(User.authSessionsMiddleware())

        authRoutes.get("login", use: loginHandler)
        authRoutes.get(use: getAcronymsHandler)
        authRoutes.get("acronyms", Acronym.parameter, use: getAcronymHandler)
        authRoutes.get("users", use: getUsersHandler)
        authRoutes.get("users", User.parameter, use: getUserHandler)
        authRoutes.get("categories", use: getCategoriesHandler)
        authRoutes.get("categories", Category.parameter, use: getCategoryHandler)

        authRoutes.post(LoginPostData.self, at: "login", use: postLoginHandler)
        authRoutes.post("logout", use: logoutHandler)

        let protectedRoutes = authRoutes.grouped(RedirectMiddleware<User>(path: "/login"))

        protectedRoutes.get("acronyms", "create", use: getCreateAcronymFormHandler)
        protectedRoutes.get("acronyms", Acronym.parameter, "edit", use: getEditAcronymFormHandler)

        protectedRoutes.post(CreateAcronymData.self, at: "acronyms", "create", use: postCreateAcronymFormHandler)
        protectedRoutes.post("acronyms", Acronym.parameter, "edit", use: postEditAcronymFormHandler)
        protectedRoutes.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)


    }

    // MARK: - login / logout

    func loginHandler(_ req: Request) throws -> Future<View> {
        struct Context: Encodable {
            let title = "Log in"
            let loginError: Bool
            init(loginError: Bool = false) {
                self.loginError = loginError
            }
        }
        let context: Context
        if req.query[Bool.self, at: "error"] != nil {
            context = Context(loginError: true)
        } else {
            context = Context()
        }
        return try req.view().render("login", context)
    }

    struct LoginPostData: Content {
        let username: String
        let password: String
    }

    func postLoginHandler(_ req: Request, userData: LoginPostData) throws -> Future<Response> {
        return User.authenticate(
            username: userData.username,
            password: userData.password,
            using: BCryptDigest(),
            on: req
            ).map(to: Response.self) { user in
                guard let user = user else {
                    return req.redirect(to: "login?error")
                }
                try req.authenticateSession(user)
                return req.redirect(to: "/")
        }
    }

    func logoutHandler(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/")
    }

    // MARK: - Acronym

    func getAcronymsHandler(_ req: Request) throws -> Future<View> {
        jjprint("getAcronymsHandler")
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            struct Context: Encodable {
                let title: String
                let acronyms: [Acronym]?
                let userLoggedIn: Bool
                let showCookieMessage: Bool
            }
            let userLoggedIn = try req.isAuthenticated(User.self)
            let showCookieMessage = req.http.cookies["cookies-accepted"] == nil
            let context = Context(title: "Homepage", acronyms: acronyms, userLoggedIn: userLoggedIn, showCookieMessage: showCookieMessage)
            return try req.view().render("acronyms", context)
        }
    }

    func getAcronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            return acronym.user.get(on: req).flatMap(to: View.self) { user in
                struct Context: Encodable {
                    let title: String
                    let acronym: Acronym
                    let user: User
                    let categories:Future<[Category]>
                    let csrfToken: String
                }
                let categories = try acronym.categories.query(on: req).all()
                let csrfToken = try CryptoRandom().generateData(count: 16).base64URLEncodedString()
                try req.session()["CSRF_TOKEN"] = csrfToken
                let context = Context(
                    title: acronym.short,
                    acronym: acronym,
                    user: user,
                    categories: categories,
                    csrfToken: csrfToken
                )
                return try req.view().render("acronym", context)
            }
        }
    }

    func getCreateAcronymFormHandler(_ req: Request) throws -> Future<View> {
        struct Context: Encodable {
            let title = "Create An Acronym"
            let usesSelect = true
            let csrfToken : String
        }
        let csrfToken = try CryptoRandom().generateData(count: 16).base64URLEncodedString()
        try req.session()["CSRF_TOKEN"] = csrfToken
        let context = Context(csrfToken: csrfToken)
        return try req.view().render("acronymForm", context)
    }

    struct CreateAcronymData: Content {
        let short: String
        let long: String
        let categories: [String]?
        let csrfToken: String
    }

    func postCreateAcronymFormHandler(_ req: Request, data: CreateAcronymData) throws -> Future<Response> {
        let expectedToken = try req.session()["CSRF_TOKEN"]
        try req.session()["CSRF_TOKEN"] = nil
        guard expectedToken == data.csrfToken else {
            throw Abort(.badRequest)
        }
        let user = try req.requireAuthenticated(User.self)
        let acronym = Acronym(short: data.short, long: data.long, userID: try user.requireID())
        return acronym.save(on: req).flatMap(to: Response.self) { acronym in
            guard let id = acronym.id else {
                throw Abort(.internalServerError)
            }
            var categorySaves: [Future<Void>] = []
            for category in data.categories ?? [] {
                try categorySaves.append(Category.addCategory(category, to: acronym, on: req))
            }
            let redirect = req.redirect(to: "/acronyms/\(id)")
            return categorySaves.flatten(on: req).transform(to: redirect)
        }
    }

    func getEditAcronymFormHandler(_ req: Request) throws -> Future<View> {
        struct Context: Encodable {
            let title = "Edit An Acronym"
            let acronym: Acronym
            let categories: Future<[Category]>
            let editing = true
            let usesSelect = true
            let csrfToken: String
        }
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            let categories = try acronym.categories.query(on: req).all()
            let csrfToken = try CryptoRandom().generateData(count: 16).base64URLEncodedString()
            try req.session()["CSRF_TOKEN"] = csrfToken
            let context = Context(acronym: acronym, categories: categories, csrfToken: csrfToken)
            return try req.view().render("acronymForm", context)
        }
    }

    func postEditAcronymFormHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(
            to: Response.self,
            req.parameters.next(Acronym.self),
            req.content.decode(CreateAcronymData.self)
        ) { acronym, data in
            let expectedToken = try req.session()["CSRF_TOKEN"]
            try req.session()["CSRF_TOKEN"] = nil
            guard expectedToken == data.csrfToken else {
                throw Abort(.badRequest)
            }
            let user = try req.requireAuthenticated(User.self)
            acronym.short = data.short
            acronym.long = data.long
            acronym.userID = try user.requireID()
            return acronym.save(on: req).flatMap(to: Response.self) { savedAcronym in
                guard let id = savedAcronym.id else {
                    throw Abort(.internalServerError)
                }
                return try acronym.categories.query(on: req).all().flatMap(to:Response.self) { existingCategories in
                    let existingStringArray = existingCategories.map { $0.name }
                    let existingSet = Set<String>(existingStringArray)
                    let newSet = Set<String>(data.categories ?? [])
                    let categoriesToAdd = newSet.subtracting(existingSet)
                    let categoriesToRemove = existingSet.subtracting(newSet)
                    var categoryResults: [Future<Void>] = []
                    for newCategory in categoriesToAdd {
                        categoryResults.append(try Category.addCategory(newCategory, to: acronym, on: req))
                    }
                    for categoryNameToRemove in categoriesToRemove {
                        let categoryToRemove = existingCategories.first {
                            $0.name == categoryNameToRemove
                        }
                        if let category = categoryToRemove {
                            categoryResults.append(acronym.categories.detach(category, on: req))
                        }
                    }
                    return categoryResults.flatten(on: req).transform(to: req.redirect(to: "/acronyms/\(id)"))
                }
            }
        }
    }

    func deleteAcronymHandler(_ req: Request) throws -> Future<Response> {
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: req.redirect(to: "/"))
    }

    // MARK: - User
    func getUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            struct Context: Encodable {
                let title: String
                let users: [User]?
            }
            let context = Context(title: "Users", users: users.isEmpty ? nil : users)
            return try req.view().render("users", context)
        }
    }

    func getUserHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            return try user.acronyms.query(on: req).all().flatMap(to: View.self) { acronyms in
                struct Context: Encodable {
                    let title: String
                    let acronyms: [Acronym]?
                    let user: User
                }
                let context = Context(title: user.name, acronyms: acronyms.isEmpty ? nil : acronyms, user: user)
                return try req.view().render("user", context)
            }
        }
    }

    // MARK: - Category
    func getCategoriesHandler(_ req: Request) throws -> Future<View> {
        struct Context: Encodable {
            let title: String
            let categories: Future<[Category]>
        }
        let categories = Category.query(on: req).all() // Leaf knows how to handle futures.
        let context = Context(title: "Categories", categories: categories)
        return try req.view().render("categories", context)
    }

    func getCategoryHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Category.self).flatMap(to: View.self) { category in
            struct Context: Encodable {
                let title: String
                let category: Category
                let acronyms: Future<[Acronym]>
            }
            let acronyms =  try category.acronyms.query(on: req).all()
            let context = Context(title: category.name, category: category, acronyms: acronyms)
            return try req.view().render("category", context)
        }
    }

}

