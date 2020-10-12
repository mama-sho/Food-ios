//
//  MyPageViewController.swift
//  FoodMyMenu
//
//  Created by 上田大樹 on 2020/10/08.
//

import UIKit
import Firebase
import Lottie

class MyPageViewController: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate,UITextFieldDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    @IBOutlet weak var detailSwitch: UISwitch!
    
    @IBOutlet weak var changeButton: UIButton!
    
    @IBOutlet weak var imageButton: UIButton!
    
    var alertController = UIAlertController()
    
    var animationView = AnimationView()
    
    let uid = Auth.auth().currentUser?.uid
    
    var nameText = String()
    var emailText = String()
    var passwordText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = 110
        
        nameTextField.borderStyle = .none
        nameTextField.isEnabled = false
        emailTextField.borderStyle = .none
        emailTextField.isEnabled = false
        passwordTextField.borderStyle = .none
        passwordTextField.isEnabled = false
        passwordTextField.isSecureTextEntry = true
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        imageButton.isHidden = true
        imageButton.isEnabled = false
        
        changeButton.isHidden = true
        changeButton.isEnabled = false
        changeButton.layer.cornerRadius = 10.0
        
        // 2.影の設定
        // 影の濃さ
        changeButton.layer.shadowOpacity = 0.5
        // 影のぼかしの大きさ
        changeButton.layer.shadowRadius = 3
        // 影の色
        changeButton.layer.shadowColor = UIColor.black.cgColor
        // 影の方向（width=右方向、height=下方向）
        changeButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        
        //キーボードが開く時
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        //キーボードが閉じる時
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    //viewがないのに遷移するとエラーなるだからAppearに
    override func viewDidAppear(_ animated: Bool) {
        AuthCheck()
    }
    
    func getMyData() {
        startAnimation()
        
        print("getMyData")
        print("uidの取得:: \(String(describing: uid!))")
        
        let getRef = Firestore.firestore().collection("Users").document(uid!)
        
        getRef.getDocument { (snapShot, error) in
            
            if let error = error {
                print("自分の情報の取得に失敗しました。\(error)")
                return
            }
            print("情報の取得に成功")
            
            let getData = snapShot?.data()
            let user = User.init(dic: getData!)
            
            //UIに反映していく
            self.nameTextField.text = user.name
            self.nameText = user.name
            self.emailTextField.text = user.email
            self.emailText = user.email
            self.passwordTextField.text = user.password
            self.passwordText = user.password
            self.userImageView.image = self.getImageByUrl(url: user.ImageUrlString)
            
            self.stopAnimation()
        }
    }
    
    //urlからUImageに変換
    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
    
    func AuthCheck() {
        //認証すみかどうかわかる
        if uid == nil {
            print("認証済ではないので、AuthViewに遷移します")
            let NextVC = self.storyboard?.instantiateViewController(identifier: "AuthVC")
            self.present(NextVC!, animated: true, completion: nil)
        } else {
            self.getMyData()
        }
    }

    @IBAction func detailSwitch(_ sender: Any) {
        
        if detailSwitch.isOn == true {
            print("スイッチがオンになった")
            
            nameTextField.borderStyle = .bezel
            nameTextField.isEnabled = true
            nameTextField.text = ""
            nameTextField.placeholder = nameText
            emailTextField.borderStyle = .bezel
            emailTextField.isEnabled = true
            emailTextField.text = ""
            emailTextField.placeholder = emailText
            passwordTextField.borderStyle = .bezel
            passwordTextField.isEnabled = true
            passwordTextField.text = ""
            passwordTextField.placeholder = passwordText
            passwordTextField.isSecureTextEntry = false
            
            changeButton.isHidden = false
            changeButton.isEnabled = true
            imageButton.isHidden = false
            imageButton.isEnabled = true

        } else {
            print("スイッチがオフになった")
            nameTextField.borderStyle = .none
            nameTextField.isEnabled = false
            nameTextField.text = nameText
            emailTextField.borderStyle = .none
            emailTextField.isEnabled = false
            emailTextField.text = emailText
            passwordTextField.borderStyle = .none
            passwordTextField.isEnabled = false
            passwordTextField.text = passwordText
            
            changeButton.isHidden = true
            changeButton.isEnabled = false
            imageButton.isHidden = true
            imageButton.isEnabled = false
        }
        
    }
    
    
    @IBAction func buttonTapAction(_ sender: Any) {
        print("ボタンタップ")
        startAnimation()
        
        let email = self.emailTextField.text
        let name = self.nameTextField.text
        let password = self.passwordTextField.text
        let image = self.userImageView.image
        
        if email == "" || name == "" || password == "" || image == nil {
            alert(title: "更新できませんでした", message: "未入力の項目があります")
            stopAnimation()
            return
        }
        Auth.auth().signIn(withEmail: self.emailText, password: self.passwordText) { [weak self] authResult, error in
            
            if let error = error {
                print("ログインに失敗しました::\(error)")
                self?.alert(title: "更新に失敗しました", message: "ざんねん")
                self?.stopAnimation()
                return
            }
        
            //Authの更新処理
            let user = Auth.auth().currentUser
        
            user?.updateEmail(to: email!, completion: { (error) in
                if let error = error {
                    print("emailの更新に失敗しました",error) // 再ログインしないとダメみたい
                    self?.alert(title: "更新に失敗しました", message: "emailの更新に問題があります")
                    self?.stopAnimation()
                    return
                }
                print("emailの更新に成功しました")
                user?.updatePassword(to: password!, completion: { (error) in
                    if let error = error {
                        print("passwordの更新に失敗しました",error)
                        self?.alert(title: "更新に失敗しました", message: "passwordの更新に問題があります")
                        self?.stopAnimation()
                        return
                    }
                    print("passwordのにセア移行しました")
                
                    //storage元のファイルを参照して削除したい............
                    let fileName = NSUUID().uuidString
                    let storageRef = Storage.storage().reference().child("userImage").child(fileName)
                
                    //metaデータの設定
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/jpeg"
                
                    let UpdateImageData = self!.userImageView.image?.jpegData(compressionQuality: 0.1)
                    //画像を保存します
                    storageRef.putData(UpdateImageData!,metadata: metaData) { (metaData, error) in
                        if let error = error {
                            print("画像の保存に失敗しました:\(error)")
                            self?.stopAnimation()
                            return
                        }
                        print("画像の保存に成功しました")
                
                        storageRef.downloadURL { (url, error) in
                            if let error = error {
                                print("urlに取得に失敗しました\(error)")
                                self?.stopAnimation()
                                return
                            }
                            print("urlの取得に成功しました:\(String(describing: url))")
                        
                            guard let urlString = url?.absoluteString else { return }
                            print("urlString:", urlString)
                        
                            self?.FireStoreUpdate(imageURLString: urlString)
                        }
                    }
                
                })
            })
        }

    }
    
    //updateする
    func FireStoreUpdate(imageURLString:String) {
        
        let firestore = Firestore.firestore().collection("Users").document(uid!)
        
        let name = self.nameTextField.text
        let email = self.emailTextField.text
        let password = self.passwordTextField.text

        let docData = ["name": name, "email": email,"password": password,"ImageURLString": imageURLString]
        
        firestore.updateData(docData as [AnyHashable : Any]) { (error) in
            if let error = error {
                print("updateに失敗しました::\(error)")
                self.stopAnimation()
                return
            }
            self.viewDidLoad()
            self.stopAnimation()
            print("firestoreの更新に成功しました！オールクリア！")
            self.AuthCheck()
            self.detailSwitch.setOn(false, animated: true)
        }
        
    }
    
    @IBAction func imageTapButton(_ sender: Any) {
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
    @IBAction func createButton(_ sender: Any) {
        let nextVC = self.storyboard?.instantiateViewController(identifier: "NewPostsVC")
        
        nextVC?.modalTransitionStyle = .crossDissolve
        self.present(nextVC!, animated: true, completion: nil)
    }
    
}
