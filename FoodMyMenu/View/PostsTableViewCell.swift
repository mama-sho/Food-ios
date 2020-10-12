//
//  PostsTableViewCell.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/09/26.
//

import UIKit

class PostsTableViewCell: UITableViewCell {

    @IBOutlet weak var materialTextView: UITextView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var recipeImageView: UIImageView!

    @IBOutlet weak var indicationLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
