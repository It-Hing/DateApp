//
//  profilePopUpController.swift
//  drink
//
//  Created by user on 16/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class profilePopUpController:UIViewController{
    
    var list:[String] = []
    var delegate:DimissManager?
    var kindOfList:String?
    
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var popUpTableView: UITableView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var popUpName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpTableView.delegate = self
        popUpTableView.dataSource = self
        
        popUpView.layer.cornerRadius = 10.0
        popUpView.layer.masksToBounds = true
        
        backView.isUserInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        backView.addGestureRecognizer(tap)
        
        popUpTableView.reloadData()
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension profilePopUpController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = popUpTableView.dequeueReusableCell(withIdentifier: "popUpCell", for: indexPath) as! popUpCell
        popUpName.text = kindOfList
        //cell.textLabel!.text = list[indexPath.row]
        cell.label_cellElement.text = list[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if kindOfList == "나이"{
            UserDefaults.standard.set(list[indexPath.row], forKey: "age")
            delegate?.vcDismissed()
            dismiss(animated: false, completion: nil)
        }else if kindOfList == "성격"{
            UserDefaults.standard.set(list[indexPath.row], forKey: "personality")
            delegate?.vcDismissed()
            dismiss(animated: false, completion: nil)
        }else if kindOfList == "키"{
            UserDefaults.standard.set(list[indexPath.row], forKey: "tall")
            delegate?.vcDismissed()
            dismiss(animated: false, completion: nil)
        }else if kindOfList == "체형"{
            UserDefaults.standard.set(list[indexPath.row], forKey: "body")
            delegate?.vcDismissed()
            dismiss(animated: false, completion: nil)
        }
    }
}

class popUpCell:UITableViewCell{
    @IBOutlet weak var label_cellElement: UILabel!
}
