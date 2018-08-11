//
//  AcronymsController.swift
//  App
//
//  Created by jj on 11/08/2018.
//

import Vapor
import Fluent
import FluentSQL

struct AcronymsController: RouteCollection {

    func boot(router: Router) {
        let acronymsRoutes = router.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(Acronym.parameter, use: getAcronymHandler)
        acronymsRoutes.get("search", use: searchAcronymsHandler)
        acronymsRoutes.get("fullsearch", use: fullsearchAcronymsHandler)
        acronymsRoutes.get("first", use: getFirstAcronymHandler)
        acronymsRoutes.get("last", use: getLastAcronymHandler)
        acronymsRoutes.get("sorted", use: getSortedAcronymsHandler)
        acronymsRoutes.get("id", Int.parameter, use: getAcronymByIdHandler)

        acronymsRoutes.post(use: postAcronymHandler)
        acronymsRoutes.put(Acronym.parameter, use: putAcronymHandler)

        acronymsRoutes.delete(Acronym.parameter, use: deleteAcronymHandler)

    }

    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }

    func getAcronymHandler(_ req: Request) throws -> Future<Acronym> {
        let acronym = try req.parameters.next(Acronym.self)
        return acronym
    }

    func postAcronymHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            return acronym.save(on: req)
        }
    }

    func putAcronymHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self,
            req.parameters.next(Acronym.self),
            req.content.decode(Acronym.self)
        ) { (currentAcronym, updatedAcronym) -> Future<Acronym> in
            currentAcronym.short = updatedAcronym.short
            currentAcronym.long = updatedAcronym.long
            return currentAcronym.save(on: req)
        }
    }

    func deleteAcronymHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }

    func searchAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req).filter(\.short == searchTerm).all()
    }

    func fullsearchAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long ~~ searchTerm)
        }.all()
    }

    func getFirstAcronymHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }

    func getLastAcronymHandler(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).sort(\.id, .descending).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }

    func getSortedAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }

    func getAcronymByIdHandler(_ req: Request) throws -> Future<Acronym> {
        let id = try req.parameters.next(Int.self)
        return Acronym.find(id, on: req).unwrap(or: Abort(.notFound))
    }

}
