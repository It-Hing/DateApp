//
//  alertViewController.swift
//  drink
//
//  Created by user on 08/11/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit

class alertViewController:UIViewController{
    
    @IBOutlet weak var label_alertTitle: UILabel!
    @IBOutlet weak var label_alertContent: UILabel!
    var okAction:(() -> ())? = nil
    @IBOutlet weak var backView: UIView!
    var alertTitle:String?
    var alertContent:String?
    var ver:Int?
    
    @IBOutlet weak var popUpView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (ver == 1){
            label_alertTitle.backgroundColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
            label_alertTitle.textColor = .white
        }else{
            popUpView.layer.cornerRadius = 5.0
        }
        
        label_alertContent.numberOfLines = 0
        label_alertContent.textAlignment = NSTextAlignment.center
        label_alertTitle.text = alertTitle
        label_alertContent.text = alertContent
        popUpView.isUserInteractionEnabled = true
        popUpView.layer.masksToBounds = true
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        okAction!()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
