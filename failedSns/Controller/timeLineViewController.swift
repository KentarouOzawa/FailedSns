//
//  timeLineViewController.swift
//  failedSns
//
//  Created by 小澤謙太郎 on 2019/12/23.
//  Copyright © 2019 小澤謙太郎. All rights reserved.
//

import UIKit
import Firebase

class timeLineViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    var timeLineRef = Firestore.firestore().collection("timeline")
    var timeLines = [TimeLineModel]()
    var profileImageString = ""
    var userName = ""
    var imageString = ""
    var text = ""
    let refleshControll = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //タイムラインscrollの更新
        refleshControll.addTarget(self, action: #selector(reflesh), for: .valueChanged)
        refleshControll.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refleshControll.addTarget(self, action: #selector(reflesh), for: .valueChanged)
        tableView.addSubview(refleshControll)
        
        //しっかりとスクロールして更新する
        self.tableView.alwaysBounceVertical = true
        //navigationのUI
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = .white
        title = "TUMADUKI"
        
        self.tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timeLineRef.order(by: "timestamp", descending: false).getDocuments{ (snapshots, error) in
            self.timeLines.removeAll()
            // ここに通信後の処理を書く。
            // snapshot.documentsで全てのドキュメントが取得できる。
            // document.data()でドキュメントのデータが取得可能
            for document in snapshots!.documents {
                let data = document as DocumentSnapshot 
                let timeline = TimeLineModel(snapshot: data)
                print(timeline)
                self.timeLines.insert(timeline, at: 0)
                
            }
            self.tableView.reloadData()
        }
    }
    
    @objc func reflesh(){
        refleshControll.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeLines.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 718
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",for: indexPath) as! TimeLineCell
        let timeLineModel = timeLines[indexPath.row]
        cell.timeLineModel = timeLineModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        profileImageString = timeLines[indexPath.row].profileImageString
        userName = timeLines[indexPath.row].userName
        imageString = timeLines[indexPath.row].imageString
        text = timeLines[indexPath.row].text
        performSegue(withIdentifier: "detailView", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailView"{
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.profileImage = profileImageString
            detailViewController.userName = userName
            detailViewController.contentImage = imageString
            detailViewController.comment = text
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            performSegue(withIdentifier: "LoginMenu", sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
}

