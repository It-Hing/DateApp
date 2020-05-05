//
//  noticeViewController.swift
//  drink
//
//  Created by user on 17/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit

class noticeViewController:UIViewController{
    
    @IBOutlet weak var label_manual: UILabel!
    @IBOutlet weak var label_policy: UILabel!
    @IBOutlet weak var label_inquiry: UILabel!
    
    @IBOutlet weak var height_manual: NSLayoutConstraint!
    @IBOutlet weak var height_policy: NSLayoutConstraint!
    @IBOutlet weak var height_inquiry: NSLayoutConstraint!
    
    @IBOutlet weak var manualImageView: UIImageView!
    @IBOutlet weak var policyImageview: UIImageView!
    @IBOutlet weak var inquiryImageView: UIImageView!
    
    @IBOutlet weak var manualTextView: UITextView!
    @IBOutlet weak var policyTextView: UITextView!
    @IBOutlet weak var inquiryTextView: UITextView!
    
    var up:UIImage?
    var down:UIImage?
    
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
        
        label_manual.isUserInteractionEnabled = true
        label_manual.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(manualTapped)))
        label_policy.isUserInteractionEnabled = true
        label_policy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(policyTapped)))
        label_inquiry.isUserInteractionEnabled = true
        label_inquiry.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(inquiryTapped)))
        
        up = UIImage(named: "baseline_keyboard_arrow_up_black_36pt")
        down = UIImage(named: "baseline_keyboard_arrow_down_black_36pt")
        
        //manualTextView.text = "*이용방법*\n\n1.신뢰할 수 잇는 프로필과 잘 나온 사진을 업로드하신 후 가입해주세요.\n\n2.'오늘'은 가입 후 24시간 이내에 관리자의 프로필 심사를 받게 됩니다.\n(프로필에 문제가 있을 시 거절될 수 있습니다.)\n\n3.지도에 표시된 회원들의 프로필을 "
    }
    
    @objc func manualTapped(){
        if(height_manual.constant == 0){
            height_manual.constant = 410
            manualImageView.image = up
        }else{
            height_manual.constant = 0
            manualImageView.image = down
        }
    }
    
    @objc func policyTapped(){
        if(height_policy.constant == 0){
            height_policy.constant = 450
            policyImageview.image = up
        }else{
            height_policy.constant = 0
            policyImageview.image = down
        }
    }
    
    @objc func inquiryTapped(){
        if(height_inquiry.constant == 0){
            height_inquiry.constant = 120
            inquiryImageView.image = up
        }else{
            height_inquiry.constant = 0
            inquiryImageView.image = down
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.barStyle = .default
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)
    }
    
}
