//
//  signUp_EnrollEmailController.swift
//  drink
//
//  Created by user on 14/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

class signUp_EnrollEmailController:UIViewController{
    
    @IBOutlet weak var label_email: UILabel!
    @IBOutlet weak var label_pwd: UILabel!
    @IBOutlet weak var label_emailConfirm: UILabel!//비밀번호확인(오타)
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var emailConfirmField: UITextField!//비밀번호확인(오타)
    
    @IBOutlet weak var email_Height: NSLayoutConstraint!
    @IBOutlet weak var pwd_Height: NSLayoutConstraint!
    @IBOutlet weak var confirmPwd_Height: NSLayoutConstraint!
    
    @IBOutlet weak var label_emailAlert: UILabel!
    @IBOutlet weak var label_pwdAlert: UILabel!
    @IBOutlet weak var label_pwdConfirmAlert: UILabel!
    
    var failImage:UIImage?
    var emailImage:UIImage?
    var pwdImage:UIImage?
    var repwdImage:UIImage?
    
    @IBOutlet weak var emailImageView: UIImageView!
    @IBOutlet weak var pwdImageView: UIImageView!
    @IBOutlet weak var repwdImageView: UIImageView!
    
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
        }
        
        
        label_email.layer.borderColor = UIColor.lightGray.cgColor
        label_email.layer.borderWidth = 0.5
        label_pwd.layer.borderColor = UIColor.lightGray.cgColor
        label_pwd.layer.borderWidth = 0.5
        label_emailConfirm.layer.borderColor = UIColor.lightGray.cgColor
        label_emailConfirm.layer.borderWidth = 0.5
        
        emailField.delegate = self
        pwdField.delegate = self
        emailConfirmField.delegate = self
        
        pwdField.isEnabled = false
        emailConfirmField.isEnabled = false
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emailEnrollTapped(_ sender: Any) {
        
        if emailField.text == ""{
            email_Height.constant = 70
            label_emailAlert.text = "이메일을 입력해주세요."
            label_emailAlert.textColor = UIColor.red
            return
        }
        if emailField.text?.validateEmail() == false{
            email_Height.constant = 70
            label_emailAlert.text = "이메일 형식이 올바르지 않습니다."
            label_emailAlert.textColor = UIColor.red
            pwdField.isEnabled = false
            return
        }
        if pwdField.text == ""{
            pwd_Height.constant = 70
            label_pwdAlert.text = "비밀번호를 입력해주세요."
            label_pwdAlert.textColor = UIColor.red
            return
        }
        if emailConfirmField.text == ""{
            confirmPwd_Height.constant = 70
            label_pwdConfirmAlert.text = "비밀번호를 한번더 입력해주세요."
            label_pwdConfirmAlert.textColor = UIColor.red
            return
        }
        
        if emailConfirmField.text != pwdField.text{
            confirmPwd_Height.constant = 70
            label_pwdConfirmAlert.text = "비밀번호가 일치하지 않습니다."
            label_pwdConfirmAlert.textColor = UIColor.red
            return
        }
        
        loadingVC.show()
        guard let email = emailField.text,
            email != "",
            let password = pwdField.text,
            password != "",
            let pwdConfirm = emailConfirmField.text,
            pwdConfirm != ""
            else{
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                //print(error as Any)
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                        case .emailAlreadyInUse:
                            self.email_Height.constant = 70
                            self.label_emailAlert.text = "이미 가입된 이메일입니다."
                            self.label_emailAlert.textColor = UIColor.red
                            self.pwdField.isEnabled = false
                            break
                        default:
                            print("Create User Error: \(error!)")
                            break
                    }
                }
                loadingVC.hide()
                return
            }else{
                //UserDefaults.standard.set(false, forKey: "enrollProfile")
                KeychainWrapper.standard.set(email, forKey: "enrollProfile")
                KeychainWrapper.standard.set(email, forKey: "email")
                KeychainWrapper.standard.set(password, forKey: "pwd")
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let signUp_EnrollProfileController = storyBoard.instantiateViewController(withIdentifier: "signUp_EnrollProfileController") as! signUp_EnrollProfileController
                signUp_EnrollProfileController.modalPresentationStyle = .fullScreen
                loadingVC.hide()
                self.present(signUp_EnrollProfileController, animated: true, completion: nil)
            }
        }
    }
    
}

extension signUp_EnrollEmailController:UITextFieldDelegate{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == emailField{
            if emailField.text?.validateEmail() == true{
                email_Height.constant = 50
                label_emailAlert.text = ""
                pwdField.isEnabled = true
                return true
            }else{
                email_Height.constant = 70
                label_emailAlert.text = "이메일 형식이 올바르지 않습니다."
                label_emailAlert.textColor = UIColor.red
                pwdField.isEnabled = false
                return true
            }
        }else if textField == pwdField{
            if pwdField.text!.count < 6{
                pwd_Height.constant = 70
                label_pwdAlert.text = "비밀번호는 6자리 이상적어주세요."
                label_pwdAlert.textColor = UIColor.red
                emailConfirmField.isEnabled = false
                return true
            }else{
                pwd_Height.constant = 50
                label_pwdAlert.text = ""
                emailConfirmField.isEnabled = true
                return true
            }
        }else if textField == emailConfirmField{
            if emailConfirmField.text == pwdField.text{
                confirmPwd_Height.constant = 50
                label_pwdConfirmAlert.text = ""
                return true
            }else{
                confirmPwd_Height.constant = 70
                label_pwdConfirmAlert.text = "비밀번호가 일치하지 않습니다."
                label_pwdConfirmAlert.textColor = UIColor.red
                return true
            }
        }else{
            return true
        }
        //true인경우 다른 textfield를 수정가능 false인경우 다른 textfield를 수정불가능
    }
}

extension String{
    //이메일 정규식(유효성 확인)
    func validateEmail()->Bool{
        let emailRegEx = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return predicate.evaluate(with: self)
    }
}
