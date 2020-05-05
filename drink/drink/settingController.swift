//
//  settingController.swift
//  drink
//
//  Created by user on 09/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class settingController:UIViewController{
    
    @IBOutlet weak var settingTableView: UITableView!
    let db = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
        
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.reloadData()
    }
    
    func showBlockList(){
        let blockListController = storyboard?.instantiateViewController(withIdentifier: "blockListController") as! blockListController
        self.navigationController?.pushViewController(blockListController, animated: true)
    }
    
    func showTempLogin(){
        //디비에 로그인체크 필드에 false(로그아웃)을 저장해준다.
        db.child("users").child(uid!).child("loginCheck").setValue(false) { (err, ref) in
            if err != nil{
                print(err)
            }else{
                let tempLoginController = self.storyboard?.instantiateViewController(withIdentifier: "tempLoginController") as! tempLoginController
                //tempLoginController.loginEmail = Auth.auth().currentUser?.email
                self.db.child("users").child(self.uid!).child("location").removeValue { (err, ref) in
                    UserDefaults.standard.set(false, forKey: "loginCheck")
                    //tempLoginController.isInitialView = false
                    self.navigationController?.pushViewController(tempLoginController, animated: true)
                    //로그아웃을 하면 디비에서 나의 위치 삭제후 화면전환
                }
            }
        }
    }
}

extension settingController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingTableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! settingCell
        switch indexPath.row {
        case 0:
            cell.textLabel!.text = "차단목록"
            break
        case 1:
            cell.textLabel!.text = "이용약관"
            break
        case 2:
            cell.textLabel!.text = "비밀번호 재설정"
            break
        case 3:
            cell.textLabel!.text = "계정탈퇴"
            break
        case 4:
            cell.textLabel!.text = "로그아웃"
            break
        default:
            break
        }
        //cell.textLabel!.text = "차단목록"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            showBlockList()
            break
        case 1:
            break
        case 2:
            
            break
        case 3:
            
            break
        case 4:
            let msg = "로그아웃 하시겠습니까?"
            let alert = UIAlertController(title: "로그아웃", message: msg, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel){
                (action : UIAlertAction) -> Void in
                //self.dismiss(animated: true)
            }
            
            let okayAction = UIAlertAction(title: "확인", style: .default){
                (action : UIAlertAction) -> Void in
                //확인 클릭 했을때 처리할 내용
                self.showTempLogin()
            }
            alert.addAction(cancelAction)
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
}

class settingCell:UITableViewCell{
    
}
