//
//  PostStorage.swift
//  FirstCourseFinalTask
//
//  Created by lala lala on 17.05.2020.
//  Copyright © 2020 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

class PostsStorage: PostsStorageProtocol {
    var posts: [PostInitialData]
    var likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)]
    var currentUserID: GenericIdentifier<UserProtocol>
    var newPost = Post(id: "", author: "", description: "",  currentUserLikesThisPost: false, likedByCount: 0)
    
    /// Инициализатор хранилища. Принимает на вход массив публикаций, массив лайков в виде
    /// кортежей в котором первый - это ID пользователя, поставившего лайк, а второй - ID публикации
    /// на которой должен стоять этот лайк и ID текущего пользователя.
    required init(posts: [PostInitialData], likes: [(GenericIdentifier<UserProtocol>, GenericIdentifier<PostProtocol>)], currentUserID: GenericIdentifier<UserProtocol>) {
        self.posts = posts
        self.likes = likes
        self.currentUserID = currentUserID
    }
    
    var count: Int { // kol-vo postov
        get {
            return posts.count
        }
    }
    
    /// Возвращает публикацию с переданным ID.
    ///
    /// - Parameter postID: ID публикации которую нужно вернуть.
    /// - Returns: Публикация если она была найдена.
    /// nil если такой публикации нет в хранилище.
    func post(with postID: GenericIdentifier<PostProtocol>) -> PostProtocol? {
        guard posts.contains(where: {$0.id == postID}) else {
            return nil
        }
        
        var somePost = newPost
        
        for post in posts {
            if post.id == postID {
                somePost.id = post.id
                somePost.author = post.author
                somePost.description = post.description
                somePost.likedByCount = likes.filter{$0.1 == postID}.count
            }
        }
        for like in likes {
            if like.0 == currentUserID && like.1 == postID {
                somePost.currentUserLikesThisPost = true
            }
        }
        return somePost
    }
    
    /// Возвращает все публикации пользователя с переданным ID.
    ///
    /// - Parameter authorID: ID пользователя публикации которого нужно вернуть.
    /// - Returns: Массив публикаций.
    /// Пустой массив если пользователь еще ничего не опубликовал.
    func findPosts(by authorID: GenericIdentifier<UserProtocol>) -> [PostProtocol] {
        guard posts.contains(where: {$0.author == authorID}) else {
            return [PostProtocol]()
        }
        
        var authorsPost = newPost
        var postsArray = [Post]()

        for post in posts {
            if post.author == authorID {
                authorsPost.id = post.id
                authorsPost.author = post.author
                authorsPost.description = post.description
                
                postsArray.append(authorsPost)
            }
        }
        return postsArray
    }
    
    /// Возвращает все публикации, содержащие переданную строку.
    ///
    /// - Parameter searchString: Строка для поиска.
    /// - Returns: Массив публикаций.
    /// Пустой массив если нет таких публикаций.
    func findPosts(by searchString: String) -> [PostProtocol] {
        guard posts.contains(where: {$0.description == searchString}) else {
            return [PostProtocol]()
        }
        
        var searchingPost = newPost
        var postsArray = [Post]()
        
        for post in posts {
            if post.description.contains(searchString){
                searchingPost.id = post.id
                postsArray.append(searchingPost)
            }
        }
       return postsArray
    }
    
    /// Ставит лайк от текущего пользователя на публикацию с переданным ID.
    ///
    /// - Parameter postID: ID публикации на которую нужно поставить лайк.
    /// - Returns: true если операция выполнена упешно или пользователь уже поставил лайк
    /// на эту публикацию.
    /// false в случае если такой публикации нет.
    func likePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        guard posts.contains(where: {$0.id == postID}) else {
            return false
        }
        
        // если уже лайкнуто
        if (likes.first{$0.0 == currentUserID && $0.1 == postID} != nil) {
            return true
        }
        
        likes.append((currentUserID, postID))
        
        return true
    }
    
    /// Удаляет лайк текущего пользователя у публикации с переданным ID.
       ///
       /// - Parameter postID: ID публикации у которой нужно удалить лайк.
       /// - Returns: true если операция выполнена успешно или пользователь и так не ставил лайк
       /// на эту публикацию.
       /// false в случае если такой публикации нет.
    func unlikePost(with postID: GenericIdentifier<PostProtocol>) -> Bool {
        guard posts.contains(where: {$0.id == postID}) else {
            return false
        }
        
        likes.removeAll(where: {$0.0 == currentUserID && $0.1 == postID})
        return true
    }
    
    /// Возвращает ID пользователей поставивших лайк на публикацию.
    ///
    /// - Parameter postID: ID публикации лайки на которой нужно искать.
    /// - Returns: Массив ID пользователей.
    /// Пустой массив если никто еще не поставил лайк на эту публикацию.
    /// nil если такой публикации нет в хранилище.
    func usersLikedPost(with postID: GenericIdentifier<PostProtocol>) -> [GenericIdentifier<UserProtocol>]? {
        guard posts.contains(where: {$0.id == postID}) else {
            return nil
        }
        
        var somePost = newPost
        var usersArray = [GenericIdentifier<UserProtocol>]()
        
        for like in likes {
            if like.1 == postID {
                somePost.author = like.0
                usersArray.append(somePost.author)
            }
        }
        return usersArray
    }
}
