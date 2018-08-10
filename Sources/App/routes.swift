import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.post("api", "acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            return acronym.save(on: req)
        }
    }
    router.post(Acronym.self, at: "api2", "acronyms") { (req, acronym) -> Future<Acronym> in
        return acronym.save(on: req)
    }

    router.get("api", "acronyms") { req -> Future<[Acronym]>in
        return Acronym.query(on: req).all()
    }

    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        let acronym = try req.parameters.next(Acronym.self)
        return acronym
    }

    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try flatMap(to: Acronym.self,
                           req.parameters.next(Acronym.self),
                           req.content.decode(Acronym.self)
        ) { (currentAcronym, updatedAcronym) -> Future<Acronym> in
        currentAcronym.short = updatedAcronym.short
        currentAcronym.long = updatedAcronym.long
        return currentAcronym.save(on: req)
        }
    }

    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
}
