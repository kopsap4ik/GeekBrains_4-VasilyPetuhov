//
//  GetNewsList.swift
//  Client VK
//
//  Created by Василий Петухов on 04.09.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import Foundation
import UIKit

struct NewsResponse: Decodable {
    var response: Response
    
    struct Response: Decodable {
        var items: [Item]
        var groups: [Groups]
        
        struct Item: Decodable {
            var sourceID: Int
            var date: Int
            var text: String
            var attachments: [Attachments]
            
            private enum CodingKeys: String, CodingKey {
                case sourceID = "source_id"
                case date
                case text
                case attachments
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                sourceID = try container.decode(Int.self, forKey: .sourceID)
                date = try container.decode(Int.self, forKey: .date)
                text = try container.decode(String.self, forKey: .text)
                attachments = try container.decode([Attachments].self, forKey: .attachments)
            }

            struct Attachments: Decodable {
                var type: String
                var photo: Photo?
                var link: Link?

                struct Photo: Decodable {
                    var sizes: [Sizes]

                    struct Sizes: Decodable {
                        var url: String
                    }
                }

                struct Link: Decodable {
                    var photo: LinkPhoto
                    
                    struct LinkPhoto: Decodable {
                        var sizes: [Sizes]

                        struct Sizes: Decodable {
                            var url: String
                        }
                    }
                }
            }
        }
        
        struct Groups: Decodable {
            var id: Int
            var name: String
            var avatar: String
            
            private enum CodingKeys: String, CodingKey {
                case id
                case name
                case avatar = "photo_50"
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                id = try container.decode(Int.self, forKey: .id)
                name = try container.decode(String.self, forKey: .name)
                avatar = try container.decode(String.self, forKey: .avatar)
            }
        }
    }
}
            
//            private enum CodingKeys: String, CodingKey {
//                case ownerID = "owner_id"
//                case sizes
//            }
//
//            init(from decoder: Decoder) throws {
//                let container = try decoder.container(keyedBy: CodingKeys.self)
//
//                ownerID = try container.decode(Int.self, forKey: .ownerID)
//                sizes = try container.decode([Sizes].self, forKey: .sizes)
//            }
            
            //var sizes: [Sizes]
            
//            struct Sizes: Decodable {
//                //var height: Int
//                var url: String
//                //var type: String
//                //var width: Int
//            }



class GetNewsList {
    
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
        urlConstructor.path = "/method/newsfeed.get"
        urlConstructor.queryItems = [
            URLQueryItem(name: "owner_id", value: String(Session.instance.userId)),
            URLQueryItem(name: "access_token", value: Session.instance.token),
            URLQueryItem(name: "filters", value: "post,photo"),
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "v", value: "5.122")
        ]
              
        // задача для запуска
        let task = session.dataTask(with: urlConstructor.url!) { (data, response, error) in
            print("Запрос к API: \(urlConstructor.url!)")
            
            // в замыкании данные, полученные от сервера, мы преобразуем в json
            guard let data = data else { return }
            
            do {
                let arrayNews = try JSONDecoder().decode(NewsResponse.self, from: data)
                //print(arrayNews)
                
                var newsList: [PostNews] = []

                guard arrayNews.response.items.count != 0 else { return } // проверка на наличие новостей

                for i in 0...arrayNews.response.items.count-1 {
                    let date: String = String(arrayNews.response.items[i].date)
                    let text: String = arrayNews.response.items[i].text
                    var urlPhoto: String = ""
                    
                    if arrayNews.response.items[i].attachments.first?.type == "link" {
                        urlPhoto = arrayNews.response.items[i].attachments.first?.link?.photo.sizes.first?.url ?? ""
                        print("link")
                    }
                    if arrayNews.response.items[i].attachments.first?.type == "photo" {
                        urlPhoto = arrayNews.response.items[i].attachments.first?.photo?.sizes.last?.url ?? ""
                        print("photo")
                    }
                    
                    print("\(date)\n \(text)\n \(urlPhoto)")
                    
                    newsList.append(PostNews(name: "name", avatar: UIImage(named: "person1"), date: date, textNews: text, imageNews: UIImage(named: "news3")))
                    
                    
//                    if let urlPhoto = arrayPhotosFriend.response.items[i].sizes.last?.url {
//                        //ownerID = String(arrayPhotosFriend.response.items[i].owner_id)
//                        ownerID = String(arrayPhotosFriend.response.items[i].ownerID)
//                        photosFriend.append(Photo.init(photo: urlPhoto, ownerID: ownerID))
//                    }
                }
                
                //print(newsList)
//                DispatchQueue.main.async {
//                    RealmOperations().savePhotosToRealm(photosFriend, ownerID)
//                }
                
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
}
