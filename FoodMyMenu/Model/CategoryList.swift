//
//  CategoryList.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/09/28.
//


import Foundation

//CodableでJSONデータをencode,decodeするモデル？のような物
struct CategoryList: Codable {
    
    let result: Result
    
    struct Result:Codable {
        
        let small:[Small?]
        let medium:[Medium?]
        let large:[Large?]
        
        struct Small:Codable {
            let categoryName: String
            let parentCategoryId: String
            let categoryId: Int
            let categoryUrl: String
        }
        
        struct Medium:Codable {
            let categoryName: String
            var parentCategoryId: String
            let categoryId: Int
            let categoryUrl: String
        }
        
        struct Large:Codable {
            let categoryName: String
            let categoryId: String
            let categoryUrl: String
        }
        
    }

}
