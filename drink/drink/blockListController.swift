//
//  blockListController.swift
//  drink
//
//  Created by user on 09/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class blockListController:UIViewController{
    
    @IBOutlet weak var blockListTableView: UITableView!
    
    var blockList:[String] = []
    let db = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *)
        {
              let app = UIApplication.shared
              let statusBarHeight: CGFloat = app.statusBarFrame.size.height
              
              let statusbarView = UIView()
              statusbarView.backgroundColor =  UIColor(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)

              view.addSubview(statusbarView)
            
              statusbarView.translatesAutoresizingMaskIntoConstraints = false
              statusbarView.heightAnchor
                  .constraint(equalToConstant: statusBarHeight).isActive = true
              statusbarView.widthAnchor
                  .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
              statusbarView.topAnchor
                  .constraint(equalTo: view.topAnchor).isActive = true
              statusbarView.centerXAnchor
                  .constraint(equalTo: view.centerXAnchor).isActive = true
        }else{
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            if statusBar!.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar!.backgroundColor = UIColor(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }
        
        blockListTableView.delegate = self
        blockListTableView.dataSource = self
        getBlockList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.barStyle = .default
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    func getBlockList(){
        db.child("users").child(uid!).child("blockList").observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            self.blockList.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                self.blockList.append(item.key)
            }
            self.blockListTableView.reloadData()
        })
    }
    
    func blockCancel(index:Int){
        db.child("users").child(uid!).child("blockList").child(blockList[index]).removeValue()
        db.child("users").child(blockList[index]).child("blockedList").child(uid!).removeValue()
        getBlockList()
    }

}

extension blockListController:UITableViewDelegate,UITableViewDataSource,OptionButtonsClickDelegate{
    func blockCancelTapped(at index: IndexPath) {
        let msg = "차단을 해제하시겠습니까?"
        let alert = UIAlertController(title: "차단해제", message: msg, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel){
            (action : UIAlertAction) -> Void in
            //self.dismiss(animated: true)
        }
        
        let okayAction = UIAlertAction(title: "확인", style: .default){
            (action : UIAlertAction) -> Void in
            //확인 클릭 했을때 처리할 내용
            self.blockCancel(index: index.row)
        }
        alert.addAction(cancelAction)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = blockListTableView.dequeueReusableCell(withIdentifier: "blockListCell", for: indexPath) as! blockListCell
        //cell.btn_blockCancel.layer.cornerRadius = cell.btn_blockCancel.frame.height/2
        cell.btn_blockCancel.layer.cornerRadius = 10
        cell.btn_blockCancel.layer.masksToBounds = true
        cell.delegate = self
        cell.indexPath = indexPath
        db.child("users").child(blockList[indexPath.row]).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            let usermodel = userModel(JSON: datasnapshot.value as! [String:AnyObject])
            cell.label_blkUserName.text = usermodel!.username
            
            let imageIndex = (usermodel?.photo.keys.sorted())!
            
            if (usermodel?.photo.count != 0){
                if (usermodel!.photo[imageIndex[0]]!.image != nil){
                    let url = URL(string: usermodel!.photo[imageIndex[0]]!.image!)
                    cell.destinationFaceView.kf.setImage(with:url)
                }else{
                    
                }
            }
            
            cell.destinationFaceView.layer.cornerRadius = cell.destinationFaceView.frame.width/3
            cell.destinationFaceView.layer.masksToBounds = true
            
            /*self.db.child("users").child(self.blockList[indexPath.row]).child("photo").observeSingleEvent(of: DataEventType.value, with: {(dataSnapshot) in
                
                for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                    let data = item.value
                    usermodel?.mainPhoto = userModel.Photo(JSON: data as! [String: AnyObject])
                    break
                }
                let url = URL(string: (usermodel?.mainPhoto!.temp)!)
                
                //let url = URL(string:(self.usermodel!.photo.first?.value.temp)!)
                cell.destinationFaceView.layer.cornerRadius = cell.destinationFaceView.frame.width/3
                cell.destinationFaceView.layer.masksToBounds = true
                cell.destinationFaceView.kf.setImage(with:url)
            })*/
            
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //return UITableView.automaticDimension
        return 60
    }

}

class blockListCell:UITableViewCell{
    @IBOutlet weak var btn_blockCancel: UIButton!
    @IBOutlet weak var label_blkUserName: UILabel!
    
    @IBOutlet weak var destinationFaceView: UIImageView!
    
    var delegate:OptionButtonsClickDelegate!
    var indexPath:IndexPath!
    @IBAction func blockCancelTapped(_ sender: UIButton) {
        self.delegate.blockCancelTapped(at: indexPath)
    }
}

protocol OptionButtonsClickDelegate{
    func blockCancelTapped(at index:IndexPath)
}
