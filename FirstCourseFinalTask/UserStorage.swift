//
//  UserStorage.swift
//  FirstCourseFinalTask
//
//  Created by lala lala on 18.05.2020.
//  Copyright © 2020 E-Legion. All rights reserved.
//

import Foundation
import FirstCourseFinalTaskChecker

class UserStorage: UsersStorageProtocol {
    
    var users: [User]
    var followers: [(GenericIdentifier<UserProtocol>, GenericIdentifier<UserProtocol>)]
    var currentUserID: GenericIdentifier<UserProtocol>
    /// Инициализатор хранилища. Принимает на вход массив пользователей, массив подписок в
    /// виде кортежей в котором первый элемент это ID, а второй - ID пользователя на которого он
    /// должен быть подписан и ID текущего пользователя.
    /// Инициализация может завершится с ошибкой если пользователя с переданным ID
    /// нет среди пользователей в массиве users.
    required init?(users: [UserInitialData], followers: [(GenericIdentifier<UserProtocol>, GenericIdentifier<UserProtocol>)], currentUserID: GenericIdentifier<UserProtocol>) {
        guard users.contains(where: {$0.id == currentUserID}) else {
            return nil
        }
        
        self.followers = followers
        self.currentUserID = currentUserID
        var usersList = [User]()
        
        users.forEach{
            initialUser in
            let followsCount = followers.filter{$0.0 == initialUser.id}.count
            let followedByCount = followers.filter{$0.1 == initialUser.id}.count
            
            var currentUserFollowsThisUser = false
            if ((followers.first{$0.0 == currentUserID && $0.1 == initialUser.id}) != nil) {
                currentUserFollowsThisUser = true
            }
            
            var currentUserIsFollowedByThisUser = false
            if (followers.first{$0.1 == currentUserID && $0.0 == initialUser.id} != nil) {
                currentUserIsFollowedByThisUser = true
            }
            
            usersList.append(
                User(id: initialUser.id,
                     username: initialUser.username,
                     fullName: initialUser.fullName,
                     avatarURL: initialUser.avatarURL,
                     currentUserFollowsThisUser: currentUserFollowsThisUser,
                     currentUserIsFollowedByThisUser: currentUserIsFollowedByThisUser,
                     followsCount: followsCount,
                     followedByCount: followedByCount)
            )
        }
        self.users = usersList

    }
    
    var count: Int {
        get{
            return users.count
        }
    }
    
    /// Возвращает текущего пользователя.
    ///
    /// - Returns: Текущий пользователь.
    func currentUser() -> UserProtocol {
        return users.first{$0.id == currentUserID}!
    }
    
    /// Возвращает пользователя с переданным ID.
    ///
    /// - Parameter userID: ID пользователя которого нужно вернуть.
    /// - Returns: Пользователь если он был найден.
    /// nil если такого пользователя нет в хранилище.
    func user(with userID: GenericIdentifier<UserProtocol>) -> UserProtocol? {
        guard users.contains(where: {$0.id == userID}) else {
            return nil
        }
        return users.first{$0.id == userID}
    }
    
    /// Возвращает всех пользователей, содержащих переданную строку.
    ///
    /// - Parameter searchString: Строка для поиска.
    /// - Returns: Массив пользователей. Если не нашлось ни одного пользователя, то пустой массив.
    func findUsers(by searchString: String) -> [UserProtocol] {
        guard users.contains(where: {$0.username == searchString || $0.fullName == searchString}) else {
            return [UserProtocol]()
        }
        return users.filter({(user:UserProtocol) -> Bool in
            user.username.hasPrefix(searchString) || user.fullName.hasPrefix(searchString)
        })
    }
    
    /// Добавляет текущего пользователя в подписчики.
    ///
    /// - Parameter userIDToFollow: ID пользователя на которого должен подписаться текущий пользователь.
    /// - Returns: true если текущий пользователь стал подписчиком пользователя с переданным ID
    /// или уже являлся им.
    /// false в случае если в хранилище нет пользователя с переданным ID.
    func follow(_ userIDToFollow: GenericIdentifier<UserProtocol>) -> Bool {
        guard users.contains(where: {$0.id == userIDToFollow}) else {
            return false
        }
        
        let currentUserIndexInList = users.firstIndex{$0.id == currentUserID}
        let userToFollowIndex = users.firstIndex{$0.id == userIDToFollow}
        
        guard currentUserIndexInList != nil else {
            return false
        }
        guard userToFollowIndex != nil else {
                   return false
        }
        users[currentUserIndexInList!].followsCount += 1
        users[userToFollowIndex!].followedByCount += 1
        followers.append((currentUserID, userIDToFollow))
        return true
    }
    
    /// Удаляет текущего пользователя из подписчиков.
    ///
    /// - Parameter userIDToUnfollow: ID пользователя от которого должен отписаться текущий пользователь.
    /// - Returns: true если текущий пользователь перестал быть подписчиком пользователя с
    /// переданным ID или и так не являлся им.
    /// false в случае если нет пользователя с переданным ID.
    func unfollow(_ userIDToUnfollow: GenericIdentifier<UserProtocol>) -> Bool {
        guard users.contains(where: {$0.id == userIDToUnfollow}) else {
            return false
        }
        
        let currentUserIndexInList = users.firstIndex{$0.id == currentUserID}
        let userToUnfollowIndex = users.firstIndex{$0.id == userIDToUnfollow}
        
        guard currentUserIndexInList != nil else {
            return false
        }
        guard userToUnfollowIndex != nil else {
                   return false
        }
        users[currentUserIndexInList!].followsCount -= 1
        users[userToUnfollowIndex!].followedByCount -= 1
        
        followers.removeAll(where: {$0.0 == currentUserID && $0.1 == userIDToUnfollow})
        return true
    }
    
    /// Возвращает всех подписчиков пользователя.
    ///
    /// - Parameter userID: ID пользователя подписчиков которого нужно вернуть.
    /// - Returns: Массив пользователей.
    /// Пустой массив если на пользователя никто не подписан.
    /// nil если такого пользователя нет.
    func usersFollowingUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        guard users.contains(where: {$0.id == userID}) else {
            return nil
        }
        
        return users.filter({
            (user: UserProtocol) -> Bool in
            followers.first{ $0.1 == userID && $0.0 == user.id} != nil
        })
    }
    
    /// Возвращает все подписки пользователя.
    ///
    /// - Parameter userID: ID пользователя подписки которого нужно вернуть.
    /// - Returns: Массив пользователей.
    /// Пустой массив если он ни на кого не подписан.
    /// nil если такого пользователя нет.
    func usersFollowedByUser(with userID: GenericIdentifier<UserProtocol>) -> [UserProtocol]? {
        guard users.contains(where: {$0.id == userID}) else {
            return nil
        }
        
        return users.filter({
            (user: UserProtocol) -> Bool in
            followers.first{ $0.0 == userID && $0.1 == user.id} != nil
        })
    }
}
