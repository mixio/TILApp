//
//  PostsController.swift
//  App
//
//  Created by jj on 13/08/2018.
//

import Vapor
import Fluent
import FluentSQL

struct PostsController: RouteCollection, SQLiteBrowsable {

    typealias Record = Post
    typealias SortKeyType = String
    let sortKeyPath = \Record.title
    let slug = "posts"

    func boot(router: Router) {
        let routes = router.grouped("api", slug)
        routes.get(use: getRecordsHandler)
        routes.get(Record.parameter, use: getRecordHandler)
        routes.get("search", use: getSearchRecordsHandler)
        routes.get("fullsearch", use: getFullsearchRecordsHandler)
        routes.get("first", use: getFirstRecordHandler)
        routes.get("last", use: getLastRecordHandler)
        routes.get("sorted", use: getSortedRecordsHandler)
        routes.get(Record.parameter, "postResponses", use: geRecordPostResponsesHandler)

        routes.post(Record.self, use: postRecordHandler)
        routes.put(Record.parameter, use: putRecordHandler)

        routes.delete(Record.parameter, use: deleteRecordHandler)

    }

    func putRecordHandler(_ req: Request) throws -> Future<Record> {
        return try flatMap(to: Record.self,
                           req.parameters.next(Record.self),
                           req.content.decode(Record.self)
        ) { (currentRecord, updatedRecord) -> Future<Record> in
            currentRecord.title = updatedRecord.title
            return currentRecord.save(on: req)
        }
    }

    func getSearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).filter(\Record.title == searchTerm).all()
    }

    func getFullsearchRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Record.query(on: req).group(.or) { or in
            or.filter(\Record.title == searchTerm)
            or.filter(\Record.content ~~ searchTerm)
            }.all()
    }

    func geRecordPostResponsesHandler(_ req: Request) throws -> Future<[PostResponse]> {
        return try req.parameters.next(Record.self).flatMap(to: [PostResponse].self) { record in
            return try record.postResponses.query(on:req).all()
        }
    }

}
