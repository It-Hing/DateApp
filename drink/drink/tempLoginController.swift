//
//  tempLoginController.swift
//  drink
//
//  Created by user on 09/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftKeychainWrapper
import Firebase
import AVFoundation
import AVKit

class tempLoginController:UIViewController{
    
    @IBOutlet weak var btn_login: UIButton!
    let db = Database.database().reference()
    
    override func viewDidLoad(){
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //playLocalVideo()

        let email = KeychainWrapper.standard.string(forKey: "email")
        if (email != nil){
            let btnMent = "\((KeychainWrapper.standard.string(forKey: "email"))!)로 로그인"
            self.btn_login.setTitle(btnMent, for: .normal)
        }
        btn_login.layer.borderWidth = 0.5
        btn_login.layer.borderColor = UIColor.white.cgColor
        btn_login.layer.cornerRadius = btn_login.frame.height/2
        btn_login.layer.masksToBounds = true
        
        //이전뷰를 모두 지워주고 심플로그인 화면만 남김
        var viewControllers = self.navigationController?.viewControllers
        viewControllers?.removeAll()
        viewControllers?.append(self)
        self.navigationController?.viewControllers = viewControllers!
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func tosTapped(_ sender: Any) {
        let tosViewController = storyboard?.instantiateViewController(withIdentifier: "tosViewController") as! tosViewController
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.modalPresentationStyle = .currentContext
        tosViewController.modalPresentationStyle = .overCurrentContext
        tosViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(tosViewController, animated: true, completion: nil)
    }
    
    @IBAction func privacyTapped(_ sender: Any) {
        let privacyViewController = storyboard?.instantiateViewController(withIdentifier: "privacyViewController") as! privacyViewController
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.modalPresentationStyle = .currentContext
        privacyViewController.modalPresentationStyle = .overCurrentContext
        privacyViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(privacyViewController, animated: true, completion: nil)
    }
    
    //내부 비디오 재생 함수
    /*func playLocalVideo(){
        
        let filePath:String? = Bundle.main.path(forResource: "오늘_소개영상", ofType: ".mp4")
        let url = NSURL(fileURLWithPath: filePath!)
        let player = AVPlayer(url: url as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        //비디오를 재생한다.
        self.present(playerViewController, animated:true){
            player.play()
        }
    }*/
    
    func loginAction(){
        let uid = Auth.auth().currentUser?.uid
        
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instance ID: \(error)")
            }else if let result = result {
                print("Remote instance ID token: \(result.token)")
                Database.database().reference().child("users").child(uid!).child("pushToken").setValue(result.token)
                Database.database().reference().child("users").child(uid!).child("platform").setValue("ios")

                KeychainWrapper.standard.set(true, forKey: "loginCheck")
                
                if let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarNavigationBar"){
                    tabBarController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    tabBarController.modalPresentationStyle = .fullScreen
                    self.present(tabBarController, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        let email = KeychainWrapper.standard.string(forKey: "email")
        let password = KeychainWrapper.standard.string(forKey: "pwd")
        
        if (email == nil){
            ToastViewController.show(message: "유효하지 않은 아이디입니다.", controller: self)
            
            KeychainWrapper.standard.removeObject(forKey: "email")
            KeychainWrapper.standard.removeObject(forKey: "pwd")
            KeychainWrapper.standard.removeObject(forKey: "loginCheck")
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let loginPage = storyBoard.instantiateViewController(withIdentifier: "firstPageController") as! firstPageController
            //loginPage.modalPresentationStyle = .overCurrentContext
            loginPage.modalPresentationStyle = .fullScreen
            loginPage.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(loginPage, animated: true, completion: nil)
        }
        
        Auth.auth().signIn(withEmail: email!, password: password! ){(user,Error) in
            if Error != nil{
                print(Error!)
                
                let err = AuthErrorCode(rawValue: Error!._code)
                
                if (err?.rawValue == 17009){
                    //동시로그인한 유저가 비밀번호를 변경한 경우
                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    let popupVC = storyBoard.instantiateViewController(withIdentifier: "pwdConfirmViewController") as! pwdConfirmViewController
                    popupVC.alertTitle = "비밀번호 입력"
                    popupVC.alertContent = "비밀번호가 변경되었습니다.\n변경된 비밀번호를 입력해주세요."
                    popupVC.loginState = false
                    popupVC.okAction = self.loginAction
                    popupVC.modalPresentationStyle = .overCurrentContext
                    popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.present(popupVC, animated: true, completion: nil)
                }else if (err?.rawValue == 17011){
                    //이메일이 유효하지 않은 경우 -> 동시 로그인 유저가 회원탈퇴한 경우
                    ToastViewController.show(message: "유효하지 않은 아이디입니다.", controller: self)
                    
                    KeychainWrapper.standard.removeObject(forKey: "email")
                    KeychainWrapper.standard.removeObject(forKey: "pwd")
                    KeychainWrapper.standard.removeObject(forKey: "loginCheck")

                    let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                    let loginPage = storyBoard.instantiateViewController(withIdentifier: "firstPageController") as! firstPageController
                    loginPage.modalPresentationStyle = .overCurrentContext
                    loginPage.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.present(loginPage, animated: true, completion: nil)
                }else{
                    ToastViewController.show(message: "로그인에 실패하였습니다.", controller: self)
                }
                return
            }else{
                KeychainWrapper.standard.set(email!, forKey: "email")
                KeychainWrapper.standard.set(password!, forKey: "pwd")
                self.loginAction()
            }
        }
    }
}
