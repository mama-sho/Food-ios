//
//  User.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/08.
//

import Foundation
import Firebase

//マイページで情報を取得する時に使う
class User {
    
    let name: String
    let email: String
    let password: String
    let ImageUrlString: String
    
    init(dic:[String:Any]) {
        self.name = dic["name"] as? String ?? ""
        self.email = dic["email"] as? String ?? ""
        self.password = dic["password"] as? String ?? ""
        self.ImageUrlString = dic["ImageURLString"] as? String ?? ""
    }
}
