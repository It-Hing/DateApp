//
//  emailConfirmViewController.swift
//  drink
//
//  Created by user on 14/11/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftKeychainWrapper

class emailConfirmViewController:UIViewController{
    
    @IBOutlet weak var label_alertTitle: UILabel!
    @IBOutlet weak var label_alertContent: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var popUpView: UIView!

    @IBOutlet weak var emailConfirmField: UITextField!
    
    var alertContent:String?
    var alertTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label_alertTitle.text = alertTitle
        label_alertContent.text = alertContent
        popUpView.layer.cornerRadius = 5.0
        popUpView.layer.masksToBounds = true
        
        label_alertContent.numberOfLines = 0
        label_alertContent.textAlignment = NSTextAlignment.center

        backView.isUserInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        backView.addGestureRecognizer(tap)
        popUpView.isUserInteractionEnabled = true
        popUpView.addGestureRecognizer(tap)
    }
    
    @objc func endEditing(){
        self.view.endEditing(true)
    }
    
    @IBAction func okButtonTapped(_ sender: Any){
        //이메일 입력시 비밀번호 리셋 메일 전송
        Auth.auth().sendPasswordReset(withEmail: emailConfirmField.text!){ (err) in
            print("이메일 전송완료")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
}
