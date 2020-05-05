//
//  pushListController.swift
//  drink
//
//  Created by user on 19/09/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase

class pushListController:UIViewController{
    let db = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var databaseRef:DatabaseReference?
    var observe:UInt?//채팅방에서 나갔을 때 더이상 디비를 참조하지 않기 위한 변수
    var pushList:[String] = []
    var usermodels:[userModel] = []
    
    @IBOutlet weak var pushListTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        pushListTableView.delegate = self
        pushListTableView.dataSource = self
        
        getPushList()
    }
    
    public func getPushList(){
        db.child("users").child(uid!).child("pushList").observe(DataEventType.value, with: {(datasnapshot) in
            self.pushList.removeAll()
            self.usermodels.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                //let data = item.value as! [String:Bool]
                let destinationUid = item.key
                print(item.key)
                self.pushList.append(destinationUid)
            }
            self.pushListTableView.reloadData()

        })
    }
}

extension pushListController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pushList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = pushListTableView.dequeueReusableCell(withIdentifier: "pushListCell", for: indexPath) as! pushListCell
        
        let destinationUid = pushList[indexPath.row]
        
        db.child("users").child(destinationUid).observeSingleEvent(of: DataEventType.value,  with: { (DataSnapshot) in
            let usermodel = userModel(JSON: DataSnapshot.value as! [String:AnyObject])
            usermodel!.uid = destinationUid
            self.usermodels.append(usermodel!)
            cell.textLabel!.text = usermodel?.username
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInfoViewController = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
        userInfoViewController.navigationItem.title = usermodels[indexPath.row].username
        userInfoViewController.usermodel = usermodels[indexPath.row]
        userInfoViewController.prevPage = 2
        self.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
}

class pushListCell:UITableViewCell{
    
}
