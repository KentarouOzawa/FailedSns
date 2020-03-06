//
//  PostViewController.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2020/01/02.
//  Copyright © 2020 小澤謙太郎. All rights reserved.
//

import UIKit
import Firebase
import PKHUD
import CDAlertView
import FirebaseFirestore

class PostViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var postBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var contentImageView: UIImageView!
    
    var db:Firestore!
    var imageURL:URL?
    var profileImageString = ""
    var userName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .white
        postBarButtonItem.isEnabled = false
        title = " TUMADUKI"
        commentTextView.text = ""
        commentTextView.becomeFirstResponder()
        db = Firestore.firestore()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "profileImageString") != nil{
            profileImageString = UserDefaults.standard.object(forKey: "profileImageString") as! String
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextView.resignFirstResponder()
    }
    func openAction(){
        let alert:UIAlertController = UIAlertController(title: "選択してください", message: "",preferredStyle: .actionSheet)
        let cameraAction:UIAlertAction = UIAlertAction(title: "カメラから", style: .default) { (alert) in
            let sourceType = UIImagePickerController.SourceType.camera
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let cameraPicker = UIImagePickerController()
                cameraPicker.sourceType = sourceType
                cameraPicker.delegate = self
                cameraPicker.allowsEditing = true
                
                self.present(cameraPicker,animated: true)
                
            }else{
                print("エラーです")
            }
        }
        let albumAction:UIAlertAction = UIAlertAction(title: "アルバムから", style: .default) { (alert) in
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let albumPicker = UIImagePickerController()
                albumPicker.sourceType = sourceType
                albumPicker.delegate = self
                albumPicker.allowsEditing = true
                
                self.present(albumPicker,animated: true)
                
            }else{
                print("エラーです")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
            print("キャンセル")
        }
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)
        self.present(alert,animated: true,completion: nil)
    }
    func sendGetImageUrl(){
        /*database
         https://failedsns.firebaseio.com/
         */
        /*storage
         gs://failedsns.appspot.com
         */
        
        // let ref = Database.database().reference(fromURL: "https://failedsns.firebaseio.com/")
        let storage = Storage.storage()
        let storageReference = storage.reference(forURL: "gs://failedsns.appspot.com")
        // イメージの名前を日付から自動生成
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        // 保存する階層を設定
        let imagesReference = storageReference.child("users").child("user").child(imageName)
        // 保存するイメージデータを宣言
        let image = contentImageView.image!
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            //HUD
            HUD.dimsBackground = false
            HUD.show(.progress)
            // putDataで実際にstorageに保存を行う
            imagesReference.putData(imageData, metadata: metadata, completion:{(metadata, error) in
                if let _ = metadata {
                    imagesReference.downloadURL{(url,error) in
                        if let downloadUrl = url {
                            //HUD
                            HUD.hide()
                            // ここでstorageのURLの保存先を設定
                            self.imageURL = downloadUrl
                            self.postBarButtonItem.isEnabled = true
                        }
                    }
                }
            }
            )
        }
    }
    //カメラなどが立ち上がってる時にキャンセルされたら
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //カメラかアルバムで画像が選択されたら
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage{
            self.contentImageView.image = pickedImage
            sendGetImageUrl()
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func tapProfileImagView(_ sender: Any) {
        openAction()
    }
    
    @IBAction func postData(_ sender: Any) {
        if commentTextView.text != "" && imageURL!.absoluteString.isEmpty != true{
            let timeLineModel = TimeLineModel(text: commentTextView.text, imageString: imageURL!.absoluteString, profileImageString: profileImageString, userName: userName)
            timeLineModel.save()
            
            //CDAlertView
            let alert = CDAlertView(title: "完了", message: "投稿を完了したよ！タイムラインで確認してみよう", type: .success)
            let action = CDAlertViewAction(title: "OK")
            alert.add(action: action)
            alert.hideAnimations = { (center, transform, alpha) in
                transform = CGAffineTransform(scaleX: 3, y: 3)
                alpha = 0
            }
            alert.hideAnimationDuration = 0.88
            alert.show()
        }
    }
}
