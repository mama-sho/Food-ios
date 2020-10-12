//
//  NewPostViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/09/27.
//

import UIKit
import Firebase
import Photos
import Lottie

class AuthViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate,UITextFieldDelegate {
    
    var alertController = UIAlertController()
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var SininButton: UIButton!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    let animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraAlbamAuth()
        
        userImageView.layer.cornerRadius =  82.5
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        SininButton.layer.cornerRadius = 10
        //imgaeviewタップアクション
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ActionSheet)))
        //キーボードが閉じる時
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        //キーボードが閉じる時
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        nameTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
                
    }
    
    func cameraAlbamAuth() {
        //カメラとアルバムの許可request
        PHPhotoLibrary.requestAuthorization { (status) in
            switch (status) {
            case .authorized:
                print("認証されましたカメラ");
            case .denied:
                print("拒否されました");
            case .notDetermined:
                print("notDetermined");
            case .restricted:
                print("restricted");
            case .limited:
                print("limited")
            }
        }
    }
        
    @objc func ActionSheet() {
        
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
        
        userImageView.image = Image
        
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
    
    
    @IBAction func SIninAction(_ sender: Any) {
        
        
        if emailTextField.text == nil || nameTextField.text == nil || passwordTextField.text == nil {
            alert(title: "登録できませんでした", message: "未入力の項目があります")
            return
        }
        startAnimation()
        
        let imageData = userImageView.image?.jpegData(compressionQuality: 0.1)
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("userImage").child(fileName)
        //メタデータを設定
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        //ストレージに画像を保存
        storageRef.putData(imageData!,metadata: metaData) { (matadata, err) in
            if let err = err {
                self.stopAnimation()
                self.alert(title: "登録に失敗しました", message: "画像の保存に失敗しました")
                print("storageへの画像の保存に失敗しました:\(err)")
                return
            }
            print("storageへの画像の保存に成功しました。")
            
            //保存した画像のURLを取得
            storageRef.downloadURL { (url, error) in
                if let error = error {
                    self.stopAnimation()
                    self.alert(title: "登録に失敗しました", message: "dontURL")
                    print("画像のURLの取得に失敗しました。：\(error)")
                    return
                }
                guard let urlString = url?.absoluteString else { return }
                print("urlString:", urlString)
                
                self.firestoreCreate(imageUrlString: urlString)
            }
        }
        
    }
    
    func firestoreCreate(imageUrlString:String) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (User, error) in
            
            if error != nil {
                self.stopAnimation()
                //アラート表示する
                self.alert(title: "登録できませんでした", message: "email形式、パスワードは何文字以内？")
                return
            } else {
                print("Auth-----OK")
                //Authで割り当てられたuserのIDを取得
                guard let uid = User?.user.uid else {
                    return
                }
                //Usersコレクションにuserドキュメントを追加
                let firestore = Firestore.firestore().collection("Users").document(uid)
                
                let name = self.nameTextField.text
                let email = self.emailTextField.text
                let password = self.passwordTextField.text

                let docData = ["name": name, "email": email,"password": password,"ImageURLString": imageUrlString]
                
                //firestoreに保存
                firestore.setData(docData as [String : Any]) { (error) in
                    if let error = error {
                        self.stopAnimation()
                        self.alert(title: "データベースの保存に失敗しました", message: "!")
                        return
                    }
                    
                    print("firestoreへの情報の保存に成功しました")
                    //現在のviewcontrollerを破棄して前の画面に戻る
                    self.stopAnimation()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }

    }
    
    //キーボードの大きさに合わせてViewを上下させる
    @objc func keyboardWillShow(notification: NSNotification) {
         if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
             if self.view.frame.origin.y == 0 {
                 self.view.frame.origin.y -= keyboardSize.height
             } else {
                 let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                 self.view.frame.origin.y -= suggestionHeight
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
          self.view.endEditing(true)
      }
    
    //returnキーでキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //アラート表示
    func alert(title:String,message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
        present(alertController,animated: true)
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
    
    @IBAction func createButoon(_ sender: Any) {
        
        let nextVC = self.storyboard?.instantiateViewController(identifier: "NewPostsVC")
        nextVC?.modalTransitionStyle = .crossDissolve
        
        self.present(nextVC!, animated: true, completion: nil)
    }
}
