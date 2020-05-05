//
//  storeViewController.swift
//  drink
//
//  Created by user on 09/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class storeViewController:UIViewController,SKProductsRequestDelegate{
    
    @IBOutlet weak var label_firstItem: UILabel!
    @IBOutlet weak var label_secondItem: UILabel!
    @IBOutlet weak var label_thirdItem: UILabel!
    @IBOutlet weak var label_forthItem: UILabel!
    @IBOutlet weak var label_recommend: UILabel!
    @IBOutlet weak var label_coupon: UILabel!
    
    @IBOutlet weak var label_firstItemBg: UILabel!
    @IBOutlet weak var label_secondItemBg: UILabel!
    @IBOutlet weak var label_thirdItemBg: UILabel!
    @IBOutlet weak var label_fourthItemBg: UILabel!
    @IBOutlet weak var label_recommendBg: UILabel!
    @IBOutlet weak var label_couponBg: UILabel!
    
    @IBOutlet weak var btn_history: UIButton!
    
    @IBOutlet weak var label_historyBg: UILabel!
    var itemIndex:Int?
    
    //멤버변수들
    let iapObserver = storeObserver()
    var productRequest:SKProductsRequest?
    
    //입력받은 상품정보들을 저장하는 변수들
    var validProductArray = [SKProduct]()

    var statusBar: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        btn_history.layer.cornerRadius = btn_history.frame.height/2
        
        //loadingVC.show()
        
        label_firstItem.isUserInteractionEnabled = true
        label_secondItem.isUserInteractionEnabled = true
        label_thirdItem.isUserInteractionEnabled = true
        label_forthItem.isUserInteractionEnabled = true
        label_firstItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(firstItemTapped)))
        label_secondItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(secondItemTapped)))
        label_thirdItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thirdItemTapped)))
        label_forthItem.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fourthItemTapped)))
        
        //페이먼트 관련 설정 해주기
        SKPaymentQueue.default().add(iapObserver)
        
        //상품정보를 가지고 오는 리퀘스트를 설정하기
        let pIDs = Set(["com.sinabro.drink.heart1",
                        "com.sinabro.drink.heart2",
                        "com.sinabro.drink.heart3",
                        "com.sinabro.drink.heart4"])
        productRequest = SKProductsRequest(productIdentifiers: pIDs)
        productRequest!.delegate = self
        
        //앱스토어 상품정보를 요청하기
        productRequest!.start()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //statusBar?.removeFromSuperview()
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barStyle = .default
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.tintColor = .darkGray
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)
        self.navigationController?.navigationBar.backgroundColor = .white
        
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
    }
    
    override func viewDidLayoutSubviews() {
        drawShadow(settingLabel: label_firstItem, bg: label_firstItemBg)
        drawShadow(settingLabel: label_secondItem, bg: label_secondItemBg)
        drawShadow(settingLabel: label_thirdItem, bg: label_thirdItemBg)
        drawShadow(settingLabel: label_forthItem, bg: label_fourthItemBg)
        drawShadow(settingLabel: label_recommend, bg: label_recommendBg)
        drawShadow(settingLabel: label_coupon, bg: label_couponBg)
        
        btn_history.layer.cornerRadius = btn_history.frame.height/2
        btn_history.layer.masksToBounds = true
        
        //label_myLocation.layer.cornerRadius = 10
        let shadowPath = UIBezierPath(roundedRect: btn_history.bounds, cornerRadius: btn_history.frame.height/2)
        label_historyBg.layer.masksToBounds = false
        label_historyBg.layer.shadowRadius = btn_history.frame.height/2
        label_historyBg.layer.shadowColor = UIColor.black.cgColor
        label_historyBg.layer.shadowOffset = CGSize(width: 1, height: 1)
        label_historyBg.layer.shadowOpacity = 0.1
        label_historyBg.layer.shadowPath = shadowPath.cgPath//그림자 넣기
    }
    
    func drawShadow(settingLabel:UILabel, bg:UILabel){
        settingLabel.layer.cornerRadius = 10
        settingLabel.layer.masksToBounds = true
        
        //label_myLocation.layer.cornerRadius = 10
        let shadowPath = UIBezierPath(roundedRect: settingLabel.bounds, cornerRadius: 10)
        bg.layer.masksToBounds = false
        bg.layer.shadowRadius = 10.0
        bg.layer.shadowColor = UIColor.black.cgColor
        bg.layer.shadowOffset = CGSize(width: 1, height: 1)
        bg.layer.shadowOpacity = 0.2
        bg.layer.shadowPath = shadowPath.cgPath//그림자 넣기
    }
    
    @objc func firstItemTapped(){
        itemIndex = 0
        presentAlert(heartNum: "120")
    }
    
    @objc func secondItemTapped(){
        itemIndex = 1
        presentAlert(heartNum: "240")
    }
    
    @objc func thirdItemTapped(){
        itemIndex = 2
        presentAlert(heartNum: "660")
    }
    
    @objc func fourthItemTapped(){
        itemIndex = 3
        presentAlert(heartNum: "1,380")
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func presentAlert(heartNum:String){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = tryPaymentQueue
        popupVC.alertTitle = "하트구매"
        if heartNum == "120"{
            popupVC.alertContent = "[7500원]\n부가세별도\n하트\(heartNum)개 상품을 구매하시겠습니까?"
        }else if heartNum == "240"{
            popupVC.alertContent = "[12000원]\n부가세별도\n하트\(heartNum)개 상품을 구매하시겠습니까?"
        }else if heartNum == "660"{
            popupVC.alertContent = "[30000원]\n부가세별도\n하트\(heartNum)개 상품을 구매하시겠습니까?"
        }else if heartNum == "1,380"{
            popupVC.alertContent = "[55000원]\n부가세별도\n하트\(heartNum)개 상품을 구매하시겠습니까?"
        }
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func tryPaymentQueue(){
        let payment = SKMutablePayment(product: validProductArray[itemIndex!])
        SKPaymentQueue.default().add(payment)
        //print("변화가 있는지?")
    }
    
    //상품적재 메소드(앱스토어에 접근해서 상품가져옴)
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("상품개수 \(response.products.count)")
        print("확인하지 못한 상품 개수 \(response.invalidProductIdentifiers.count)")
        
        for product in response.products{
            print("이름:\(product.localizedTitle)\n가격:\(product.price)")
            validProductArray.append(product)
        }
        
        for product in response.invalidProductIdentifiers{
            print("이름:\(product)")
            //validProductArray.append(product)
        }
        //loadingVC.hide()
    }
}
