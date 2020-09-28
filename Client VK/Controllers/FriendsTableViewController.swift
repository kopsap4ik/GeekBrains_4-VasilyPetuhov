//
//  FriendsTableViewController.swift
//  Client VK
//
//  Created by Василий Петухов on 22.07.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift
import PromiseKit

class FriendsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        subscribeToNotificationRealm() // подписка на нотификации реалма + обновление таблицы
        
        // Обычный запуск обновления данных из сети, запись в Реалм и загрузка из реалма новых данных
        //GetFriendsList().loadData()
        
        // PromiseKit - обновления данных из сети, запись в Реалм
        GetFriendsListPromise().getData()
        
        // переработка в дженерики, нужно доработать
        //        VKService().loadData(.friends) { () in
        //        }
        
        searchBar.delegate = self
    }
    
    var realm: Realm = {
        let configrealm = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        let realm = try! Realm(configuration: configrealm)
        return realm
    }()
    
    lazy var friendsFromRealm: Results<Friend> = {
        return realm.objects(Friend.self)
    }()
    
    var notificationToken: NotificationToken?
    
    var friendsList: [Friend] = []
    var namesListFixed: [String] = [] //эталонный массив с именами для сравнения при поиске
    var namesListModifed: [String] = [] // массив с именами меняется (при поиске) и используется в таблице
    var letersOfNames: [String] = []
    
    
    // MARK: - TableView
    
    // количество секций
    override func numberOfSections(in tableView: UITableView) -> Int {
        return letersOfNames.count
    }
    
    // настройка хедера ячеек и добавление букв в него
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3) // прозрачность только хедера
        
        let leter: UILabel = UILabel(frame: CGRect(x: 30, y: 5, width: 20, height: 20))
        leter.textColor = UIColor.black.withAlphaComponent(0.5)  // прозрачность только надписи
        leter.text = letersOfNames[section]
        leter.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light)
        header.addSubview(leter)
        
        return header
    }
    
    // список букв для навигации (справа контрол)
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return letersOfNames
    }
    
    // количество ячеек в секции
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var countOfRows = 0
        // сравниваем массив букв и заглавные буквы каждого имени, выводим количество ячеек в соотвествии именам на отдельную букву
        for name in namesListModifed {
            if letersOfNames[section].contains(name.first!) {
                countOfRows += 1
            }
        }
        return countOfRows
    }
    
    // запонение ячеек
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // получить ячейку класса FriendTableViewCell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as! FriendsTableViewCell
        
        let friendInfo = getFriendInfoForCell(indexPath) //текущий друг по indexPath
        
        //Имя друга
        cell.nameFriendLabel.text = friendInfo.name
        
        //Аватар друга
        guard let imgUrl = friendInfo.avatar else { return cell }
        let avatar = ImageResource(downloadURL: imgUrl) //работает через Kingfisher
        cell.avatarFriendView.avatarImage.kf.indicatorType = .activity
        cell.avatarFriendView.avatarImage.kf.setImage(with: avatar)
        
        // работает через extension UIImageView
        //        cell.avatarFriendView.avatarImage.load(url: imgUrl)
        
        
        // старая реализация
        // задать имя пользователя (ищет по буквам для расстановки по секциям) + сортировка по алфавиту
        //        cell.nameFriendLabel.text = getNameFriendForCell(indexPath)
        //print(indexPath)
        
        //        let name = self.getNameFriendForCell(indexPath)
        //        cell.nameFriendLabel.text = name
        
        //задать аватар для друга (грузит по ссылке: 2 способа)
        //        guard let imgUrl = getAvatarFriendForCell(indexPath) else { return cell }
        //        let avatar = ImageResource(downloadURL: imgUrl) //работает через Kingfisher
        //        cell.avatarFriendView.avatarImage.kf.indicatorType = .activity
        //        cell.avatarFriendView.avatarImage.kf.setImage(with: avatar)
        //        cell.avatarFriendView.avatarImage.load(url: imgUrl) // работает через extension UIImageView
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // кратковременное подсвечивание при нажатии на ячейку
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Functions
    
    //тестовая функция для отображения времени
    //    func printTime() {
    //        let d = Date()
    //        let df = DateFormatter()
    //        df.dateFormat = "mm:ss.SSSS"
    //
    //        print(df.string(from: d))
    //    }
    
    private func subscribeToNotificationRealm() {
        notificationToken = friendsFromRealm.observe { [weak self] (changes) in
            switch changes {
            case .initial:
                self?.loadFriendsFromRealm()
            //case let .update (_, deletions, insertions, modifications):
            case .update:
                self?.loadFriendsFromRealm()
            case let .error(error):
                print(error)
            }
        }
    }
    
    func loadFriendsFromRealm() {
        friendsList = Array(friendsFromRealm).sorted{ $0.userName < $1.userName }
        guard friendsList.count != 0 else { return } // проверка, что в реалме что-то есть
        makeNamesList()
        sortCharacterOfNamesAlphabet()
        tableView.reloadData()
    }
    
    // создание массива из имен пользователей
    func makeNamesList() {
        namesListFixed.removeAll()
        for item in 0...(friendsList.count - 1){
            namesListFixed.append(friendsList[item].userName)
        }
        namesListModifed = namesListFixed//.sorted() //сортировка лишняя
    }
    
    // созданием массива из начальных букв имен пользователй по алфавиту
    func sortCharacterOfNamesAlphabet() {
        var letersSet = Set<Character>()
        letersOfNames = [] // обнуляем массив на случай повторного использования
        
        // создание сета <Character> из первых букв имени, чтобы не было повторов
        for name in namesListModifed {
            letersSet.insert(name[name.startIndex])
        }
        
        // заполнение массива из букв имен
        for leter in letersSet.sorted() {
            letersOfNames.append(String(leter))
        }
    }
    
    func getFriendInfoForCell(_ indexPath: IndexPath) -> (name: String, avatar: URL?, ownerID: String) {
        var friendInfo: [(name: String, avatar: URL?, ownerID: String)] = []
        let letter = letersOfNames[indexPath.section]
        
        for friend in friendsList {
            if letter.contains(friend.userName.first!){
                let name = friend.userName
                let avatar = URL(string: friend.userAvatar)
                let ownerID = friend.ownerID
                
                friendInfo.append((name, avatar, ownerID))
            }
        }
        
        return friendInfo[indexPath.row]
    }
    
    
    //    func getNameFriendForCell(_ indexPath: IndexPath) -> String {
    //        var namesArray = [String]()
    //        let letter = letersOfNames[indexPath.section]
    //
    //        for name in namesListModifed {
    //            if letter.contains(name.first!) {
    //                namesArray.append(name)
    //            }
    //        }
    //        return namesArray[indexPath.row]
    //    }
    //
    //    func getAvatarFriendForCell(_ indexPath: IndexPath) -> URL? {
    //        let namesArray = getNameFriendForCell(indexPath)
    //        for friend in friendsList {
    //            if friend.userName.contains(namesArray) {
    //                return URL(string: friend.userAvatar)
    //            }
    //        }
    //        return nil
    //    }
    //
    //    func getIDFriend(_ indexPath: IndexPath) -> String {
    //        var ownerIDs = ""
    //        let namesArray = getNameFriendForCell(indexPath)
    //        for friend in friendsList {
    //            if friend.userName.contains(namesArray) {
    //                ownerIDs = friend.ownerID
    //            }
    //        }
    //        return ownerIDs
    //    }
    
    
    // MARK: - SearchBar
    
    // поиск по именам
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        namesListModifed = searchText.isEmpty ? namesListFixed : namesListFixed.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        sortCharacterOfNamesAlphabet() // создаем заново массив заглавных букв для хедера
        tableView.reloadData()
    }
    
    // отмена поиска (через кнопку Cancel)
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true // показыть кнопку Cancel
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false // скрыть кнопку Cancel
        searchBar.text = nil
        makeNamesList() // возвращаем массив имен
        sortCharacterOfNamesAlphabet()  // создаем заново массив заглавных букв для хедера
        tableView.reloadData() //обновить таблицу
        searchBar.resignFirstResponder() // скрыть клавиатуру
    }
    
    
    // MARK: - Segue
    
    // переход на экран с коллекцией фоток + передача фоток конкретного пользователя
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showListUsersPhoto"{
            // ссылка объект на контроллер с которого переход
            guard let friend = segue.destination as? PhotosFriendCollectionViewController else { return }
            
            // индекс нажатой ячейки
            if let indexPath = tableView.indexPathForSelectedRow {
                let friendInfo = getFriendInfoForCell(indexPath)
                friend.title = friendInfo.name //тайтл экрана (имя пользователя)
                friend.ownerID = friendInfo.ownerID
            }
        }
    }
    
    
}
