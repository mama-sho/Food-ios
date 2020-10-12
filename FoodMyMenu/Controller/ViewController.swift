//
//  ViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/09/26.

//マルチデバイス対応方法
// storyboardで？
// プログラムで？
// オートレイアウトで？

// ER図作る
/*
 ・Firestoreを使うこと
 ・Codableを使うこと　SwityJsonは古い,
 ・UI/UXを工夫したアプリにする
 ・マルチデバイスに対応
 ・マテリアルデザインやフラットデザイン2.0を参考にし、ネイティブアプリらしく使いやすいものにする レスポンシブデザイン
 ・期限は特にないが、目安としては2週間程
 ・tableView collectionViewのカクツキの修正と、表示する場面だけを取得？するようにしてみる SDWebimage + DataSourcePrefetchingでできそう


 ・RxSwiftを使ってみる observer.observe onNext.onError ..ets
 ・いきなりログイン機能だとそれ以上やってくれないからコメントや投稿の時にログインするようにする
 ・Load中にアニメーション、プログラスバーを使ったり
 ・画面遷移おしゃれライブラリ使ってみる

 
 FireStore ドキュメント思考のNoSQLクラウド
 あえて冗長化する事で読み込みを一度だけで、処理する事がある

 Usersコレクション Userドキュメント
 Postsコレクション Postドキュメント
 
 /Users/user-1/
        name:String
        id:String
 /Posts/post/
        recipeTitle:String
        recipeId:String
 
 欲しい機能
 コメント機能
 マイページ
 メニュー
 サインイン機能
 投稿機能
 投稿物に物にいいね機能
 投稿レシピ一覧表示
 カテゴリ別検索機能
 */

import UIKit
import Firebase
import RxCocoa
import RxSwift
import RxRelay
import Lottie
import SDWebImage //SDWebimage非同期でURLから画像データを取得するために導入cellのカクツク防止

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDataSourcePrefetching{

    @IBOutlet weak var searchRecipeButton: UIButton!
    
    @IBOutlet weak var createRecipeButton: UIButton!
    
    @IBOutlet weak var MyPageButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var animationView = AnimationView()
        
    var posts = [Post]()
    
    //SDWebimagenでrefecthをするために用意
    var fetchImageURL = [URL]()
    
    //購読の破棄をするDisproBagインスタンス自身が破棄されると、その購読も破棄される。メモリーリークしないため
    let disposeBag:DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        Button_TapAction()
        //tableView
        collectionView.prefetchDataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: "PostsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PostsCell")
        
        getPostsData()
        
    }
    
    func Button_TapAction() {
        // tapイベントを検知する
        searchRecipeButton.rx.tap.subscribe(onNext: {[weak self] _ in
            self?.changeViewController(branch: 1)
        }).disposed(by: disposeBag)
        
        createRecipeButton.rx.tap.subscribe(onNext: {[weak self] _ in
            self?.changeViewController(branch: 2)
        }).disposed(by: disposeBag)
        
        MyPageButton.rx.tap.subscribe(onNext: {[weak self] _ in
            self?.changeViewController(branch: 3)
        }).disposed(by: disposeBag)
    }
    
    //画面遷移を分岐
    func changeViewController(branch:Int) {
        
        switch branch {
        case 1:
            let NextVC = self.storyboard?.instantiateViewController(identifier: "SearchFoodVC")
            NextVC?.modalTransitionStyle = .crossDissolve
            self.present(NextVC!, animated: true, completion: nil);
            break
        case 2:
            let NextVC = self.storyboard?.instantiateViewController(identifier: "NewPostsVC")
            NextVC?.modalTransitionStyle = .crossDissolve
            self.present(NextVC!, animated: true, completion: nil);
            break
        case 3:
            let NextVC = self.storyboard?.instantiateViewController(identifier: "MyPageVC")
            NextVC?.modalTransitionStyle = .crossDissolve
            self.present(NextVC!, animated: true, completion: nil)
        default:
            print("error")
        }
    }
    
    func getPostsData (){
        print("getPostsData----")
        
        startAnimation()
        let firestore = Firestore.firestore().collection("Posts")
        
        firestore.getDocuments { (snapShot, error) in
            
            if let error = error {
                print("errorドキュメントの取得に失敗しました\(error)")
                self.stopAnimation()
                return
            }
            print("ドキュメントの取得に成功しました")
            let getData = snapShot?.documents.forEach({ (snapshot) in
                let data = snapshot.data()
                
                let post = Post(dic: data)
                
                self.fetchImageURL.append(URL(string: post.imageURLString)!)
                self.posts.append(post)
            })
            
            
            self.collectionView.reloadData()
        }
    }
    
    //アニメーションを始める
    func startAnimation() {
        let animation = Animation.named("circleLoading")
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostsCell", for: indexPath) as! PostsCollectionViewCell
        
        cell.titleLabel.text = posts[indexPath.row].title
        cell.ImageView.sd_setImage(with: URL(string: posts[indexPath.row].imageURLString))
        
        return cell
    }
    
    //cellがタップされた時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("タップされました")
        let nextVC = self.storyboard?.instantiateViewController(identifier: "DetailVC") as! DetailViewController
        
        nextVC.titleString = posts[indexPath.row].title
        nextVC.time = posts[indexPath.row].indication
        nextVC.cost = posts[indexPath.row].cost
        nextVC.imageString = posts[indexPath.row].imageURLString
        nextVC.material = posts[indexPath.row].material
        nextVC.makeMahod = posts[indexPath.row].makeMethod
        
        self.present(nextVC, animated: true, completion: nil)
    }
    
    //cellが表示する前に呼ばれる
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //表示する直前でアニメーションを止めたい
        stopAnimation()
    }
    //Cellのレイアウトを調整
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        //cell同士の隙間を調整
        let horizontalSpace : CGFloat = 6
        //cellのサイズを調整
        let cellSize : CGFloat = self.view.bounds.width / 2 - horizontalSpace
        
        return CGSize(width: cellSize, height: cellSize - 30)
    }
    
    //UICollectionViewDataSourcePrefetchingのデリゲートメソッドで、
    //メインスレッド以外で処理され、リソースの取得などのセル生成の準備を早くから始める事が可能になる
    //スクロールされる方向のセルの生成の準備をしてくれるため、カクカク対策になり得る
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("prefetch--")
        SDWebImagePrefetcher.shared.prefetchURLs(fetchImageURL)
    }
    // prefetchキャンセル
    // スクロールの方向が変更された時に呼ばれる
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
 
        SDWebImagePrefetcher.shared.cancelPrefetching()
    }
}

