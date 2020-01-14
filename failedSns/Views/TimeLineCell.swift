//
//  TimeLineCell.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2020/01/01.
//  Copyright © 2020 小澤謙太郎. All rights reserved.
//

import UIKit
import Firebase
import PINRemoteImage

class TimeLineCell: UITableViewCell {

    @IBOutlet weak var contentsImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
     var timeLineModel:TimeLineModel! {
        didSet{
            commentLabel.text = timeLineModel.text
            userNameLabel.text = timeLineModel.userName
            profileImageView.pin_setImage(from: URL(string:timeLineModel.profileImageString)!)
            contentsImageView.pin_setImage(from: URL(string:timeLineModel.imageString)!)
           }
    }
   
}
