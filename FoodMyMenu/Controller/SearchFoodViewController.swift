//
//  SearchFoodViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/09/27.
//


/*
 CodableでJSON解析
 URLSesstionで叩く
 RxSwiftを使ってみる
 */


import UIKit
import RxSwift
import RxCocoa
import RxRelay

class SearchFoodViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var disposeBag = DisposeBag()
    
    var categoryId:[String] = []
    var categoryName:[String] = []
    
    var selectTitle = String()
    var selectCategforyId = String()
    
    var ID = ""
    
    let layout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        KeyGet()
        //URLsessionでリクエスト、CodableでJSONm解析
        fetchDataRX()
        obserberAPI()
        
        //collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "CategoryListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "categoryCell")
        //collectionViewのlayoutの調整
        layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
        
    }
    
    func KeyGet() {
        //.plistからKeyを取得
        let filePath = Bundle.main.path(forResource: "Key", ofType: "plist")
        let plist = NSDictionary(contentsOfFile: filePath!)
        ID = plist!["Rakuten_App_ID"] as! String
    }
    
    //監視される
    func fetchDataRX() -> Observable<CategoryList> {

        let url = URL(string: "https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&categoryType=large&applicationId=\(ID)")

        let request = URLRequest(url:url!)
        
        return Observable<CategoryList>.create({observable in
            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                if let error = error {
                    observable.onError(error)
                }
                //メソッドが成功した時にdoに流れる
                do {
                    let decodedData = try JSONDecoder().decode(CategoryList.self,from: data!)
                    observable.onNext(decodedData)
                } catch(let e) {
                    observable.onError(e)
                }
            }
            task.resume()
            return Disposables.create()
        })
    }
    
    //購読する
    func obserberAPI() {
        fetchDataRX().subscribe(onNext:{response in
            
            let largeData = response.result.large
            print(largeData.count)
            
            for i in 0 ..< largeData.count{
                self.categoryId.append(largeData[i]!.categoryId)
                self.categoryName.append(largeData[i]!.categoryName)
            }
            //メインスレッドで実行する。UIの変更など
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        },onError: {error in
            print(error.localizedDescription)
        },onCompleted: {
            print("Completed")
        },onDisposed: {
            print("Disposed")
        }).disposed(by: disposeBag)
    }
    
    //segueで画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 処理を実行したいsegueを指定
        if segue.identifier == "nextSearchSegue"{
            //遷移先のインスタンスをsegueから取り出す
            let nextVC: SearchFoodNextViewController = segue.destination as! SearchFoodNextViewController
            //値を渡す
            nextVC.label1Text = selectTitle
            nextVC.ID = ID
            nextVC.parrentID = selectCategforyId
        }
    }
    
    //cellの数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryName.count
    }
    
    //cellの生成
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CategoryListCollectionViewCell
        
        cell.label.text = categoryName[indexPath.row]
        
        return cell
    }
    
    //cellがタップされた時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectTitle = categoryName[indexPath.row]
        print(selectTitle)
        selectCategforyId = categoryId[indexPath.row]
        //segueで画面遷移
        performSegue(withIdentifier: "nextSearchSegue", sender: self)
        
    }
    //Cellのレイアウトを調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //cell同士の隙間を調整
        let horizontalSpace : CGFloat = 20
        //cellのサイズを調整
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        
        print(cellSize)
        
        return CGSize(width: cellSize, height: cellSize)
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
