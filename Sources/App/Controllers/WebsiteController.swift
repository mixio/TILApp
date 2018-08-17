//
//  WebsiteController.swift
//  App
//
//  Created by jj on 16/08/2018.
//

import Foundation
import Vapor
import Leaf

struct WebsiteController: RouteCollection {
    func boot(router: Router) throws {
        router.get(use: getAcronymsHandler)
        router.get("acronyms", Acronym.parameter, use: getAcronymHandler)
        router.get("users", use: getUsersHandler)
        router.get("users", User.parameter, use: getUserHandler)
    }

    func getAcronymsHandler(_ req: Request) throws -> Future<View> {
        return Acronym.query(on: req).all().flatMap(to: View.self) { acronyms in
            struct acronymsContext: Encodable {
                let title: String
                let acronyms: [Acronym]?
            }
            let context = acronymsContext(title: "Acronyms", acronyms: acronyms.isEmpty ? nil : acronyms)
            return try req.view().render("acronyms", context)
        }
    }

    func getAcronymHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(Acronym.self).flatMap(to: View.self) { acronym in
            return acronym.user.get(on: req).flatMap(to: View.self) { user in
                struct AcronymContext: Encodable {
                    let title: String
                    let acronym: Acronym
                    let user: User
                }
                let context = AcronymContext(title: acronym.short, acronym: acronym, user: user)
                return try req.view().render("acronym", context)
            }
        }
    }

    func getUsersHandler(_ req: Request) throws -> Future<View> {
        return User.query(on: req).all().flatMap(to: View.self) { users in
            struct UsersContext: Encodable {
                let title: String
                let users: [User]?
            }
            let context = UsersContext(title: "Users", users: users.isEmpty ? nil : users)
            return try req.view().render("users", context)
        }
    }

    func getUserHandler(_ req: Request) throws -> Future<View> {
        return try req.parameters.next(User.self).flatMap(to: View.self) { user in
            return try user.acronyms.query(on: req).all().flatMap(to: View.self) { acronyms in
                struct UserContext: Encodable {
                    let title: String
                    let acronyms: [Acronym]?
                    let user: User
                }
                let context = UserContext(title: user.name, acronyms: acronyms.isEmpty ? nil : acronyms, user: user)
                return try req.view().render("user", context)
            }
        }
    }

}
