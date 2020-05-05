//
//  simpleAlertViewController.swift
//  drink
//
//  Created by user on 11/11/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class simpleAlertViewController:UIViewController{
    
    @IBOutlet weak var label_alertTitle: UILabel!
    @IBOutlet weak var label_alertContent: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var popUpView: UIView!
    
    var alertTitle:String? = nil
    var alertContent:String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label_alertTitle.text = alertTitle
        label_alertContent.text = alertContent
        popUpView.layer.cornerRadius = 5.0
        popUpView.layer.masksToBounds = true
        
        label_alertContent.numberOfLines = 0
        label_alertContent.textAlignment = NSTextAlignment.center
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
