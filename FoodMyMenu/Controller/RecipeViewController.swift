//
//  RecipeViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/02.
//

//カテゴリランキングAPi

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import Lottie

//非同期でurlから画像を取得するため
import SDWebImage

class RecipeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITableViewDataSourcePrefetching {
    
    var foodImageUrl = [URL]()
    var recipeDescription = [String]()
    var recipeId = [Int]()
    var nickname = [String]()
    var recipeMaterial = [[String]]()
    var recipeIndication = [String]()
    var recipeCost = [String]()
    var recipeUrl = [String]()
    var recipeTitle = [String]()
    
    var categoryTitle1 = String()
    var categoryTitle2 = String()
    var categoryTitle3 = String()
    
    var categoryId = ""
    var APIID = ""
    
    var selectUrl = ""
    
    var disposeBag = DisposeBag()
    
    var animationView = AnimationView()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    //画像を非同期で取得
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        SDWebImagePrefetcher.shared.prefetchURLs(foodImageUrl)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        SDWebImagePrefetcher.shared.cancelPrefetching()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "RecipeTableCell")
        
        searchRecipe()
        searchRecipeRX()
    }
    
    func searchRecipe() -> Observable<RecipeList>{
        
        print("serrchRecipe")
        startAnimation()

        //APiを叩く
        let url = URL(string: "https://app.rakuten.co.jp/services/api/Recipe/CategoryRanking/20170426?format=json&categoryId=\(categoryId)&applicationId=\(APIID)")

        let request = URLRequest(url:url!)
        
        return Observable<RecipeList>.create({observe in
            let task = URLSession.shared.dataTask(with: request) {data, response, error in
                if let error = error {
                    observe.onError(error)
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(RecipeList.self,from: data!)
                    observe.onNext(decodedData)
                } catch (let e){
                    observe.onError(e)
                }
                
            }
            task.resume()
            return Disposables.create()
        })
    }
    
    func searchRecipeRX() {
        searchRecipe().subscribe(onNext: {response in
            
            let data = response.result

            //配列に格納
            for i in 0 ..< data.count {
                self.foodImageUrl.append(URL(string: data[i].foodImageUrl)!)
                self.recipeDescription.append(data[i].recipeDescription)
                self.recipeId.append(data[i].recipeId)
                self.nickname.append(data[i].nickname)
                self.recipeMaterial.append(data[i].recipeMaterial)
                self.recipeIndication.append(data[i].recipeIndication)
                self.recipeCost.append(data[i].recipeCost)
                self.recipeUrl.append(data[i].recipeUrl)
                self.recipeTitle.append(data[i].recipeTitle)
            }
            
            //メインスレッドで実行する。UIの変更など
            DispatchQueue.main.async {
                print(self.recipeTitle)
                self.tableView.reloadData()
                self.stopAnimation()
            }
            
        },onError: { error in
            print(error)
        },onCompleted: {
            print("onCompleted")
        },onDisposed: {
            print("onDisposed")
        }).disposed(by: disposeBag)
    }
     
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeId.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 308
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableCell") as! RecipeTableViewCell
        
        //cellを編集
        cell.RecipeNameLabel.text = recipeTitle[indexPath.row]
        cell.RecipeDescriptionLabel.text = recipeDescription[indexPath.row]
        cell.RecipeCostLabel.text = recipeCost[indexPath.row]
        cell.RecipeIndicationLabel.text = recipeIndication[indexPath.row]
        cell.RecipeImageView.sd_setImage(with: foodImageUrl[indexPath.row], completed: nil)
        
        let material = recipeMaterial[indexPath.row]
        var materialSingle = ""
        for i in 0 ..< material.count {
            materialSingle = materialSingle + ", " + material[i]
        }
        
        cell.materialTextView.text = materialSingle
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectUrl = recipeUrl[indexPath.row]
        performSegue(withIdentifier: "WebViewSegue", sender: self)
    }
    
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  
        if segue.identifier == "WebViewSegue" {
            let nextVC: WebViewKitController = segue.destination as! WebViewKitController
            
            nextVC.url = selectUrl
        }
    }
    
    //アニメーションを始める
    func startAnimation() {
        let animation = Animation.named("loading")
        
        animationView.frame = CGRect(x: 70, y: 100,
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
