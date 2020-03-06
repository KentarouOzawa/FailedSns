//
//  TimeLineModel.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2019/12/29.
//  Copyright © 2019 小澤謙太郎. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class TimeLineModel {
    var text:String = ""
    var imageString:String = ""
    var profileImageString:String = ""
    var userName:String = ""
    var ref: DocumentReference? = nil
    var db = Firestore.firestore()
    
    
    init(text:String,imageString:String,profileImageString:String,userName:String) {
        self.text = text
        self.imageString = imageString
        self.profileImageString = profileImageString
        self.userName = userName
        db = Firestore.firestore()
    }
    
    init(snapshot: DocumentSnapshot) {
        ref = snapshot.reference
        if let value = snapshot.data(){
            text = value["text"] as! String
            imageString = value["imageString"] as! String
            profileImageString = value["profileImageString"] as! String
            userName = value["userName"] as! String
        }
    }
    
    func toContents()->[String:Any]{
        return
            ["text":text,"imageString":imageString,"profileImageString":profileImageString,"userName":userName, "timestamp": NSDate()]
    }
    
    func save(){
       ref = db.collection("timeline").addDocument(data: toContents()){ err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.ref!.documentID)")
            }
        }
    }
}


