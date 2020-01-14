//
//  profileEditViewController.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2019/12/23.
//  Copyright © 2019 小澤謙太郎. All rights reserved.
//

import UIKit
import Photos
import Firebase
import PKHUD
class profileEditViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var profileImage: UIImageView!
    
    var imageUrl:URL?
    
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
        let ref = Database.database().reference(fromURL: "https://failedsns.firebaseio.com/")
        let storage = Storage.storage().reference(forURL: "gs://failedsns.appspot.com")
        //画像が入るフォルダを作成してそこに画像を入れる
        //画像の名前も決めます
        let key = ref.childByAutoId().key
        let imageRef = storage.child("profileImages").child("\(key).jpeg")
        var imageData:Data = Data()
        if self.profileImage.image != nil{
            imageData = (self.profileImage.image?.jpegData(compressionQuality: 0.01))!
        }
        //HUD
        HUD.dimsBackground = false
        HUD.show(.progress)
        let uploadTask = imageRef.putData(imageData, metadata: nil) { (metaData, error) in
            if error != nil{
                print(error as Any)
                return
            }
            imageRef.downloadURL { (url, error) in
                if url != nil{
                    //HUD
                    HUD.hide()
                    self.imageUrl = url
                    UserDefaults.standard.set(self.imageUrl?.absoluteString, forKey: "profileImageString")
                }
            }
        }
        uploadTask.resume()
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
