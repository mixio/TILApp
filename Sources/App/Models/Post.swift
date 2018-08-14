//
//  Post.swift
//  App
//
//  Created by jj on 13/08/2018.
//

import Foundation
import Vapor
//import  FluentPostgreSQL
import FluentSQLite

final class Post: Codable {
    var id: Int?
    var title: String
    var content: String
    var userID: User.ID

    init(title: String, content: String, userID: User.ID) {
        self.title = title
        self.content = content
        self.userID = userID
    }

}

extension Post: SQLiteModel { }

extension Post: Content { }
extension Post: Migration { }
extension Post: Parameter { }

extension Post {
    var postResponses: Children<Post, PostResponse> {
        return children(\.postID)
    }
}


