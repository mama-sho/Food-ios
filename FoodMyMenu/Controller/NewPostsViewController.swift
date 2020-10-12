//
//  NewPostsViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/06.
//


import UIKit
import Firebase
import Lottie

class NewPostsViewController: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var indicationTextField: UITextField!
    
    @IBOutlet weak var costTextField: UITextField!
    
    @IBOutlet weak var materialTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var makeMethodTextView: UITextView!
    
    @IBOutlet weak var imagecoverButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    
    var fieldJatch = false
    
    var animationView = AnimationView()
    var alertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //UIの設定
        
        materialTextView.layer.borderWidth = 1.0
        materialTextView.layer.borderColor = UIColor.orange.cgColor
        materialTextView.layer.cornerRadius = 5.0
        materialTextView.layer.masksToBounds = true

        makeMethodTextView.layer.borderWidth = 1.0
        makeMethodTextView.layer.borderColor = UIColor.orange.cgColor
        makeMethodTextView.layer.cornerRadius = 5.0
        makeMethodTextView.layer.masksToBounds = true
        makeMethodTextView.delegate = self
        
        titleTextField.delegate = self
        indicationTextField.delegate = self
        costTextField.delegate = self
        titleTextField.layer.borderColor = UIColor.orange.cgColor
        titleTextField.layer.borderWidth = 1
        indicationTextField.layer.borderColor = UIColor.orange.cgColor
        indicationTextField.layer.borderWidth = 1
        costTextField.layer.borderColor = UIColor.orange.cgColor
        costTextField.layer.borderWidth = 1
         
        createButton.layer.cornerRadius = 10
        createButton.layer.shadowColor = UIColor.black.cgColor
        createButton.layer.shadowOpacity = 0.5
        createButton.layer.shadowRadius = 3
        createButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        
        //キーボードが開く時
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //キーボードが閉じる時
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        AuthCheck()
    }
    
    func AuthCheck() {
        //認証すみかどうかわかる
        if Auth.auth().currentUser?.uid == nil {
            print("認証済ではないので、AuthViewに遷移します")
            let NextVC = self.storyboard?.instantiateViewController(identifier: "AuthVC")
            self.present(NextVC!, animated: true, completion: nil)
        }
    }
    
    //storage & Firestoreに保存
    @IBAction func createButton(_ sender: Any) {

        if titleTextField.text == nil || costTextField.text == nil || indicationTextField.text == nil || materialTextView.text == nil || makeMethodTextView.text == nil || imageView.image == nil {
            alert(title: "登録できませんでした", message: "未入力の項目があります!")
            return
        }
        
        startAnimation()
        
        let imageData = imageView.image?.jpegData(compressionQuality: 0.1)
        
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("postImage").child(filename)
        //メタデータを設定
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        
        //ストレージに画像を保存
        storageRef.putData(imageData!,metadata: metaData) { (metaData, err) in
            if let err = err {
                print("ストレージに画像を保存できませんでした: \(err)")
                self.stopAnimation()
                self.alert(title: "投稿に失敗しました", message: "ごめんなさい")
                return
            }
            print("画像の保存に成功しました")
            
            //保存した画像のURLを取得する
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    print("URLの取得に失敗しました: \(error)")
                    self.stopAnimation()
                    self.alert(title: "投稿に失敗しました", message: "ごめんなさい")
                    return
                }
                
                guard let urlString = url?.absoluteString else { return }
                print("urlString: \(urlString)")
                self.firestoreCreate(urlString: urlString)
            }
        }
        
    }
    
    func firestoreCreate(urlString:String) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        
        let docData = [
            "userId":uid,
            "imageUrlString": urlString,
            "title": self.titleTextField.text!,
            "material": materialTextView.text!,
            "indication": indicationTextField.text!,
            "cost": costTextField.text!,
            "makeMethod": makeMethodTextView.text!
        ]
        
        Firestore.firestore().collection("Posts").addDocument(data: docData) { (err) in
            if let err = err {
                print("Postsの保存に失敗しました\(err)")
                self.stopAnimation()
                self.alert(title: "投稿に失敗しました", message: "ごめんなさい")
                return
            }
            print("Postsの保存に成功しました")
            //画面遷移
            let NextVC = self.storyboard?.instantiateViewController(identifier: "PostsVC")
            NextVC?.modalTransitionStyle = .crossDissolve
            self.present(NextVC!, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func imageTap(_ sender: Any) {
        let actionAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        //アクションの項目を定義
        let albamAction = UIAlertAction(title: "アルバムから選択", style: UIAlertAction.Style.default, handler: {
            (action:UIAlertAction!) in
            self.openAlbam()
        })
        let cameraAction = UIAlertAction(title: "カメラ", style: UIAlertAction.Style.default) { (action: UIAlertAction!) in
            self.openCamera()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel) { (action: UIAlertAction!) in
            print("キャンセル")
        }
        
        //定義したアクションを追加する
        actionAlert.addAction(cameraAction)
        actionAlert.addAction(albamAction)
        actionAlert.addAction(cancelAction)
        
        //アクションを表示
        self.present(actionAlert,animated: true, completion: nil)
    }
    
    //撮影or画像が選択された時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[.editedImage]
        let Image = selectedImage as! UIImage
        
        imagecoverButton.isHidden = true
        
        imageView.image = Image
        
        //写真の保存
        UIImageWriteToSavedPhotosAlbum(Image, self, nil, nil)
        //閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    //キャンセルされた時の挙動
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    //カメラ起動
    func openCamera() {
        
        let sourceType = UIImagePickerController.SourceType.camera
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.allowsEditing = true
            cameraPicker.delegate = self
            present(cameraPicker, animated: true,completion: nil)
        } else {
            print("エラー")
        }
    }
    
    //アルバム起動
    func openAlbam() {
        
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.allowsEditing = true
            cameraPicker.delegate = self
            present(cameraPicker, animated: true,completion: nil)
        } else {
            print("エラー")
        }
    }
    
    //キーボードの大きさに合わせてViewを上下させる
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if fieldJatch == true {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                } else {
                    let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                    self.view.frame.origin.y -= suggestionHeight
                }
            }
        }
     }
     
    //キーボードを閉じる時にViewを元に戻す
    @objc func keyboardWillHide() {
             if self.view.frame.origin.y != 0 {
                 self.view.frame.origin.y = 0
         }
     }
    
    //他の所をtapすることでキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fieldJatch = false
        self.view.endEditing(true)
      }
    
    //returnキーでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //textViewにフォーカスが当たった時
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("textViewDidBeginEditing")
        fieldJatch = true
    }
    //textViewにフォーカスが外れた時
    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
        fieldJatch = false
    }
    
    //アラート表示
    func alert(title:String,message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
        present(alertController,animated: true)
    }
    
    
    
    
    @IBAction func returnButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
}
