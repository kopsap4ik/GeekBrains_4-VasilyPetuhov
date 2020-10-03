//
//  PhotosFriendNode.swift
//  Client VK
//
//  Created by Василий Петухов on 02.10.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

final class PhotosFriendNode: ASCellNode {
//    ASCollectionNode
    
//    private let photoFriend: Photo
    private let photoFriend: String
    private let text: String
    
    private var photoImageNode = ASNetworkImageNode()
    private var textNode = ASTextNode()
    
    init(photoFriend: String) {
        self.photoFriend = photoFriend
        self.text = "Holla amigo!"
        
//        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        super.init()
        setupNode()
    }
    
    func setupNode() {
        photoImageNode.url = URL(string: (photoFriend))
        photoImageNode.contentMode = .scaleAspectFill
        addSubnode(photoImageNode)
        
        textNode.attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15)])
        addSubnode(textNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        photoImageNode.style.preferredSize = CGSize(width: 100, height: 100)
        
        let photoSpec = ASInsetLayoutSpec(
            insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
            child: photoImageNode)
        
        //        let photoSpec = ASCenterLayoutSpec(centeringOptions: .XY,
        //                                           sizingOptions: [],
        //                                           child: photoImageNode)
        
        let textSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: [], child: textNode)
        
        let stackV = ASStackLayoutSpec()
        stackV.direction = .vertical
        stackV.spacing = 10
        stackV.children = [photoSpec, textSpec]
        
        return stackV
    }
    
    
}
