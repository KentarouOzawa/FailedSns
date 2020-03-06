//
//  LoginViewController.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2019/12/23.
//  Copyright © 2019 小澤謙太郎. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var nameTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextfield.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        nameTextfield.resignFirstResponder()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        if nameTextfield.text?.isEmpty != true{
            //名前テキストの文字が入っていたら
            UserDefaults.standard.set(nameTextfield.text, forKey: "userName")
            Auth.auth().signInAnonymously { (result, error) in
                if error == nil{
                    guard let user = result?.user else { return }
                    let isAnonymous = user.isAnonymous  // true
                    let uid = user.uid
                    self.performSegue(withIdentifier: "profileEdit", sender: nil)
                }else{
                    print(error?.localizedDescription as Any)
                }
            }
        }else{
            //名前テキストの文字が空だったら
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
}
