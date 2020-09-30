//
//  NewsTableViewCell.swift
//  Client VK
//
//  Created by Василий Петухов on 25.05.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarUserNews: AvatarsView!
    @IBOutlet weak var nameUserNews: UILabel!
    @IBOutlet weak var dateNews: UILabel!
    //@IBOutlet weak var textNews: UILabel!
    @IBOutlet weak var textNewsPost: UITextView!
    @IBOutlet weak var textNewsPostHeight: NSLayoutConstraint!
    @IBOutlet weak var showMore: UIButton!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var likesCount: LikeControl!
    @IBOutlet weak var commentsCount: UIButton!
    @IBOutlet weak var repostsCount: UIButton!
    @IBOutlet weak var viewsCount: UIButton!
    
    @IBAction func showMore(_ sender: Any) {
        
        let size = textNewsPost.frame.size.height
        if size == 200.5 {
            textNewsPost.adjustUITextViewHeightToFit()
            showMore.setTitle("Показать меньше...", for: .normal)
        } else {
            textNewsPost.adjustUITextViewHeightToDefault()
            showMore.setTitle("Показать полностью...", for: .normal)
        }
        //textNewsPost.heightAnchor.constraint(equalToConstant: 400)
        
        //textNewsPost.translatesAutoresizingMaskIntoConstraints = false
        //textNewsPost.isScrollEnabled = false
        //textNewsPostHeight.constant = 500 //textNewsPost.contentSize.height
        
//        textNewsPost.translatesAutoresizingMaskIntoConstraints = true
//        textNewsPost.sizeToFit()
//        textNewsPost.isScrollEnabled = false
//        textNewsPost.translatesAutoresizingMaskIntoConstraints = false
//        showMore.isHidden = true
    }
    
    func resetStateButtonShowMore() {
        showMore.isHidden = false
        showMore.setTitle("Показать полностью...", for: .normal)
    }
}

extension UITextView {
    func adjustUITextViewHeightToFit() {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.sizeToFit()
//        self.isScrollEnabled = false
    }
    
    func adjustUITextViewHeightToDefault() {
        self.translatesAutoresizingMaskIntoConstraints = false
//        self.sizeToFit()
//        self.isScrollEnabled = true
    }
}
