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

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: getAcronymsHandler)
        router.get("acronyms", Acronym.parameter, use: getAcronymHandler)
        router.get("acronyms", "create", use: getCreateAcronymFormHandler)
        router.get("acronyms", Acronym.parameter, "edit", use: getEditAcronymFormHandler)
        router.get("users", use: getUsersHandler)
        router.get("users", User.parameter, use: getUserHandler)
        router.get("categories", use: getCategoriesHandler)
        router.get("categories", Category.parameter, use: getCategoryHandler)

        router.post(Acronym.self, at: "acronyms", "create", use: postCreateAcronymFormHandler)
        router.post("acronyms", Acronym.parameter, "edit", use: postEditAcronymFormHandler)
        router.post("acronyms", Acronym.parameter, "delete", use: deleteAcronymHandler)
    }

    // MARK: - Acronym

    func getAcronymsHandler(_ req: Request) throws -> Future<View> {
        jjprint("getAcronymsHandler")
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            struct Context: Encodable {
                let title: String
                let acronyms: [Acronym]?
            }
            let context = Context(title: "Acronyms", acronyms: acronyms.isEmpty ? nil : acronyms)
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
                }
                let context = Context(title: acronym.short, acronym: acronym, user: user)
                return try req.view().render("acronym", context)
            }
        }
    }

    func getCreateAcronymFormHandler(_ req: Request) throws -> Future<View> {
        struct Context: Encodable {
            let title = "Create An Acronym"
            let users: Future<[User]>
        }
        let context = Context(users: User.query(on: req).all())
        return try req.view().render("acronymForm", context)
    }

    func postCreateAcronymFormHandler(_ req: Request, acronym: Acronym) throws -> Future<Response> {
        return acronym.save(on: req).map(to: Response.self) { acronym in
            guard let id = acronym.id else {
                throw Abort(.internalServerError)
            }
            return req.redirect(to: "/acronyms/\(id)")
        }
    }

    func getEditAcronymFormHandler(_ req: Request) throws -> Future<View> {
        struct Context: Encodable {
            let title = "Edit An Acronym"
            let acronym: Acronym
            let users: Future<[User]>
            let editing = true
        }

        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            let context = Context(acronym: acronym, users: User.query(on: req).all())
            return try req.view().render("acronymForm", context)
        }
    }

    func postEditAcronymFormHandler(_ req: Request) throws -> Future<Response> {
        return try flatMap(
            to: Response.self,
            req.parameters.next(Acronym.self),
            req.content.decode(Acronym.self)
        ) { acronym, data in
            acronym.short = data.short
            acronym.long = data.long
            acronym.userID = data.userID
            return acronym.save(on: req).map(to: Response.self) { savedAcronym in
                guard let id = savedAcronym.id else {
                    throw Abort(.internalServerError)
                }
                return req.redirect(to: "/acronyms/\(id)")
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
