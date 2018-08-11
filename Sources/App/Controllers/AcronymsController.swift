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

        routes.post(Record.self, use: postRecordHandler)
        routes.put(Record.parameter, use: putRecordHandler)

        routes.delete(Record.parameter, use: deleteRecordHandler)

    }

    func putRecordHandler(_ req: Request) throws -> Future<Record> {
        return try flatMap(to: Record.self,
            req.parameters.next(Record.self),
            req.content.decode(Record.self)
        ) { (currentRecord, updatedRecord) -> Future<Record> in
            currentRecord.short = updatedRecord.short
            currentRecord.long = updatedRecord.long
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

}
