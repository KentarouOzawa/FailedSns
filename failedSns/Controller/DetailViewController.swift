//
//  DetailViewController.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2020/01/02.
//  Copyright © 2020 小澤謙太郎. All rights reserved.
//

import UIKit
import PINRemoteImage
class DetailViewController: UIViewController {
   @IBOutlet weak var profileImageview: UIImageView!
   @IBOutlet weak var userNameLabel: UILabel!
   @IBOutlet weak var contentImageView: UIImageView!
   @IBOutlet weak var commentTextView: UITextView!
    
    var profileImage = String()
    var userName = String()
    var contentImage = String()
    var comment = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.isEditable = false
        userNameLabel.text = userName
        commentTextView.text = comment
        profileImageview.pin_setImage(from: URL(string:profileImage)!)
        contentImageView.pin_setImage(from: URL(string: contentImage)!)
    }
}
