//
//  NewsTableViewController.swift
//  Client VK
//
//  Created by Василий Петухов on 25.05.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRefreshControl()
        
        // Decodable - GetNewsList
//        GetNewsList().loadData { [weak self] (complition) in
//                self?.postNewsList = complition
//                self?.tableView.reloadData()
//        }
        
        // SwiftyJSON - GetNewsListSwiftyJSON
        getNewsListSwiftyJSON.get { [weak self] (complition) in
                self?.postNewsList = complition
                self?.tableView.reloadData()
        }
        
    }
    
    lazy var getNewsListSwiftyJSON = GetNewsListSwiftyJSON()
    lazy var imageCache = ImageCache(container: self.tableView)
    var postNewsList: [News] = []

    // MARK:  - Свайп вниз для обновления новостей
    
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Новости загружаются...")
        refreshControl?.tintColor = .blue
        refreshControl?.addTarget(self, action: #selector(refreshNewsList), for: .valueChanged)
        //tableView.addSubview(refreshControl!)
    }

    
    @objc private func refreshNewsList() {
        
        let dateFormatter: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "dd.MM.yyyy HH.mm"
            return df
        }()
        
        if let dateFrom = postNewsList.first?.date {
            let timestamp = dateFormatter.date(from: dateFrom)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
            
            // SwiftyJSON - GetNewsListSwiftyJSON + время с которого нужно загрузить данные
            getNewsListSwiftyJSON.get(from: timestamp + 10) { [weak self] (complition) in
                guard let strongSelf = self else { return }
                print(complition)
                strongSelf.postNewsList = complition + strongSelf.postNewsList
                strongSelf.tableView.reloadData()
            }
        }
        
        self.refreshControl?.endRefreshing() //останавливаем контрол
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postNewsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier: String
        
        if postNewsList[indexPath.row].textNews.isEmpty {
            identifier = "PhotoCell"
        } else {
            identifier = "PostCell"
        }
        
        let  cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NewsTableViewCell
        
        // аватар работает через extension UIImageView
        //guard let avatarUrl = URL(string: postNewsList[indexPath.row].avatar ) else { return cell }
        //cell.avatarUserNews.avatarImage.load(url: avatarUrl)
        
        // аватар работает через кэш в ImageCache
        cell.avatarUserNews.avatarImage.image = imageCache.getPhoto(at: indexPath, url: postNewsList[indexPath.row].avatar)
        
        // имя автора
        cell.nameUserNews.text = postNewsList[indexPath.row].name
        
        // дата новости
        cell.dateNews.text = postNewsList[indexPath.row].date
        cell.dateNews.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        cell.dateNews.textColor = UIColor.gray.withAlphaComponent(0.5)
        
        // лайки
        cell.likesCount.countLikes = postNewsList[indexPath.row].likes // значение для счетчика
        cell.likesCount.labelLikes.text = String(postNewsList[indexPath.row].likes) // вывод количества лайков
        
        // комментарии
        cell.commentsCount.setTitle(String(postNewsList[indexPath.row].comments), for: .normal)
        
        // репосты
        cell.repostsCount.setTitle(String(postNewsList[indexPath.row].reposts), for: .normal)
        
        // просмотры
        cell.viewsCount.setTitle(String(postNewsList[indexPath.row].views), for: .normal)
        
        // текст новости
        if identifier == "PostCell" {
            cell.textNewsPost.text = postNewsList[indexPath.row].textNews
        }
        
        //картинка к новости
        guard let imgUrl = URL(string: postNewsList[indexPath.row].imageNews ) else { return cell }
        cell.imgNews.image = UIImage(systemName: "icloud.and.arrow.down") // обнулить картинку
        cell.imgNews.load(url: imgUrl) // работает через extension UIImageView
        cell.imgNews.contentMode = .scaleAspectFill

        return cell
    }

}
