//
//  SearchFoodNext2ViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/03.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class SearchFoodNex2tViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    
    var label1Text = String()
    var label2Text = String()
    var label3Text = String()
    
    var parrentID = String()
    var parrent2ID = String()
    var parrent3ID = String()
    
    var disposeBag = DisposeBag()
    
    var categoryId:[Int] = []
    var categoryName:[String] = []
    
    let layout = UICollectionViewFlowLayout()
    
    var selectTitle = String()
    
    var ID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

        // labelを編集
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.cornerRadius = 3
        label.text = label1Text
        
        label2.layer.borderWidth = 1
        label2.layer.borderColor = UIColor.black.cgColor
        label2.layer.cornerRadius = 3
        label2.text = label2Text
        
        label3.layer.borderWidth = 1
        label3.layer.borderColor = UIColor.black.cgColor
        label3.layer.cornerRadius = 3
     
    }
    
    //監視される
    func fetchDataRX() -> Observable<CategoryList> {

        let url = URL(string: "https://app.rakuten.co.jp/services/api/Recipe/CategoryList/20170426?format=json&categoryType=small&applicationId=\(ID)")

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
            
            let smallData = response.result.small
            
            let smallFilterData = smallData.filter{
                $0?.parentCategoryId == self.parrent2ID
            }
            
            for i in 0 ..< smallFilterData.count{
                self.categoryId.append(smallFilterData[i]!.categoryId)
                self.categoryName.append(smallFilterData[i]!.categoryName)
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
        if segue.identifier == "returnSegue"{
            //遷移先のインスタンスをsegueから取り出す
            let nextVC: SearchFoodNextViewController = segue.destination as! SearchFoodNextViewController
            //値を渡す
            nextVC.parrentID = self.parrentID
            nextVC.ID = self.ID
            nextVC.label1Text = self.label1Text
        } else if segue.identifier == "RecipeSegue" {
            
            let nextVC: RecipeViewController = segue.destination as! RecipeViewController
            //値を渡す
            nextVC.APIID = self.ID
            nextVC.categoryTitle3 = label3Text
            let AllCategoryId = parrentID + "-" + parrent2ID + "-" + parrent3ID
            nextVC.categoryId = AllCategoryId
            
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
        
        label3Text = categoryName[indexPath.row]
        parrent3ID = String(categoryId[indexPath.row])
        
        performSegue(withIdentifier: "RecipeSegue", sender: self)
        
    }
    //Cellのレイアウトを調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //cell同士の隙間を調整
        let horizontalSpace : CGFloat = 20
        //cellのサイズを調整
        let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    @IBAction func returnButton(_ sender: Any) {
        //segueで画面遷移
        performSegue(withIdentifier: "returnSegue", sender: self)
    }
    
}

