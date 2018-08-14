//
//  PostResponse.swift
//  App
//
//  Created by jj on 13/08/2018.
//

import Foundation
import Vapor
//import  FluentPostgreSQL
import FluentSQLite

final class PostResponse {
    var id: Int?
    var title: String
    var content: String
    var username: String
    var postID: Post.ID

    init(title: String, content: String, username: String, postID: Post.ID) {
        self.title = title
        self.content = content
        self.username = username
        self.postID = postID
    }
    
}


extension PostResponse: SQLiteModel { }

extension PostResponse: Content { }
extension PostResponse: Migration { }
extension PostResponse: Parameter { }

extension PostResponse {
    var post: Parent<PostResponse, Post> {
        return parent(\.postID)
    }
}
