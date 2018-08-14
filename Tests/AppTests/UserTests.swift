//
//  UserTests.swift
//  App
//
//  Created by jj on 14/08/2018.
//

import Foundation
@testable import App
import Vapor
import XCTest
import FluentSQLite

final class UserTests: XCTestCase {

    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    var conn: SQLiteConnection!

    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .sqlite).wait()
    }

    override func tearDown() {
        conn.close()
    }

    func testUsersCanBeRetrievedFromTheAPI() throws {
        let user = try User.create(
            name: usersName,
            username: usersUsername,
            on: conn
        )

        _ = try User.create(on: conn)

        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User].self
        )

        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, user.id)
    }

    func testUserCanBeSavedWithTheAPI() throws {
        let user = User(name: usersName, username: usersUsername)
        let receivedUser = try app.getResponse(
            to: usersURI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: user,
            decodeTo: User.self
        )

        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertNotNil(receivedUser.id)

        let users = try app.getResponse(
            to: usersURI,
            decodeTo: [User].self
        )

        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].name, usersName)
        XCTAssertEqual(users[0].username, usersUsername)
        XCTAssertEqual(users[0].id, receivedUser.id)

    }

    func testGettingASingleUserFromTheAPI() throws {
        let user = try User.create(
            name: usersName,
            username: usersUsername,
            on: conn
        )
        let receivedUser = try app.getResponse(
            to: "\(usersURI)\(user.id!)",
            decodeTo: User.self
        )

        XCTAssertEqual(receivedUser.name, usersName)
        XCTAssertEqual(receivedUser.username, usersUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }

    func testGettingAUsersAcronymsFromTheAPI() throws {
        let user = try User.create(on: conn)
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        let acronym1 = try Acronym.create(
            short: acronymShort,
            long: acronymLong,
            user: user,
            on: conn
        )
        _ = try Acronym.create(
            short: "LOL",
            long: "Laughing Out Loud",
            user: user,
            on: conn
        )

        let acronyms = try app.getResponse(
            to: "\(usersURI)\(user.id!)/acronyms",
            decodeTo: [Acronym].self
        )

        XCTAssertEqual(acronyms.count, 2)
        XCTAssertEqual(acronyms[0].id, acronym1.id)
        XCTAssertEqual(acronyms[0].short, acronymShort)
        XCTAssertEqual(acronyms[0].long, acronymLong)
}

    static let allTests = [
        ("testUsersCanBeRetrievedFromTheAPI", testUsersCanBeRetrievedFromTheAPI),
        ("testUserCanBeSavedWithTheAPI", testUserCanBeSavedWithTheAPI),
        ("testGettingASingleUserFromTheAPI", testGettingASingleUserFromTheAPI),
        ("testGettingAUsersAcronymsFromTheAPI", testGettingAUsersAcronymsFromTheAPI),
        ]

//    func testUsersCanBeRetrievedFromAPI_first_try() throws {
//
//        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
//        var revertConfig = Config.default()
//        var revertServices = Services.default()
//        var revertEnv = Environment.testing
//        revertEnv.arguments = revertEnvironmentArgs
//        try App.configure(&revertConfig, &revertEnv, &revertServices)
//        let revertApp = try Application(
//            config: revertConfig,
//            environment: revertEnv,
//            services: revertServices
//        )
//        try App.boot(revertApp)
//        try revertApp.asyncRun().wait()
//
//        let migrateEnvironmentArgs = ["vapor", "migrate", "-y"]
//        var migrateConfig = Config.default()
//        var migrateServices = Services.default()
//        var migrateEnv = Environment.testing
//        migrateEnv.arguments = migrateEnvironmentArgs
//        try App.configure(&migrateConfig, &migrateEnv, &migrateServices)
//        let migrateApp = try Application(
//            config: migrateConfig,
//            environment: migrateEnv,
//            services: migrateServices
//        )
//        try App.boot(migrateApp)
//        try migrateApp.asyncRun().wait()
//        let expectedName = "Alice"
//        let expectedUsername = "alice"
//
//        var config = Config.default()
//        var services = Services.default()
//        var env = Environment.testing
//        try App.configure(&config, &env, &services)
//        let app = try Application(config: config, environment: env, services: services)
//        try App.boot(app)
//
//        let conn = try app.newConnection(to: .sqlite).wait()
//
//        let user = User(name: expectedName, username: expectedUsername)
//        let savedUser = try user.save(on: conn).wait()
//        _ = try User(name: "Luke", username: "luke").save(on: conn).wait()
//
//        let responder = try app.make(Responder.self)
//
//        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
//        let wrappedRequest = Request(http: request, using: app)
//
//        let response = try responder.respond(to: wrappedRequest).wait()
//
//        let data = response.http.body.data
//        let users = try JSONDecoder().decode([User].self, from: data!)
//
//        XCTAssertEqual(users.count, 2)
//        XCTAssertEqual(users[0].name, expectedName)
//        XCTAssertEqual(users[0].username, expectedUsername)
//        XCTAssertEqual(users[0].id, savedUser.id)
//        conn.close()
//    }

}
