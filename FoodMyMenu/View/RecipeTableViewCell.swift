//
//  RecipeTableViewCell.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/02.
//

//    var foodImageUrl = [String]()
//    var recipeDescription = [String]()
//    var recipeId = [Int]()
//    var nickname = [String]()
//    var recipeMaterial = [[String]]()
//    var recipeIndication = [String]()
//    var recipeCost = [String]()
//    var recipeUrl = [String]()
//    var recipeTitle = [String]()
//
//    var categoryTitle1 = String()
//    var categoryTitle2 = String()
//    var categoryTitle3 = String()

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var RecipeNameLabel: UILabel!
    
    @IBOutlet weak var RecipeDescriptionLabel: UILabel!
    
    @IBOutlet weak var RecipeIndicationLabel: UILabel!
    
    @IBOutlet weak var RecipeCostLabel: UILabel!
    
    @IBOutlet weak var materialTextView: UITextView!
    
    @IBOutlet weak var RecipeImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
