//
//  ApiBrowsable.swift
//  App
//
//  Created by jj on 11/08/2018.
//
import Vapor
import Fluent
import FluentSQLite
import Crypto

protocol _ApiBrowsable {
    associatedtype Record: Parameter, Content
    associatedtype SortKeyType
    var sortKeyPath: ReferenceWritableKeyPath<Record, SortKeyType> { get }
    var slug: String { get }

    // MARK: method DELETE
    func deleteRecordHandler(_ req: Request) throws -> Future<HTTPStatus>

    // MARK: method GET
    func getFirstRecordHandler(_ req: Request) throws -> Future<Record>
    func getFullsearchRecordsHandler(_ req: Request) throws -> Future<[Record]>
    func getLastRecordHandler(_ req: Request) throws -> Future<Record>
    func getRecordHandler(_ req: Request) throws -> Future<Record>
    func getRecordsHandler(_ req: Request) throws -> Future<[Record]>
    func getSearchRecordsHandler(_ req: Request) throws -> Future<[Record]>
    func getSortedRecordsHandler(_ req: Request) throws -> Future<[Record]>

    // MARK: method POST
    func postRecordHandler(_ req: Request, record: Record) throws -> Future<Record>

    // MARK: method PUT
    func putRecordHandler(_ req: Request) throws -> Future<Record>
}

protocol ApiBrowsable: _ApiBrowsable where Record: _SQLiteModel {}

extension ApiBrowsable {

    func getRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        return Record.query(on: req).all()
    }

    func getRecordHandler(_ req: Request) throws -> Future<Record> {
        let record = try req.parameters.next(Record.self)
        return record as! EventLoopFuture<Self.Record>
    }

    func postRecordHandler(_ req: Request, record: Record) throws -> Future<Record> {
        return record.save(on: req)
    }

    func deleteRecordHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return (try req.parameters.next(Record.self) as! EventLoopFuture<Self.Record>)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }

    func getFirstRecordHandler(_ req: Request) throws -> Future<Record> {
        return Record.query(on: req).first().map(to: Record.self) { record in
            guard let record = record else {
                throw Abort(.notFound)
            }
            return record
        }
    }

    func getSortedRecordsHandler(_ req: Request) throws -> Future<[Record]> {
        return Record.query(on: req).sort(sortKeyPath, .ascending).all()
    }

}

protocol SQLiteBrowsable: ApiBrowsable where Record: SQLiteModel {}
protocol SQLiteUUIDBrowsable: ApiBrowsable where Record: SQLiteUUIDModel {}

extension SQLiteBrowsable {

    func getLastRecordHandler(_ req: Request) throws -> Future<Record> {
        return Record.query(on: req).sort(\.id, .descending).first().map(to: Record.self) { record in
            guard let record = record else {
                throw Abort(.notFound)
            }
            return record
        }
    }

}

extension SQLiteUUIDBrowsable {

    func getLastRecordHandler(_ req: Request) throws -> Future<Record> {
        return Record.query(on: req).sort(\.id, .descending).first().map(to: Record.self) { record in
            guard let record = record else {
                throw Abort(.notFound)
            }
            return record
        }
    }

}
