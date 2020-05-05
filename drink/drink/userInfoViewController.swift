//
//  userInfoViewController.swift
//  drink
//
//  Created by user on 14/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Alamofire
import FirebaseAuth
import FirebaseDatabase

class userInfoViewController:UIViewController{
    
    var usermodel:userModel? = nil
    var prevPage:Int?//이전페이지에 따라 화면에 보여주는 양식이 조금 다름
    //1:맵뷰 2:푸시리스트뷰 3:나자신을 클릭했을 때 4:채팅방에서 사진을 클릭해서 들어왔을 때
    var chatDupCheck:Bool?//방 중복체크를 위한 변수
    let db = Database.database().reference()
    var imageIndex:[String] = []
    var destinationUid:String?
    var freecoupon:String?
    var distance:String?
    
    @IBOutlet weak var infoCollectionView: UICollectionView!
    @IBOutlet weak var callButtonView: UIView!
    @IBOutlet weak var profileButtonView: UIView!
    @IBOutlet weak var selectButtonView: UIView!
    
    @IBOutlet weak var acceptButtonView: UIView!
    @IBOutlet weak var rejectButtonView: UIView!
    
    @IBOutlet weak var acceptImageView: UIImageView!
    @IBOutlet weak var rejectImageView: UIImageView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var label_userName: UILabel!
    @IBOutlet weak var label_userAge: UILabel!
    @IBOutlet weak var label_content: UILabel!
    @IBOutlet weak var label_comment: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    @IBOutlet weak var label_imageMent: UILabel!
    
    @IBOutlet weak var profileButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var callButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var label_distance: UILabel!
    @IBOutlet weak var label_dash: UILabel!
    
    
    var databaseRef_user:DatabaseReference?
    var observe_user:UInt?
    var databaseRef:DatabaseReference?
    var observe:UInt?
    
    //var databaseRef_usermore:DatabaseReference?
    //var observe_usermore:UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoCollectionView.delegate = self
        infoCollectionView.dataSource = self
        
        /*let rightButton: UIBarButtonItem = UIBarButtonItem(title: "차단", style: UIBarButtonItem.Style.plain, target: self, action: #selector(blockTapped))
        navigationItem.rightBarButtonItem = rightButton;*/
        
        //navigationItem.hidesBackButton = true
        /*let backButton: UIBarButtonItem = UIBarButtonItem(title: "뒤로", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton*/
        
        /*let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor =
                UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        }*/
        //상태바 색변경
        
        heartImageView.tintColor = .red
        pageControl.numberOfPages = 0
        
        profileButtonHeight.constant = view.frame.height/9
        callButtonHeight.constant = view.frame.height/9
        self.label_comment.isHidden = true
        label_imageMent.isHidden = true

        let uid = Auth.auth().currentUser?.uid
        
