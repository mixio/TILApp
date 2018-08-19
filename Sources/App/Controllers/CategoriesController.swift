//
//  CategoriesController.swift
//  App
//
//  Created by jj on 12/08/2018.
//

import Vapor
import Fluent
import FluentSQL

struct CategoriesController: RouteCollection, SQLiteBrowsable {
    typealias Record = Category
    typealias SortKeyType = String
    let sortKeyPath = \Category.name
    let slug = "categories"

    func boot(router: Router) {
        let routes = router.grouped("api", slug)
        routes.get(use: getRecordsHandler)
        routes.get(Record.parameter, use: getRecordHandler)
        routes.get("search", use: getSearchRecordsHandler)
        routes.get("fullsearch", use: getFullsearchRecordsHandler)
        routes.get("first", use: getFirstRecordHandler)
        routes.get("last", use: getLastRecordHandler)
        routes.get("sorted", use: getSortedRecordsHandler)
        routes.get(Record.parameter, "acronyms", use: geRecordAcronymsHandler)

        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let protectedRoutes = routes.grouped(tokenAuthMiddleware, guardAuthMiddleware)

        protectedRoutes.post(Record.self, use: postRecordHandler)
        protectedRoutes.put(Record.parameter, use: putRecordHandler)

        protectedRoutes.delete(Record.parameter, use: deleteRecordHandler)

    }

    func putRecordHandler(_ req: Request) throws -> Future<Record> {
        return try flatMap(to: Record.self,
                           req.parameters.next(Record.self),
                           req.content.decode(Record.self)
        ) { (currentRecord, updatedRecord) -> Future<Record> in
            currentRecord.name = updatedRecord.name
            return currentRecord.save(on: req)
        }
    }

    func getSearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).filter(\Record.name == searchTerm).all()
    }

    func getFullsearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).group(.or) { or in
            or.filter(\Record.name == searchTerm)
            or.filter(\Record.description ~~ searchTerm)
            }.all()
    }

    func geRecordAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Record.self).flatMap(to: [Acronym].self) { record in
            return try record.acronyms.query(on:req).all()
        }
    }

}
