//
//  AcronymsController.swift
//  App
//
//  Created by jj on 11/08/2018.
//

import Vapor
import Fluent
import FluentSQL

struct AcronymsController: RouteCollection, SQLiteBrowsable {

    typealias Record = Acronym
    typealias SortKeyType = String
    let sortKeyPath = \Acronym.short
    let slug = "acronyms"

    func boot(router: Router) {

        let routes = router.grouped("api", slug)
        routes.get(use: getRecordsHandler)
        routes.get(Record.parameter, use: getRecordHandler)
        routes.get("search", use: getSearchRecordsHandler)
        routes.get("fullsearch", use: getFullsearchRecordsHandler)
        routes.get("first", use: getFirstRecordHandler)
        routes.get("last", use: getLastRecordHandler)
        routes.get("sorted", use: getSortedRecordsHandler)
        routes.get(Acronym.parameter, "user", use: getUserHandler)
        routes.get(Acronym.parameter, "categories", use: getCategoriesHandler)

        routes.post(Record.self, use: postRecordHandler)
        routes.post(Record.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        
        routes.put(Record.parameter, use: putRecordHandler)

        routes.delete(Record.parameter, use: deleteRecordHandler)
        routes.delete(Record.parameter, "categories", Category.parameter, use: deleteRecordCategoriesHandler)

    }

    func putRecordHandler(_ req: Request) throws -> Future<Record> {
        return try flatMap(to: Record.self,
            req.parameters.next(Record.self),
            req.content.decode(Record.self)
        ) { (currentRecord, updatedRecord) -> Future<Record> in
            currentRecord.short = updatedRecord.short
            currentRecord.long = updatedRecord.long
            currentRecord.userID = updatedRecord.userID
            return currentRecord.save(on: req)
        }
    }

    func getSearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).filter(\.short == searchTerm).all()
    }

    func getFullsearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long ~~ searchTerm)
        }.all()
    }

    func getUserHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
            return acronym.user.get(on: req)
        }
    }

    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)
        ) { acronym, category in
            return acronym.categories.attach(category, on: req).transform(to: .created)
        }
    }

    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self) { acronym in
            // Note:
            // <https://docs.swift.org/swift-book/LanguageGuide/Closures.html>
            //
            // Implicit Returns keyword from Single-Expression Closures
            //
            // Single expression closures can implicitly return the result of their single expression by
            // omitting the return keyword from their declaration.
            // The function type makes the returned type clear, there is no ambiguity, and the
            // `return` keyword can be omitted.
            /* return */ try acronym.categories.query(on: req).all()
        }
    }

    func deleteRecordCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(
            to: HTTPStatus.self,
            req.parameters.next(Acronym.self),
            req.parameters.next(Category.self)
        ) { acronym, category in
            acronym.categories.detach(category, on: req).transform(to: HTTPStatus.noContent)
        }

    }

}
