//
//  Animation.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/09.
//

import Foundation
import Lottie

let animationView = AnimationView()

class Animation {
    
    //アニメーションを始める
    func startAnimation() {
        let animation = Animation.named("circleLoading")
        
        animationView.frame = CGRect(x: 50, y: 100,
                                     width: view.frame.size.width / 1.5, height: view.frame.size.height / 1.5)
        
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    
        view.addSubview(animationView)
    }
    
    //アニメーションをストップさせる
    func stopAnimation() {
        
        //アニメーションを消す
        animationView.removeFromSuperview()
    }
  
    
}
