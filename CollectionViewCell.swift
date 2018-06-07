//
//  CollectionViewCell.swift
//  swTest2
//
//  Created by Pratyush on 2/13/18.
//  Copyright © 2018 Pratyush. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    var cocktailName: UILabel!
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height*2/3))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        contentView.addSubview(imageView)
        
        cocktailName = UILabel(frame: CGRect(x: 0, y: imageView.frame.size.height, width: frame.size.width, height: frame.size.height/3))
        //cocktailName.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        cocktailName.textAlignment = .center
        contentView.addSubview(cocktailName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
