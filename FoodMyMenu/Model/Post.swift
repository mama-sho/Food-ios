//
//  Post.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/09.
//

import Foundation

class Post {
    
    var title = String()
    var material = String()
    var imageURLString = String()
    var cost = String()
    var indication = String()
    var makeMethod = String()
    
    init(dic: [String:Any]) {
        
        self.title = dic["title"] as? String ?? ""
        self.material = dic["material"] as? String ?? ""
        self.imageURLString = dic["imageUrlString"] as? String ?? ""
        self.cost = dic["cost"] as? String ?? ""
        self.indication = dic["indication"] as? String ?? ""
        self.makeMethod = dic["makeMethod"] as? String ?? ""
    }
}
