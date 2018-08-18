//
//  UsersController.swift
//  App
//
//  Created by jj on 11/08/2018.
//

import Vapor
import Fluent
import FluentSQL
import Crypto

struct UsersController: RouteCollection, SQLiteUUIDBrowsable {

    typealias Record = User
    typealias PublicRecord = Record.Public
    typealias SortKeyType = String
    let sortKeyPath = \User.username
    let slug = "users"
    
    func boot(router: Router) {
        let routes = router.grouped("api", slug)
        routes.get(use: getPublicRecordsHandler)
        routes.get(Record.parameter, use: getPublicRecordHandler)
        routes.get("search", use: getSearchRecordsHandler)
        routes.get("fullsearch", use: getFullsearchRecordsHandler)
        routes.get("first", use: getFirstRecordHandler)
        routes.get("last", use: getLastRecordHandler)
        routes.get("sorted", use: getSortedRecordsHandler)
        routes.get(Record.parameter, "acronyms", use: geRecordAcronymsHandler)
        routes.get(Record.parameter, "posts", use: geRecordPostsHandler)

        routes.post(Record.self, use: postPublicRecordHandler)
        routes.post("reset", "passwords", use: postResetPasswordsHandler)
        routes.put(Record.parameter, use: putRecordHandler)

        routes.delete(Record.parameter, use: deleteRecordHandler)

    }

    func getPublicRecordsHandler(_ req: Request) throws -> Future<[PublicRecord]> {
        return Record.query(on: req).decode(data: PublicRecord.self).all()
    }

    func getPublicRecordHandler(_ req: Request) throws -> Future<PublicRecord> {
        return try req.parameters.next(Record.self).convertToPublic()
    }

    func postPublicRecordHandler(_ req: Request, record: Record) throws -> Future<PublicRecord> {
        record.password = try BCrypt.hash(record.password)
        return record.save(on: req).convertToPublic()
    }

    func putRecordHandler(_ req: Request) throws -> Future<Record> {
        return try flatMap(to: Record.self,
                           req.parameters.next(Record.self),
                           req.content.decode(Record.self)
        ) { (currentRecord, updatedRecord) -> Future<Record> in
            currentRecord.name = updatedRecord.name
            currentRecord.username = updatedRecord.username
            return currentRecord.save(on: req)
        }
    }

    func getSearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).filter(\Record.username == searchTerm).all()
    }

    func getFullsearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).group(.or) { or in
            or.filter(\Record.username == searchTerm)
            or.filter(\Record.name ~~ searchTerm)
            }.all()
    }

    func geRecordAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Record.self).flatMap(to: [Acronym].self) { record in
            return try record.acronyms.query(on:req).all()
        }
    }

    func geRecordPostsHandler(_ req: Request) throws -> Future<[Post]> {
        return try req.parameters.next(Record.self).flatMap(to: [Post].self) { record in
            return try record.posts.query(on:req).all()
        }
    }

    func postResetPasswordsHandler(_ req: Request) throws -> Future<Response> {
        return User.query(on: req).all().flatMap(to: Response.self) { users in
            var results: [Future<User>] = []
            for user in users {
                user.password = try BCrypt.hash(user.username)
                results.append(user.save(on: req))
            }
            let redirect = req.redirect(to: "/api/users")
            return results.flatten(on: req).transform(to: redirect)
        }
    }
    
}
