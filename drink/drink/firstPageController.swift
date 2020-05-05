//
//  firstPageController.swift
//  drink
//
//  Created by user on 14/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import AVFoundation
import AVKit

class firstPageController:UIViewController{
    
    @IBOutlet weak var btn_signUp: UIButton!
    @IBOutlet weak var btn_login: UIButton!
    
    private var statusBarView: UIView?

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

        
        btn_signUp.layer.cornerRadius = 10.0
        btn_signUp.layer.masksToBounds = true
        btn_login.layer.cornerRadius = 10.0
        btn_login.layer.masksToBounds = true
        
        self.setNeedsStatusBarAppearanceUpdate()

        //playLocalVideo()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    override func viewDidAppear(_ animated: Bool) {
        if KeychainWrapper.standard.string(forKey: "enrollProfile") != nil{
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let signUp_EnrollProfileController = storyBoard.instantiateViewController(withIdentifier: "signUp_EnrollProfileController") as! signUp_EnrollProfileController
            signUp_EnrollProfileController.modalPresentationStyle = .fullScreen
            self.present(signUp_EnrollProfileController, animated: true, completion: nil)
        }
        //KeychainWrapper.standard.removeObject(forKey: "blockSignUp")
        //가입금지 막아주기
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let blockDate = KeychainWrapper.standard.string(forKey: "blockSignUp")
        if blockDate != nil{
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy.MM.dd"
            let date = Date()
            let todayDate = dateFormatter.string(from: date)
            
            let signUpIsPossible = compareDate(today: todayDate, blockDate: blockDate!)
            
            if signUpIsPossible == false{
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let popupVC = storyBoard.instantiateViewController(withIdentifier: "simpleAlertViewController") as! simpleAlertViewController
                popupVC.alertTitle = "가입불가"
                popupVC.alertContent = "탈퇴한지 30일이 지나지않아\n 가입할 수 없습니다."
                popupVC.modalPresentationStyle = .overCurrentContext
                //popupVC.modalPresentationStyle = .fullScreen
                popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                self.present(popupVC, animated: true, completion: nil)
                return
            }
        }

        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "selectPopUpController")
        popupVC.modalPresentationStyle = .overCurrentContext
        //popupVC.modalPresentationStyle = .fullScreen
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve

        present(popupVC, animated: true, completion: nil)
    }
    
    func compareDate(today:String,blockDate:String) -> Bool{
        let separatedData = blockDate.split(separator: ".")
        let separatedToday = today.split(separator: ".")
        
        let year2 = Int(separatedData[0])!
        let year1 = Int(separatedToday[0])!
        
        let month2 = Int(separatedData[1])!
        let month1 = Int(separatedToday[1])!
        
        let day2 = Int(separatedData[2])!
        let day1 = Int(separatedToday[2])!
        
        
        if (year1 - year2 >= 2){
            //2년이상 차이날때 -> 패스
            print("2년 이상 지남")
            return true
        }else if (year1 - year2 == 1){
            //연도가 1년 차이나는 경우
            if(month1-month2 < 0){
                //1년이 덜 지난 경우
                if(month1 + (12 - month2) <= 1){
                    //연도는 바뀌었지만 한달이 채 지나지 않은 경우
                    if(day1-day2 < 0){
                        //30일 차이가 나지 않는 경우 -> 회원가입불가
                        print("연도는 바뀌었지만 한달이 채 지나지 않은 경우 회원가입불가")
                        return false
                    }else{
                        //딱 한달 지났거나 한달이 넘은 경우 -> 패스
                        return true
                    }
                }else{
                    //연도가 바뀌고 두달이상 지난경우 -> 패스
                    return true
                }
            }else{
                //1년이 넘었거나 딱1년 된 경우 -> 패스
                return true
            }
        }else{
            //연도가 1년도 차이나지 않는 경우
            if(month1-month2 >= 2){
                //2달이 넘은 경우 -> 패스
                return true
            }else if(month1 - month2 == 1){
                //1달 차이가 나는 경우
                if(day1-day2 < 0){
                    //30일 차이가 나지 않는 경우 -> 회원가입불가
                    print("1달 지났지만 30일 차이가 나지 않는 경우 회원가입불가")
                    return false
                }else{
                    //딱 한달 지났거나 한달이 넘은 경우 -> 패스
                    return true
                }
            }else{
                //1달도 차이가 나지 않는경우
                if(day1-day2 > 30){
                    //날짜가 30일 지난 경우 ->패스
                    return true
                }else{
                    //30일이 지나지 않은 경우 -> 회원가입불가
                    print("30일이 지나지 않은 경우 ->회원가입불가")
                    return false
                }
            }
        }
    }
    
}
