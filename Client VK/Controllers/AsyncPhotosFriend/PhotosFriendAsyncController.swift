//
//  PhotosFriendAsyncController.swift
//  Client VK
//
//  Created by Василий Петухов on 02.10.2020.
//  Copyright © 2020 Vasily Petuhov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PhotosFriendAsyncController: ASDKViewController<ASDisplayNode>, ASCollectionDelegate, ASCollectionDataSource {
    
    var collectionNode = ASCollectionNode(collectionViewLayout: UICollectionViewFlowLayout())
//    var flowLayout: UICollectionViewFlowLayout
    
    var ownerID = ""
    var collectionPhotos: [Photo] = []
        
    override init(){
//        let flowLayout = UICollectionViewFlowLayout()
//        self.collectionNode = ASCollectionNode(collectionViewLayout: flowLayout)
        super.init(node: collectionNode)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionNode.delegate = self
        self.collectionNode.dataSource = self
        
        collectionNode.view.backgroundColor = .red
        collectionNode.view.allowsSelection = true
    }
    
    // MARK:  - ASCollectionDelegate and ASCollectionDataSource
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        
        
        let cellNodeBlock = { () -> ASCellNode in
            let cellNode =  PhotosFriendNode(photoFriend: "https://d2xzmw6cctk25h.cloudfront.net/avatar/1683901/attachment/thumb-e7290cb1d247561ba9205bab27c7fe79.jpg")
//            cellNode.delegate = self
            return cellNode
          }
            
          return cellNodeBlock
        
    }
    
    
    
}
