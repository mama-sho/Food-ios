//
//  PostsCollectionViewCell.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/10.
//

import UIKit

class PostsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ImageView.layer.cornerRadius = 10.0
    }

}
