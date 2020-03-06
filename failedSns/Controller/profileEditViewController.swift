//
//  profileEditViewController.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2019/12/23.
//  Copyright © 2019 小澤謙太郎. All rights reserved.
//

import UIKit
import Photos
import FirebaseFirestore
import PKHUD
import Firebase

class profileEditViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var profileImage: UIImageView!
    
    var imageUrl:URL?
    var db:Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PHPhotoLibrary.requestAuthorization { (status) in
            switch(status){
            case .authorized:
                print("許可されてます")
            case .denied:
                print("拒否された")
            case .notDetermined:
                print("notDetermined")
            case .restricted:
                print("restricted")
            @unknown default:
                fatalError()
            }
        }
    }
    
    func sendGetImageUrl(){
        /*database
         https://failedsns.firebaseio.com/
         */
        /*storage
         gs://failedsns.appspot.com
         */
        //let ref = Database.database().reference(fromURL: "https://failedsns.firebaseio.com/")
        // インスタンスの生成
        let storage = Storage.storage()
        let storageReference = storage.reference(forURL: "gs://failedsns.appspot.com")
        // イメージの名前を日付から自動生成
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        // 保存する階層を設定
        let imagesReference = storageReference.child("users").child("user").child(imageName)
        // 保存するイメージデータを宣言
        let image = profileImage.image!
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            // putDataで実際にstorageに保存を行う
            imagesReference.putData(imageData, metadata: metadata, completion:{(metadata, error) in
                if let _ = metadata {
                    imagesReference.downloadURL{(url,error) in
                        if let downloadUrl = url {
                            // ここでstorageのURLの保存先を設定
                            self.imageUrl = downloadUrl
                            UserDefaults.standard.set(self.imageUrl?.absoluteString, forKey: "profileImageString")
                        }
                    }
                }
            })
        }
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
    //カメラなどが立ち上がってる時にキャンセルされたら
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    //カメラかアルバムで画像が選択されたら
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage{
            self.profileImage.image = pickedImage
            picker.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func tapProfileImageView(_ sender: Any) {
        openAction()
    }
    
    @IBAction func editDecided(_ sender: Any) {
        if profileImage.image != nil{
            DispatchQueue.main.async {
                self.sendGetImageUrl()
            }
            performSegue(withIdentifier: "timeLine", sender: nil)
        }
    }
}

