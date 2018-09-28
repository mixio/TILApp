//
//  TestServiceController.swift
//  App
//
//  Created by jj on 28/09/2018.
//

import Foundation
import Vapor

struct TestServiceController: RouteCollection {

    func boot(router: Router) throws {
        let routes = router.grouped("service")
        routes.get("jjservice", use: jjService)
    }

    func jjService(_ req: Request) throws -> String {
        let jjService = try req.make(JJService.self)
        let string = jjService.sayHello()
        return string
    }
}
