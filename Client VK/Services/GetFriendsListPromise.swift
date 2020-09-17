//
//  GetFriendsListPromise.swift
//  Client VK
//
//  Created by Василий Петухов on 15.09.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import Foundation
import PromiseKit

class GetFriendsListPromise {
    
    func getData() -> Promise<[Friend]> {
        
        let promise = Promise<[Friend]> { (resolver) in
            // Конфигурация по умолчанию
            let configuration = URLSessionConfiguration.default
            // собственная сессия
            let session =  URLSession(configuration: configuration)
            
            // конструктор для URL
            var urlConstructor = URLComponents()
            urlConstructor.scheme = "https"
            urlConstructor.host = "api.vk.com"
            urlConstructor.path = "/method/friends.get"
            urlConstructor.queryItems = [
                URLQueryItem(name: "user_id", value: String(Session.instance.userId)),
                URLQueryItem(name: "fields", value: "photo_50"),
                URLQueryItem(name: "access_token", value: Session.instance.token),
                URLQueryItem(name: "v", value: "5.122")
            ]
            
            // задача для запуска
            let task = session.dataTask(with: urlConstructor.url!) { (data, _, error) in
                //print("Запрос к API: \(urlConstructor.url!)")
            
                
                guard let data = data else {
                    resolver.reject(error!)
                    return
                }
                
                do {
                    let arrayFriends = try JSONDecoder().decode(FriendsResponse.self, from: data)
                    var friendList: [Friend] = []
                    for i in 0...arrayFriends.response.items.count-1 {
                        // не отображаем удаленных и заблокированных друзей
                        if arrayFriends.response.items[i].deactivated == nil {
                            let name = ((arrayFriends.response.items[i].firstName) + " " + (arrayFriends.response.items[i].lastName))
                            let avatar = arrayFriends.response.items[i].avatar
                            let id = String(arrayFriends.response.items[i].id)
                            friendList.append(Friend.init(userName: name, userAvatar: avatar, ownerID: id))
                        }
                    }
                    
                    resolver.fulfill(friendList)
                    
//                    DispatchQueue.main.async {
//                        RealmOperations().saveFriendsToRealm(friendList)
//                    }
                    
                } catch let error {
                    resolver.reject(error)
                }
            }
            task.resume()
        }
    return promise
        
    }
    

    
}
