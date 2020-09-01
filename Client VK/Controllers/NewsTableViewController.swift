//
//  NewsTableViewController.swift
//  Client VK
//
//  Created by Василий Петухов on 25.05.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    var postNewsList = [
        PostNews(name: "Victor", avatar: UIImage(named: "person1"), date: "Вчера в 17:19", textNews: "Променял Восстала исчезнет Чтя Как муж ков вер милосерд нарекший. Достояние развратом наполняет. Враждебен скрежетом примирить румянятся порицаний склонился. Им Ко Со от Уж То те Ах. Но Со цельна Свлеки Единым то До Ты Ея об. Корысть родимся радеешь Встанет болотна Молитвы.", textImage: UIImage(named: "news1")),
        PostNews(name: "Валентин", avatar: UIImage(named: "person2"), date: "14.02.2020 в 17:19", textNews: "Пламенея белизною вниманья истреблю Каратель резвятся. Ослепляет Трепещущи возвестит ему Зря лицемерья тук сим над дев. До Во Из Им ах об. . Да Ее об Он Тя вы не яд. Он тягчайший Евпраксия ах светлеясь мя Им смертного. Оно умиленье избранна созвучны вам зло бог тул воссесть льстецов скрыться. Наших место думаю потек. Муж морских Явилась стареем Величия или зло род ссужает. Своим Ее ли Забыв бы людей Вы забыл.", textImage: UIImage(named: "news2")),
        PostNews(name: "Турин", avatar: UIImage(named: "person3"), date: "27.02.2019 в 17:19", textNews: "Is education residence conveying so so. Suppose shyness say ten behaved morning had. Any unsatiable assistance compliment occasional too reasonably advantages. Unpleasing has ask acceptance partiality alteration understood two. Worth no tiled my at house added. Married he hearing am it totally removal. Remove but suffer wanted his lively length. Moonlight two applauded conveying end direction old principle but. Are expenses distance weddings perceive strongly who age domestic.", textImage: UIImage(named: "news3")),
        PostNews(name: "Victor", avatar: UIImage(named: "person1"), date: "Вчера в 17:19", textNews: "", textImage: UIImage(named: "news1")),
        PostNews(name: "Валентин", avatar: UIImage(named: "person2"), date: "14.02.2020 в 17:19", textNews: "", textImage: UIImage(named: "news2")),
        PostNews(name: "Турин", avatar: UIImage(named: "person3"), date: "27.02.2019 в 17:19", textNews: "", textImage: UIImage(named: "news3"))
        ]
    
//    var photoNewsList = [
//        PhotoNews(name: "Victor", avatar: UIImage(named: "person1"), date: "Вчера в 17:19", textImage: UIImage(named: "news1")),
//        PhotoNews(name: "Валентин", avatar: UIImage(named: "person2"), date: "14.02.2020 в 17:19", textImage: UIImage(named: "news2")),
//        PhotoNews(name: "Турин", avatar: UIImage(named: "person3"), date: "27.02.2019 в 17:19", textImage: UIImage(named: "news3"))
//    ]


    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postNewsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String
        
        if postNewsList[indexPath.row].textNews.isEmpty {
            identifier = "PhotoCell"
            print(identifier)
        } else {
            identifier = "PostCell"
            print(identifier)
        }
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NewsTableViewCell
        //let  cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! NewsTableViewCell
        
        // аватар
        cell.avatarUserNews.avatarImage.image = postNewsList[indexPath.row].avatar
        // имя автора
        cell.nameUserNews.text = postNewsList[indexPath.row].name
        // дата новости
        cell.dateNews.text = postNewsList[indexPath.row].date
        cell.dateNews.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        cell.dateNews.textColor = UIColor.gray.withAlphaComponent(0.5)
        //текст новости
        //cell.textNews.text = postNewsList[indexPath.row].textNews
        //cell.textNews.numberOfLines = 0
        
        if identifier == "PostCell" {
        cell.textNewsPost.text = postNewsList[indexPath.row].textNews
        }
        
        //картинка к новости
        cell.imgNews.image = postNewsList[indexPath.row].textImage
        cell.imgNews.contentMode = .scaleAspectFill

        return cell
    }

}
