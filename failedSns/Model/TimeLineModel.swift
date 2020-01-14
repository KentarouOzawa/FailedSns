//
//  TimeLineModel.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2019/12/29.
//  Copyright © 2019 小澤謙太郎. All rights reserved.
//

import Foundation
import Firebase

class TimeLineModel {
    var text:String = ""
    var imageString:String = ""
    var profileImageString:String = ""
    var userName:String = ""
    let ref:DatabaseReference!
    
    init(text:String,imageString:String,profileImageString:String,userName:String) {
        self.text = text
        self.imageString = imageString
        self.profileImageString = profileImageString
        self.userName = userName
        ref = Database.database().reference().child("timeline").childByAutoId()
    }
    init(snapshop:DataSnapshot) {
        ref = snapshop.ref
        if let value = snapshop.value as? [String:Any]{
            text = value["text"] as! String
            imageString = value["imageString"] as! String
            profileImageString = value["profileImageString"] as! String
            userName = value["userName"] as! String
        }
    }
    func toContents()->[String:Any]{
        return
            ["text":text,"imageString":imageString,"profileImageString":profileImageString,"userName":userName]
        }
    func save(){
        ref.setValue(toContents())
    }
}
