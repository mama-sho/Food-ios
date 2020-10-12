//
//  RecipeList.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/02.
//

import Foundation

struct RecipeList: Codable {
    
    let result: [Result]
    
    struct Result: Codable {
        
        let foodImageUrl: String 
        let recipeDescription: String
        let recipePublishday: String
        let shop: Int
        let pickup: Int
        let recipeId: Int
        let nickname: String
        let smallImageUrl: String
        let recipeMaterial: [String]
        let recipeIndication: String
        let recipeCost: String
        let rank: String
        let recipeUrl: String
        let mediumImageUrl: String
        let recipeTitle: String
    }

}

