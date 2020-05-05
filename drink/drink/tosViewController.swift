//
//  tosViewController.swift
//  drink
//
//  Created by user on 22/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit

class tosViewController:UIViewController{
    
    @IBOutlet weak var serviceTosView: UIView!
    @IBOutlet weak var locationInfoView: UIView!
    
    @IBOutlet weak var btn_service: UIButton!
    @IBOutlet weak var btn_locationInfo: UIButton!
    
    var titleColor:UIColor?
    var statusBar:UIView?
    
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
            statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            if statusBar!.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar!.backgroundColor = UIColor(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }
        
        navigationController?.navigationBar.isHidden = true
        
        titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        btn_service.setTitleColor(titleColor, for: UIControl.State.normal)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 13, *)
        {
            
        }else{
            if statusBar!.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar!.backgroundColor = UIColor.clear
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func serviceTapped(_ sender: Any) {
        serviceTosView.isHidden = false
        locationInfoView.isHidden = true
        btn_service.setTitleColor(titleColor, for: UIControl.State.normal)
        btn_locationInfo.setTitleColor(.black, for: UIControl.State.normal)

    }
    
    @IBAction func locationInfoTapped(_ sender: Any) {
        serviceTosView.isHidden = true
        locationInfoView.isHidden = false
        btn_service.setTitleColor(.black, for: UIControl.State.normal)
        btn_locationInfo.setTitleColor(titleColor, for: UIControl.State.normal)
    }
    
    
}
