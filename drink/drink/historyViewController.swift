//
//  historyViewController.swift
//  drink
//
//  Created by user on 22/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

class historyViewController:UIViewController{
    
    @IBOutlet weak var historyTableView: UITableView!
    var historys:[historyModel] = []
    let db = Database.database().reference()
    
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
        
        
        historyTableView.delegate = self
        historyTableView.dataSource = self
        
        let uid = Auth.auth().currentUser?.uid
        
        self.db.child("Buys").child(uid!).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                let data = item.value
                let history = historyModel(JSON: data as! [String: AnyObject])
                self.historys.append(history!)
            }
            self.historyTableView.reloadData()
        })
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barStyle = .default
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.tintColor = .darkGray
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)
        self.navigationController?.navigationBar.backgroundColor = .white
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension historyViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! historyCell
        
        cell.label_date.text = historys[indexPath.row].buys_date
        cell.label_reason.text = historys[indexPath.row].buys_comment
        cell.label_change.text = historys[indexPath.row].buys_change
        cell.label_result.text = historys[indexPath.row].current_heart

        return cell
    }
    
}

class historyCell:UITableViewCell{
    
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var label_reason: UILabel!
    @IBOutlet weak var label_change: UILabel!
    @IBOutlet weak var label_result: UILabel!
}
