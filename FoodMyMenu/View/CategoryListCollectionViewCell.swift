//
//  CategoryListCollectionViewCell.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/01.
//

import UIKit

class CategoryListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //cellの枠の太さ
        self.layer.borderWidth = 1.0
        //cellの枠の色
        self.layer.borderColor = UIColor.orange.cgColor
        //cellを丸くする
        self.layer.cornerRadius = 8.0
        
    }

}
