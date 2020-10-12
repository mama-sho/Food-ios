//
//  DetailViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/11.
//

import UIKit
import SDWebImage

class DetailViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    //値を受け取る変数を用意
    var imageString:String = String()
    var titleString:String = String()
    var cost:String = String()
    var material:String = String()
    var makeMahod:String = String()
    var time:String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.isEditable = false
        
        imageView.sd_setImage(with: URL(string: imageString), completed: nil)
        timeLabel.text = time
        costLabel.text = cost
        titleLabel.text = titleString
        textView.text = "-材料-\n" + material + "\n\n-作り方-\n" + makeMahod
        
    }
    
    
    
    //各種画面遷移
    @IBAction func searchButton(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "SearchFoodVC")
        nextVC?.modalTransitionStyle = .crossDissolve
        self.present(nextVC!, animated: true, completion: nil)
    }
    @IBAction func postsButton(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "PostsVC")
        nextVC?.modalTransitionStyle = .crossDissolve
        self.present(nextVC!, animated: true, completion: nil)
    }
    @IBAction func mypageButton(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "MyPageVC")
        nextVC?.modalTransitionStyle = .crossDissolve
        self.present(nextVC!, animated: true, completion: nil)
    }
    @IBAction func createButton(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "NewPostsVC")
        nextVC?.modalTransitionStyle = .crossDissolve
        self.present(nextVC!, animated: true, completion: nil)
    }
}