        //맵뷰, 푸시리스트, 채팅방에서 넘어왔을 때
        if (prevPage == 1 || prevPage == 2 || prevPage == 4){
            if destinationUid == uid{
                blockButton.isHidden = true
                callButtonView.isHidden = true
            }
            
            if(prevPage == 4){
                label_dash.isHidden = true
                label_distance.isHidden = true
            }
            
            databaseRef = db.child("users").child(destinationUid!)
            observe = databaseRef!.observe(DataEventType.value, with: {(datasnapshot) in
                if(datasnapshot.exists() == false){
                    //print("탈퇴한 사용자입니다.")
                    ToastViewController.show(message: "사용자의 정보를 불러올 수 없습니다.", controller: self)
                    self.dismiss(animated: true, completion: nil)
                }else{
                    let data = datasnapshot.value as! [String:AnyObject]
                    self.usermodel = userModel(JSON: data)
                    self.usermodel!.uid = datasnapshot.key
                    let uid = Auth.auth().currentUser?.uid
                    
                    //상대방의 위치가 꺼져있으면 정보를 불러오지 않음
                    if(self.usermodel?.sex == "남자"){
                        self.db.child("man_location").child(self.usermodel!.uid!).observeSingleEvent(of: DataEventType.value, with: {(dataSnapshot) in
                            if(!dataSnapshot.exists()){
                                //1번(맵뷰) 일때는 위치가 꺼져있으면 뷰를 없애고
                                //나머지는 지우면 안되고 거리가 안뜨게 함
                                if(self.prevPage == 1){
                                    ToastViewController.show(message: "사용자의 정보를 불러올 수 없습니다.", controller: self)
                                    self.dismiss(animated: true, completion: nil)
                                }else{
                                    self.label_dash.isHidden = true
                                    self.label_distance.text = "위치 끔"
                                }
                            }else{
                                if(self.prevPage == 2){
                                    var location:[String] = []
                                    
                                    for data in dataSnapshot.children.allObjects as! [DataSnapshot]{
                                        let new = String(describing: data.value!)
                                        location.append(new)
                                    }
                                    self.usermodel?.latitude = Double(location[0])
                                    self.usermodel?.longitude = Double(location[1])
                                    let myLat = UserDefaults.standard.value(forKey: "latitude")
                                    
                                    let myLon = UserDefaults.standard.value(forKey: "longitude")
                                    
                                    if (myLat != nil && myLon != nil){
                                        self.distance = self.getDistance(myLat: myLat as! Double, myLon: myLon as! Double, desLat: self.usermodel!.latitude!, desLon: self.usermodel!.longitude!)
                                        self.label_distance.text = self.distance
                                        self.label_dash.isHidden = false
                                    }else{
                                        self.label_distance.text = "내 위치 정보없음"
                                        self.label_dash.isHidden = true
                                    }
                                }
                            }
                        })
                    }else{
                        self.db.child("woman_location").child(self.usermodel!.uid!).observeSingleEvent(of: DataEventType.value, with: {(dataSnapshot) in
                            if(!dataSnapshot.exists()){
                                if(self.prevPage == 1){
                                    ToastViewController.show(message: "사용자의 정보를 불러올 수 없습니다.", controller: self)
                                    self.dismiss(animated: true, completion: nil)
                                }else{
                                    self.label_dash.isHidden = true
                                    self.label_distance.text = "위치 끔"
                                }
                            }else{
                                if(self.prevPage == 2){
                                    var location:[String] = []
                                    
                                    for data in dataSnapshot.children.allObjects as! [DataSnapshot]{
                                        let new = String(describing: data.value!)
                                        location.append(new)
                                    }
                                    self.usermodel?.latitude = Double(location[0])
                                    self.usermodel?.longitude = Double(location[1])
                                    let myLat = UserDefaults.standard.value(forKey: "latitude")
                                    
                                    let myLon = UserDefaults.standard.value(forKey: "longitude")
                                    
                                    if (myLat != nil && myLon != nil){
                                        self.distance = self.getDistance(myLat: myLat as! Double, myLon: myLon as! Double, desLat: self.usermodel!.latitude!, desLon: self.usermodel!.longitude!)
                                        self.label_distance.text = self.distance
                                        self.label_dash.isHidden = false
                                    }else{
                                        self.label_distance.text = "내 위치 정보없음"
                                        self.label_dash.isHidden = true
                                    }
                                }
                            }
                        })
                    }
                    
                    if (self.usermodel?.blockList.keys.contains(uid!))!{
                        print("상대방을 차단하였습니다.")
                        self.dismiss(animated: true, completion: nil)
                    }
                    if (self.usermodel?.blockedList.keys.contains(uid!))!{
                        print("상대방이 차단하였습니다.")
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.imageIndex = (self.usermodel?.photo.keys.sorted())!
                    self.label_userName.text = self.usermodel?.username
                    if(self.usermodel?.comment != nil){
                        self.label_comment.text = self.usermodel?.comment
                        self.label_comment.isHidden = false
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ko_KR")
                    dateFormatter.dateFormat = "yyyy"
                    let date = Date()
                    let today = Int(dateFormatter.string(from: date))
                    let birthYear = Int(self.usermodel!.age!)
                    let age = today! - birthYear! + 1
                    let userage:String?

                    if (age >= 20 && age <= 23){
                        userage = "20대 초반"
                    }else if(age >= 24 && age <= 26){
                        userage = "20대 중반"
                    }else if(age >= 27 && age <= 29){
                        userage = "20대 후반"
                    }else if(age >= 30 && age <= 33){
                        userage = "30대 초반"
                    }else if(age >= 34 && age <= 36){
                        userage = "30대 중반"
                    }else if(age >= 37 && age <= 39){
                        userage = "30대 후반"
                    }else if(age >= 40){
                        userage = "40대 이상"
                    }else if(age < 20){
                        userage = "10대"
                    }else{
                        userage = "나이미상"
                    }
                    
                    if(self.distance != nil){
                        self.label_distance.text = self.distance
                    }
                    
                    self.label_userAge.text = userage
                    let tall = self.usermodel?.tall
                    let body = self.usermodel?.body
                    let personality = self.usermodel!.personality
                    let sex = self.usermodel?.sex
                    let content = "\(tall!), \(body!)체형과 \(personality!) 성격을 가진 \n\(sex!)입니다."
                    
                    self.label_content.text = content
                    self.label_content.numberOfLines = 0
                    self.pageControl.numberOfPages = (self.usermodel?.photo.count)!
                    self.infoCollectionView.reloadData()
                }
            })
        }
        
        if prevPage == 1{
            profileButtonView.isHidden = true
            selectButtonView.isHidden = true
            //callButtonView.layer.borderWidth = 0.5
            //callButtonView.layer.borderColor = UIColor.lightGray.cgColor
            
            callButtonView.isUserInteractionEnabled = true
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(callButtonTapped))
            callButtonView.addGestureRecognizer(tap)

        }else if prevPage == 2{
            callButtonView.isHidden = true
            //profileButton.isHidden = true
            profileButtonView.isHidden = true
            //let buttonColor = UIColor(red: 142.0/255, green: 130.0/255, blue: 250.0/255, alpha: 1.0).cgColor
            //let buttonColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0).cgColor
            acceptImageView.image = acceptImageView.image?.maskWithColor(color: .green)
            rejectImageView.image = rejectImageView.image?.maskWithColor(color: .red)
            
            acceptButtonView.isUserInteractionEnabled = true
            let acceptTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(acceptButtonTapped))
            acceptButtonView.addGestureRecognizer(acceptTap)
            
            rejectButtonView.isUserInteractionEnabled = true
            let rejectTap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rejectButtonTapped))
            rejectButtonView.addGestureRecognizer(rejectTap)
            
        }else if prevPage == 3{
            selectButtonView.isHidden = true

            blockButton.isHidden = true
            callButtonView.isHidden = true
            label_dash.isHidden = true
            label_distance.isHidden = true
            
            profileButtonView.isUserInteractionEnabled = true
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileButtonTapped))
            profileButtonView.addGestureRecognizer(tap)
            
            getUserModel()
        }else if prevPage == 4{
            callButtonView.isHidden = true
            selectButtonView.isHidden = true
            profileButtonView.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.tintColor = .white
        
        
        if #available(iOS 13, *)
        {

        }else{
            let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
            if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar.backgroundColor = UIColor.clear
            }
        }
        //상태바 색변경
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        //상대방 디비는 뷰가 사라질때 무조건 풀어줌
        if observe != nil{
            self.databaseRef?.removeAllObservers()
        }
        
        print("옵저버 풀어줌")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        
        self.navigationController?.navigationBar.tintColor = titleColor
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func getDistance(myLat:Double, myLon:Double, desLat:Double, desLon:Double) -> String{
        let myLoc = CLLocation(latitude: myLat, longitude: myLon)
        let destinationLoc = CLLocation(latitude: desLat, longitude: desLon)
        
        var distance = myLoc.distance(from: destinationLoc)
        
        var newDistance:String?
        
        if (distance > 1000){
            distance = distance / 1000
            distance = distance.rounded()
            newDistance = "거리 \(Int(distance))km"
        }else{
            newDistance = "거리 0km"
        }
        
        return newDistance!
    }
    
    func getUserModel(){
        let uid = Auth.auth().currentUser?.uid
        
        databaseRef_user = db.child("users").child(uid!)
        observe_user = databaseRef_user!.observe(DataEventType.value, with: {(datasnapshot) in
            let data_user = datasnapshot.value as! [String:AnyObject]
            self.usermodel = userModel(JSON: data_user)
            self.usermodel?.uid = datasnapshot.key
            self.label_userName.text = self.usermodel?.username
            self.imageIndex = (self.usermodel?.photo.keys.sorted())!
            self.pageControl.numberOfPages = (self.usermodel?.photo.count)!
            if(self.usermodel?.comment != nil){
                self.label_comment.text = self.usermodel?.comment
                self.label_comment.isHidden = false
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy"
            let date = Date()
            let today = Int(dateFormatter.string(from: date))
            let birthYear = Int(self.usermodel!.age!)
            let age = today! - birthYear! + 1
            let userage:String?
            
            if (age >= 20 && age <= 23){
                userage = "20대 초반"
            }else if(age >= 24 && age <= 26){
                userage = "20대 중반"
            }else if(age >= 27 && age <= 29){
                userage = "20대 후반"
            }else if(age >= 30 && age <= 33){
                userage = "30대 초반"
            }else if(age >= 34 && age <= 36){
                userage = "30대 중반"
            }else if(age >= 37 && age <= 39){
                userage = "30대 후반"
            }else if(age >= 40){
                userage = "40대 이상"
            }else if(age < 20){
                userage = "10대"
            }else{
                userage = "나이미상"
            }
            
            self.label_userAge.text = userage
            let tall = self.usermodel?.tall
            let body = self.usermodel?.body
            let personality = self.usermodel!.personality
            let sex = self.usermodel?.sex
            
            let content = "\(tall!), \(body!)체형과 \(personality!) 성격을 가진 \n\(sex!)입니다."
            
            self.label_content.text = content
            self.label_content.numberOfLines = 0
            
            self.infoCollectionView.reloadData()
        })
    }
    
    /*@IBAction func profileButtonTapped(_ sender: Any) {
        if usermodel == nil{
            return
        }
        
        let myProfileController = storyboard?.instantiateViewController(withIdentifier: "myProfileController") as! myProfileController
        myProfileController.usermodel = usermodel
        self.present(myProfileController, animated: true, completion: nil)
    }*/
    
    @objc func profileButtonTapped(){
        if usermodel == nil{
            return
        }
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = self.moveToProfile
        popupVC.alertTitle = "프로필 편집"
        popupVC.alertContent = "프로필화면으로 이동하시겠습니까?"
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func moveToProfile(){
        dismiss(animated: true, completion: nil)
        let myProfileController = storyboard?.instantiateViewController(withIdentifier: "myProfileController") as! myProfileController
        myProfileController.usermodel = usermodel
        myProfileController.modalPresentationStyle = .fullScreen
        self.present(myProfileController, animated: true, completion: nil)
    }
    
    @objc func callButtonTapped(){
        let uid = Auth.auth().currentUser?.uid
        self.db.child("users").child(uid!).child("freeCoupon").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
            self.freecoupon = String(describing: datasnapshot.value!)
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
            popupVC.okAction = self.callAction
            popupVC.alertTitle = "오늘뭐해"
            if (Int(self.freecoupon!)! > 0){
                popupVC.alertContent = "무료쿠폰을 사용하시겠습니까?\n하트는 소모되지 않습니다."
            }else{
                popupVC.alertContent = "하트 30개를 사용합니다."
            }
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            popupVC.ver = 1
            self.present(popupVC, animated: true, completion: nil)
        })
    }
    
    func callAction(){
        let uid = Auth.auth().currentUser?.uid
        self.db.child("users").child(uid!).child("freeCoupon").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
            var coupon = String(describing: datasnapshot.value!)
            var couponnum = Int(coupon)!
            if (couponnum > 0){
                couponnum = couponnum - 1
                coupon = String(describing: couponnum)
                self.db.child("users").child(uid!).child("freeCoupon").setValue(coupon, withCompletionBlock: { (err, ref) in
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ko_KR")
                    dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
                    let date = Date()
                    let time = dateFormatter.string(from: date)
                    self.db.child("users").child(self.usermodel!.uid!).child("pushList").child(uid!).setValue(time) { (err, ref) in
                        ToastViewController.show(message: "요청완료", controller: self)
                        
                        self.sendFCM(pushText: "\((Auth.auth().currentUser?.displayName)!)님이 대화를 요청합니다.", kind: "p")
                    }
                })
            }else{
                self.db.child("users").child(uid!).child("heart").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
                    var heart = String(describing: datasnapshot.value!)
                    var num = Int(heart)
                    //print(num)
                    if (num! >= 30){
                        num = num! - 30
                        heart = String(describing: num!)
                        self.db.child("users").child(uid!).child("heart").setValue(heart, withCompletionBlock: { (err, ref) in
                            //print(num)
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "ko_KR")
                            dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
                            var date = Date()
                            var time = dateFormatter.string(from: date)
                            self.db.child("users").child(self.usermodel!.uid!).child("pushList").child(uid!).setValue(time) { (err, ref) in
                                ToastViewController.show(message: "요청완료", controller: self)

                                self.sendFCM(pushText: "\((Auth.auth().currentUser?.displayName)!)님이 대화를 요청합니다.", kind: "p")
                            }
                            
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            date = Date()
                            time = dateFormatter.string(from: date)
                            self.db.child("Buys").child(uid!).childByAutoId().setValue([
                                "buys_change" : "-30",
                                "buys_comment" : "대화요청",
                                "buys_date" : time,
                                "buys_id" : "ios",
                                "current_heart" : heart
                                ])
                        })
                    }else{
                        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
                        popupVC.okAction = self.moveToStore
                        popupVC.alertTitle = "하트수 부족"
                        popupVC.alertContent = "하트가 부족합니다.\n스토어로 이동하시겠습니까?"
                        popupVC.modalPresentationStyle = .overCurrentContext
                        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                        popupVC.ver = 1
                        self.present(popupVC, animated: true, completion: nil)
                    }
                })
            }
        })
    }
    
    func moveToStore(){
        dismiss(animated: true, completion: nil)
        /*let storeViewController = self.storyboard?.instantiateViewController(withIdentifier: "storeViewController") as! storeViewController
        self.navigationController?.pushViewController(storeViewController, animated: true)*/
        let storeViewController = storyboard?.instantiateViewController(withIdentifier: "storeViewController") as! storeViewController
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.modalPresentationStyle = .currentContext
        storeViewController.modalPresentationStyle = .overCurrentContext
        storeViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(storeViewController, animated: true, completion: nil)
    }
    
    @IBAction func blockButtonTapped(_ sender: Any) {
        print("blockTapped")
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = blockAction
        popupVC.alertTitle = "오늘뭐해"
        popupVC.alertContent = "차단하시겠습니까?\n상대방은 내 정보를 볼 수 없습니다."
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        popupVC.ver = 1
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func blockAction(){
        let uid = Auth.auth().currentUser?.uid
        self.db.child("users").child(uid!).child("blockList").child(self.usermodel!.uid!).setValue(true) { (err, ref) in
            if (err != nil){
                print(err as Any)
                return
            }else{
                self.db.child("users").child(self.usermodel!.uid!).child("blockedList").child(uid!).setValue(true, withCompletionBlock: { (err, ref) in
                    if (err != nil){
                        print(err as Any)
                        return
                    }else{
                        self.db.child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                            
                            for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                                if let chatRoomdic = item.value as? [String:AnyObject]{
                                    let chatroom = chatModel(JSON: chatRoomdic)
                                    chatroom?.roomid = item.key
                                    if (chatroom?.users[(self.usermodel?.uid)!] == true){
                                        self.db.child("chatrooms").child((chatroom?.roomid)!).child("users").child(uid!).setValue(false, withCompletionBlock: { (err, ref) in
                                            
                                            print("차단한 상대방과의 대화방에서 나감")
                                        })
                                    }
                                }
                            }
                        })
                        self.db.child("users").child(uid!).child("pushList").child((self.usermodel?.uid!)!).removeValue(completionBlock: { (err, ref) in})
                        self.db.child("users").child((self.usermodel?.uid!)!).child("pushList").child(uid!).removeValue(completionBlock: { (err, ref) in})
                        
                        print("block success")
                        //self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    /*@objc public func blockTapped(){
        print("blockTapped")
        let uid = Auth.auth().currentUser?.uid
        
        let msg = "차단하면 서로 상대방의 정보를 볼 수 없습니다."
        let alert = UIAlertController(title: "차단", message: msg, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel){
            (action : UIAlertAction) -> Void in
            //self.dismiss(animated: true)
        }
        
        let okayAction = UIAlertAction(title: "차단", style: .default){
            (action : UIAlertAction) -> Void in
            //확인 했을때 처리할 내용
            self.db.child("users").child(uid!).child("blockList").child(self.usermodel!.uid!).setValue(true) { (err, ref) in
                if (err != nil){
                    print(err as Any)
                    return
                }else{
                    self.db.child("users").child(self.usermodel!.uid!).child("blockedList").child(uid!).setValue(true, withCompletionBlock: { (err, ref) in
                        if (err != nil){
                            print(err as Any)
                            return
                        }else{
                            print("block success")
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }*/
    
    /*@objc public func backTapped(){
        self.navigationController?.popViewController(animated: true)
    }*/
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        //내 디비를 보고 있다가 엑스버튼이 눌리면 풀어줌
        //viewWilldisappear에서 풀어주면 프로필 설정 페이지로 갈때도 풀려버림
        if observe_user != nil{
            self.databaseRef_user?.removeAllObservers()
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    /*@IBAction func rejectButtonTapped(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = rejectAction
        popupVC.alertTitle = "거절"
        popupVC.alertContent = "상대방의 제안을 거절하시겠습니까?"
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
        /*let msg = "상대방의 제안을 거절하시겠습니까?"
        let alert = UIAlertController(title: "거절", message: msg, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel){
            (action : UIAlertAction) -> Void in
            //self.dismiss(animated: true)
        }
        
        let okayAction = UIAlertAction(title: "거절", style: .default){
            (action : UIAlertAction) -> Void in
            //확인 했을때 처리할 내용
            self.db.child("users").child(uid!).child("pushList").child(self.usermodel!.uid!).removeValue { (err, ref) in
                self.dismiss(animated: true, completion: nil)
                //self.navigationController?.popViewController(animated: true)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)*/
    }*/
    
    /*@IBAction func acceptButtonTapped(_ sender: Any) {
     checkChatRooms()
     }*/
    
    func rejectAction(){
        let uid = Auth.auth().currentUser?.uid
        db.child("users").child(uid!).child("pushList").child(self.usermodel!.uid!).removeValue { (err, ref) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func acceptButtonTapped(){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = checkChatRooms
        popupVC.alertTitle = "오늘뭐해"
        popupVC.alertContent = "대화방을 생성하시겠습니까?\n하트는 소모되지 않습니다."
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        popupVC.ver = 1
        self.present(popupVC, animated: true, completion: nil)
    }
    
    @objc func rejectButtonTapped(){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = rejectAction
        popupVC.alertTitle = "오늘뭐해"
        popupVC.alertContent = "거절하시겠습니까?\n거절 시 하트리스트에서 삭제됩니다."
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        popupVC.ver = 1
        self.present(popupVC, animated: true, completion: nil)
    }
    
    //방의 중복을 검사하는 메소드
    //1.이미 방이 있는 경우
    //2.상대방 true 나 false
    //3.상대방 false 나 true
    //4.방이 생성가능한 경우
    //네가지 경우의 예외처리
    
    func checkChatRooms(){
        db.child("chatrooms").queryOrdered(byChild: "users/"+Auth.auth().currentUser!.uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
            let destinationUid:String = self.usermodel!.uid!
            
            for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatRoomdic = item.value as? [String:AnyObject]{
                    let chatmodel = chatModel(JSON: chatRoomdic)
                    if (chatmodel?.users[destinationUid] == true){
                        self.acceptFailReaction(msg: "이미 상대방과의 채팅방이 존재합니다.")
                        return
                        //나와 상대방이 모두 true인 경우
                    }else if(chatmodel?.users[destinationUid] == false){
                        self.acceptFailReaction(msg: "이미 상대방과의 채팅방이 존재합니다.\n 채팅방을 나간후 진행해주세요.")
                        return
                        //나는 true 상대방은 false인경우
                    }
                }
            }
            
            self.db.child("chatrooms").queryOrdered(byChild: "users/"+Auth.auth().currentUser!.uid).queryEqual(toValue: false).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                
                print(dataSnapshot)
                
                for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                    if let chatRoomDic = item.value as? [String:AnyObject]{
                        
                        let ChatModel = chatModel(JSON: chatRoomDic)
                        if (ChatModel?.users[destinationUid] == true){//나는 false 상대방은 true인경우
                            
                            let chatRoomUid = item.key
                            let uid = Auth.auth().currentUser?.uid
                            self.db.child("chatrooms").child(chatRoomUid).child("users").child(uid!).setValue(true, withCompletionBlock: { (err, ref) in
                                self.acceptSuccessReaction()
                            })
                            return
                            //내가 나가있고 상대방은 들어가있는 채팅방이 존재 해당 채팅방에서 내 flase값을 true로 바꿔줌
                        }
                    }
                }
                self.createChatRoom()

            })
        })
    }
    
    func createChatRoom(){
        let uid = Auth.auth().currentUser?.uid
        let createRoomInfo=["users":[
            uid : true,
            self.usermodel!.uid : true
            ]
        ]
        
        let value:Dictionary<String,Any> = [
            "uid" : uid as Any,
            "message" : "[새로운 채팅방]",
            "timestamp" : ServerValue.timestamp()
        ]//메세지 포맷
        self.db.child("chatrooms").childByAutoId().setValue(createRoomInfo,withCompletionBlock:{ (err,ref) in
            if (err == nil){
                ref.child("comments").childByAutoId().setValue(value,withCompletionBlock: {(err,ref) in
                    print("디비에 업뎃")
                })
                self.acceptSuccessReaction()
            }
        })
    }
    
    public func acceptSuccessReaction(){
        let uid = Auth.auth().currentUser?.uid
        self.db.child("users").child(uid!).child("pushList").child(self.usermodel!.uid!).removeValue { (err, ref) in
            ToastViewController.show(message: "대화방이 생성되었습니다.", controller: self)
            self.sendFCM(pushText: "\((Auth.auth().currentUser?.displayName)!)님이 응답에 수락하였습니다.", kind: "r")
            //self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    public func acceptFailReaction(msg:String){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "simpleAlertViewController") as! simpleAlertViewController
        popupVC.alertTitle = "수락불가"
        popupVC.alertContent = "이미 상대방과의 대화방이 존재합니다."
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
    }
    
    public func sendFCM(pushText:String?, kind:String){
        let url = "https://fcm.googleapis.com/fcm/send"
        let header:HTTPHeaders = [
            "Content-Type":"application/json",
            "Authorization":"key = AAAAj2R4qNg:APA91bH2ZoT0hU5yDFYF24aea9CIw7m7gGHjb08PIHxgcIyLQfDhS_hDVG6tO8ld3yRR3Wabr4pawOiDSFGWC1wxoMmutG-gsXjIO4crrn7HDie0t2MaGBftNJQhSk4PY9y2rZwpBqVq"
            //클라우드 메세지 이전서버키
        ]
        //서버키  AAAAj2R4qNg:APA91bH2ZoT0hU5yDFYF24aea9CIw7m7gGHjb08PIHxgcIyLQfDhS_hDVG6tO8ld3yRR3Wabr4pawOiDSFGWC1wxoMmutG-gsXjIO4crrn7HDie0t2MaGBftNJQhSk4PY9y2rZwpBqVq
        //이전서버키
        //AIzaSyAaBpH1frYBjY_1-3nt-BJPsymVv6grpdg

        let userName = Auth.auth().currentUser?.displayName
        let notificationmodel = notificationModel()
        notificationmodel.to = usermodel?.pushtoken
        var title:String?
        
        if(kind == "p"){
            title = "대화요청"
        }else if(kind == "r"){
            title = "축하합니다!!"
        }else if(kind == "m"){
            title = Auth.auth().currentUser?.displayName
        }
        
        if(usermodel?.platform == "android"){
            notificationmodel.data.title = title
            //푸시를 받은 상대방이 보낸 사람의 정보를 보기위해 uid를 같이 보냄.
            notificationmodel.data.text = pushText
            /*if(usermodel!.photo.count >= 1){
                if(usermodel!.photo[imageIndex.first!]!.image != nil){
                    notificationmodel.data.click_action =  kind+"\(usermodel!.photo[imageIndex.first!]!.image!)"
                }
            }*/
            //사진이 한장이상이면 푸시에 사진을 실어서 보냄
            notificationmodel.data.click_action =  kind+""
            let params = notificationmodel.toJSON()
            
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON{(response) in
                print((response.result.value)!)
            }
        }else if(usermodel?.platform == "ios"){
            var pushKind:String?
            
            if kind == "p"{
                pushKind = "flagPropose"
            }else if kind == "r"{
                pushKind = "flagRecive"
            }
            self.db.child("users").child(self.usermodel!.uid!).child(pushKind!).observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
                let flag = DataSnapshot.value as! Int
                
                if flag == 0{
                    notificationmodel.notification.title = title
                    notificationmodel.notification.text = pushText
                    notificationmodel.notification.sound = "default"
                    //notificationmodel.notification.badge = 0
                    notificationmodel.notification.content_available = "true"
                    notificationmodel.notification.click_action = kind
                    notificationmodel.data.title = Auth.auth().currentUser?.displayName
                    notificationmodel.data.text = pushText
                    notificationmodel.data.click_action = kind
                    
                    let params = notificationmodel.toJSON()
                    
                    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON{(response) in
                        print((response.result.value)!)
                    }
                }else{
                    return
                }
            })
        }else{
            return
        }
    }
}

extension userInfoViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if usermodel == nil{
            return 0
        }
        
        if usermodel?.photo.count == 0 {
            if prevPage != 3{
                label_imageMent.text = "사진심사가 완료되지 않은 사용자입니다."
                label_imageMent.isHidden = false
            }
        }
        return (usermodel?.photo.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = infoCollectionView.dequeueReusableCell(withReuseIdentifier: "userInfoCell", for: indexPath) as! userInfoCell
        
        if imageIndex == []{
            return cell
        }
        
        cell.userFaceView.layer.cornerRadius = 10.0
        cell.userFaceView.layer.masksToBounds = true
        
        print(imageIndex)
        
        cell.label_imageComment.isHidden = true
        
        let url:URL?
        
        if (usermodel?.photo.count)!-1 >= indexPath.row{
            if(usermodel?.photo[imageIndex[indexPath.row]]?.image != nil){
                url = URL(string: (usermodel?.photo[imageIndex[indexPath.row]]?.image)!)
                cell.userFaceView.kf.setImage(with: url)
            }else{
                if prevPage == 3{
                    url = URL(string: (usermodel?.photo[imageIndex[indexPath.row]]?.temp)!)
                    cell.userFaceView.kf.setImage(with: url)
                    cell.label_imageComment.text = "해당 사진은 관리자 심사 후 적용됩니다."
                    cell.label_imageComment.isHidden = false
                }else{
                    //cell.label_imageComment.text = "사진심사가 완료되지 않은 사용자입니다."
                    //cell.label_imageComment.isHidden = false
                    label_imageMent.text = "사진심사가 완료되지 않은 사용자입니다."
                    label_imageMent.isHidden = false
                }
            }
        }else{
            cell.userFaceView.image = nil
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = infoCollectionView.frame.width
        let screenHeight = infoCollectionView.frame.height
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = infoCollectionView.cellForItem(at: indexPath) as? userInfoCell else {return}
        
        if(cell.userFaceView.image != nil){
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let zoomViewController = storyBoard.instantiateViewController(withIdentifier: "zoomViewController") as! zoomViewController
            zoomViewController.userImage = cell.userFaceView.image

            zoomViewController.modalPresentationStyle = .overCurrentContext
            zoomViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(zoomViewController, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
        let index = scrollView.contentOffset.x / witdh
        let roundedIndex = round(index)
        self.pageControl?.currentPage = Int(roundedIndex)
    }
}

class userInfoCell:UICollectionViewCell{
    @IBOutlet weak var userFaceView: UIImageView!
    
    @IBOutlet weak var label_imageComment: UILabel!
}
