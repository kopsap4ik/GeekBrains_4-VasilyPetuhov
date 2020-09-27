//
//  NewsTableViewController.swift
//  Client VK
//
//  Created by Василий Петухов on 25.05.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl() // подгрузка новых новостей свайпом вниз
        tableView.prefetchDataSource = self // для подгрузки новостей снизу
        loadNews() // загрузка новостей из сети/парсинг
    }
    
    lazy var getNewsListSwiftyJSON = GetNewsListSwiftyJSON()
    lazy var imageCache = ImageCache(container: self.tableView)
    var postNewsList: [News] = []
    
    var nextNewsID = ""
    var isLoadingNews = false // активна ли загрузка новостей
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return df
    }()
    
    // MARK:  - Загрузка новостей
    
    func loadNews(){
        // Decodable - GetNewsList
        //        GetNewsList().loadData { [weak self] (complition) in
        //                self?.postNewsList = complition
        //                self?.tableView.reloadData()
        //        }
        
        
        // SwiftyJSON - GetNewsListSwiftyJSON
        getNewsListSwiftyJSON.get { [weak self] (news, nextFromID) in
            self?.postNewsList = news
            self?.nextNewsID = nextFromID
            self?.tableView.reloadData()
        }
    }
    
    // MARK:  - Свайп вниз для обновления новостей
    private func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Новости загружаются...")
        refreshControl?.tintColor = .gray
        refreshControl?.addTarget(self, action: #selector(refreshNewsList), for: .valueChanged)
        //tableView.addSubview(refreshControl!)
    }
    
    @objc private func refreshNewsList() {
        if let dateFrom = postNewsList.first?.date {
            let timestamp = dateFormatter.date(from: dateFrom)?.timeIntervalSince1970 ?? Date().timeIntervalSince1970
            
            // SwiftyJSON - GetNewsListSwiftyJSON + время с которого нужно загрузить данные
            getNewsListSwiftyJSON.get(newsFrom: timestamp + 1) { [weak self] (latestNews, _) in
                guard let strongSelf = self else { return }
                guard latestNews.count > 0 else { return }
                strongSelf.postNewsList = latestNews + strongSelf.postNewsList
                
                //strongSelf.tableView.reloadData() //перезагружать всю таблицу не лучший вариант
                
                // добавляем новые ячейки в начало таблицы по вычисленным [indexPaths] из количества новостей
                let indexPaths = (0..<latestNews.count)
                    .map{ IndexPath(row: $0, section: 0) }
                strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
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
    
    // MARK:  - Загрузка дополнительных новостей снизу (бесконечный скролл)
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard
            isLoadingNews == false, //если уже грузятся новости, то заново их не нужно загружать
            let maxRow = indexPaths.map({ $0.row }).max(), //максимальное количество ячеек таблицы
            maxRow > (postNewsList.count - 3) // указание на какой ячейке начинать подгрузку новостей
        else { return }
        
        isLoadingNews = true // ВКЛ флаг загрузки
        
        getNewsListSwiftyJSON.get(nextPageNews: nextNewsID) { [weak self] (nextNews, nextFromID) in
            guard let strongSelf = self else { return }
            
            let newsCount = strongSelf.postNewsList.count // текущее количество новостей
            strongSelf.postNewsList.append(contentsOf: nextNews) // добавить следующие новости в общий список
            
            // добавляем новые ячейки в конец таблицы по вычисленным [indexPaths] от количества полученных следующих новостей
            let indexPaths = (newsCount..<(newsCount + nextNews.count))
                .map{ IndexPath(row: $0, section: 0) }
            
            strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
            strongSelf.nextNewsID = nextFromID
            strongSelf.isLoadingNews = false  // ВЫКЛ флаг загрузки
        }
        
        
    }
    
}
