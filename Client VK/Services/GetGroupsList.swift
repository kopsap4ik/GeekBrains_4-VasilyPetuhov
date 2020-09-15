//
//  GetGroupsList.swift
//  Client VK
//
//  Created by Василий Петухов on 03.08.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import Foundation
import RealmSwift

struct GroupsResponse:  Decodable {
    var response: Response
    
    struct Response: Decodable {
        var count: Int
        var items: [Item]
        
        struct Item: Decodable {
            var name: String
            var logo: String  // уже тут нужно писать желаемые названия
            var id: Int
        
            enum CodingKeys: String, CodingKey {
                case name
                case logo = "photo_50"
                case id
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                name = try container.decode(String.self, forKey: .name)
                logo = try container.decode(String.self, forKey: .logo)
                id = try container.decode(Int.self, forKey: .id)
            }
        }
    }

}

// Обычный способ загрузки данных, парсинг и запись в реалм
class GetGroupsList {
    
    //данные для авторизации в ВК
    func loadData() {
        
        // Конфигурация по умолчанию
        let configuration = URLSessionConfiguration.default
        // собственная сессия
        let session =  URLSession(configuration: configuration)
        
        // конструктор для URL
        var urlConstructor = URLComponents()
        urlConstructor.scheme = "https"
        urlConstructor.host = "api.vk.com"
        urlConstructor.path = "/method/groups.get"
        urlConstructor.queryItems = [
            URLQueryItem(name: "user_id", value: String(Session.instance.userId)),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "access_token", value: Session.instance.token),
            URLQueryItem(name: "v", value: "5.122")
        ]
        
        // задача для запуска
        let task = session.dataTask(with: urlConstructor.url!) { (data, response, error) in
            //print("Запрос к API: \(urlConstructor.url!)")
            
            // в замыкании данные, полученные от сервера, мы преобразуем в json
            guard let data = data else { return }
            
            do {
                let arrayGroups = try JSONDecoder().decode(GroupsResponse.self, from: data)
                var grougList: [Group] = []
                for i in 0...arrayGroups.response.items.count-1 {
                    let name = ((arrayGroups.response.items[i].name))
                    let logo = arrayGroups.response.items[i].logo
                    let id = arrayGroups.response.items[i].id
                    grougList.append(Group.init(groupName: name, groupLogo: logo, id: id))
                }
                
                DispatchQueue.main.async {
                    RealmOperations().saveGroupsToRealm(grougList)
                }
                
            } catch let error {
                print(error)
            }
        }
        task.resume()
        
    }
    
    
}
