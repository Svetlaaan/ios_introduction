//
//  Post.swift
//  FirstCourseFinalTask
//
//  Created by lala lala on 17.05.2020.
//  Copyright © 2020 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

struct Post: PostProtocol {
    var id: PostProtocol.Identifier
    
    var author: GenericIdentifier<UserProtocol>
    
    var description: String
    
    var imageURL: URL {return .init(fileURLWithPath: "") }
    
    var createdTime: Date {return .init()}
    
    var currentUserLikesThisPost: Bool
    
    var likedByCount: Int
    
}
