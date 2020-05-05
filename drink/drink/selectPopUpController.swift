//
//  selectPopUpController.swift
//  drink
//
//  Created by user on 14/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class selectPopUpController:UIViewController{
    
    var sex:String?
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var btn_man: UIButton!
    @IBOutlet weak var btn_woman: UIButton!
    
    var manSelect:UIImage?
    var manUnselect:UIImage?
    var womanSelect:UIImage?
    var womanUnselect:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 5.0
        popUpView.layer.masksToBounds = true
        
        backView.isUserInteractionEnabled = true
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        backView.addGestureRecognizer(tap)
        
        manSelect = UIImage(named: "manSelect")
        manUnselect = UIImage(named: "manUnselect")
        womanSelect = UIImage(named: "womanSelect")
        womanUnselect = UIImage(named: "womanUnselect")
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    /*@IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }*/
    
    @IBAction func manButtonTapped(_ sender: Any) {
        if (sex != "남자"){
            btn_man.setImage(manSelect, for: UIControl.State.normal)
            btn_woman.setImage(womanUnselect, for: UIControl.State.normal)
            sex = "남자"
        }
    }
    
    @IBAction func womanButtonTapped(_ sender: Any) {
        if (sex != "여자"){
            btn_woman.setImage(womanSelect, for: UIControl.State.normal)
            btn_man.setImage(manUnselect, for: UIControl.State.normal)
            sex = "여자"
        }
    }
    
    @IBAction func okButtonTapped(_ sender: Any) {
        if sex != nil{
            //UserDefaults.standard.set(sex, forKey: "sex")
            KeychainWrapper.standard.set(sex!, forKey: "mysex")
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let signUp_EnrollEmailController = storyBoard.instantiateViewController(withIdentifier: "signUp_EnrollEmailController") as! signUp_EnrollEmailController
            //signUp_EnrollEmailController.modalPresentationStyle = .overCurrentContext
            signUp_EnrollEmailController.modalPresentationStyle = .fullScreen
            present(signUp_EnrollEmailController, animated: true, completion: nil)
        }
    }
}
