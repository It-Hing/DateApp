//
//  tabBarController.swift
//  drink
//
//  Created by user on 02/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftKeychainWrapper
import FirebaseStorage

class tabBarController:UIViewController{
    
    @IBOutlet weak var tabBarCollectionView: UICollectionView!
    @IBOutlet weak var mapCV: UIView!
    @IBOutlet weak var chatCV: UIView!
    @IBOutlet weak var listCV: UIView!
    
    //
    @IBOutlet weak var slideBarView: UIView!
    @IBOutlet weak var slideConstraint: NSLayoutConstraint!
    @IBOutlet weak var slideBarWidth: NSLayoutConstraint!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var slideBarTableView: UITableView!
    
    @IBOutlet weak var label_heartNum: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!
    
    @IBOutlet weak var label_couponNum: UILabel!
    //
    
    var usermodel:userModel? = nil
    let db = Database.database().reference()
    var databaseRef:DatabaseReference?
    
    var indicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        //let indicatorColor = UIColor(red: 132.0/255, green: 140.0/255, blue: 250.0/255, alpha: 1.0)
        view.backgroundColor = .white
        return view
    }()
    
    var indicatorViewLeadingConstraint:NSLayoutConstraint! // ---- *
    //indicatorView가 이동하기위해 필요
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ////////////내디비를 보고 있다가 사라지면 탈퇴 액션 해주기(동시로그인상태에서 한명이 탈퇴한 경우)
        let uid = Auth.auth().currentUser?.uid
        databaseRef = self.db.child("users").child(uid!)
        let observe = databaseRef!.observe(DataEventType.value, with: {(datasnapshot) in
            //받아온 디비가 없는경우 -> 계정이 다른 디바이스에서 삭제된 경우
            if !datasnapshot.exists(){
                print("디비가 지워짐")
                //1.로그아웃
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                //2.키체인에서 이메일 비밀번호 삭제
                KeychainWrapper.standard.removeObject(forKey: "email")
                KeychainWrapper.standard.removeObject(forKey: "pwd")
                KeychainWrapper.standard.removeObject(forKey: "loginCheck")
                //3.observe참조 삭제
                self.databaseRef!.removeAllObservers()
                //4.첫페이지로 이동
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let loginPage = storyBoard.instantiateViewController(withIdentifier: "firstPageController") as! firstPageController
                loginPage.modalPresentationStyle = .overCurrentContext
                loginPage.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                self.present(loginPage, animated: true, completion: nil)
            }else{
                //내성별을 로컬디비에 저장해놓음
                let mySex = String(describing: datasnapshot.value!)
                UserDefaults.standard.set(mySex, forKey: "mySex")
                UserDefaults.standard.synchronize()
            }
        })
        /////////////쿠폰지급
        self.db.child("users").child(uid!).child("freeDate").observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy.MM.dd"
            let date = Date()
            let time = dateFormatter.string(from: date)
            
            if(!datasnapshot.exists()){
                self.db.child("users").child(uid!).updateChildValues([
                    "freeCoupon": "1",
                    "freeDate": time
                    ])
            }else{
                let freedate = String(describing: datasnapshot.value!)
                if(freedate != time){
                    self.db.child("users").child(uid!).updateChildValues([
                        "freeCoupon": "1",
                        "freeDate": time
                        ])
                }
            }
        })
        ///////////////
        let startPage = UserDefaults.standard.value(forKey: "startPage")  as! String

        slideBarWidth.constant = (view.frame.width/3)*2
        slideConstraint.constant = -slideBarWidth.constant
        //초기화면에 메뉴바가 들어가 있도록 설정
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //navigationController?.navigationBar.isTranslucent = false

        tabBarCollectionView.delegate = self
        tabBarCollectionView.dataSource = self
        
        slideBarTableView.delegate = self
        slideBarTableView.dataSource = self
        
        view.addSubview(indicatorView)
        indicatorView.widthAnchor.constraint(equalToConstant: self.view.frame.width/3-40).isActive = true // ---- *
        indicatorView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        indicatorViewLeadingConstraint = indicatorView.leadingAnchor.constraint(equalTo: tabBarCollectionView.leadingAnchor)
        indicatorViewLeadingConstraint.isActive = true
        indicatorViewLeadingConstraint.constant = (self.view.frame.width / 3) * CGFloat(Double(startPage)!-1)+20
        //indicatorViewLeadingConstraint.constant += 20
        indicatorView.bottomAnchor.constraint(equalTo: tabBarCollectionView.bottomAnchor).isActive = true
       
        self.view.bringSubviewToFront(self.slideBarView)
        
        if (startPage == "3"){
            mapCV.isHidden = true
            chatCV.isHidden = true
            listCV.isHidden = false
        }else if(startPage == "2"){
            mapCV.isHidden = true
            chatCV.isHidden = false
            listCV.isHidden = true
        }else{
            mapCV.isHidden = false
            chatCV.isHidden = true
            listCV.isHidden = true
        }
        
        UserDefaults.standard.addObserver(self, forKeyPath: "startPage", options: .new, context: nil)
        
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSlideBar))
        backgroundView.addGestureRecognizer(tap)

        slideBarTableView.reloadData()
    }
    
    @objc func dismissSlideBar(){
        slideConstraint.constant = -slideBarWidth.constant
        self.view.sendSubviewToBack(self.backgroundView)
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "startPage" {
            if (UserDefaults.standard.value(forKey: "startPage") != nil){
                let startPage = UserDefaults.standard.value(forKey: "startPage")  as! String
                
                if (startPage == "3"){
                    mapCV.isHidden = true
                    chatCV.isHidden = true
                    listCV.isHidden = false
                }else if(startPage == "2"){
                    mapCV.isHidden = true
                    chatCV.isHidden = false
                    listCV.isHidden = true
                }else{
                    mapCV.isHidden = false
                    chatCV.isHidden = true
                    listCV.isHidden = true
                }
                
                indicatorViewLeadingConstraint.constant = (self.view.frame.width / 3) * CGFloat(Double(startPage)!-1)+20
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "startPage")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.backgroundColor = .clear
        //navigationController?.navigationBar.setBottomBorderColor(color: .clear, height: 0)
        navigationController?.navigationBar.removeBorderColor()
        
        //네비게이션바 오른쪽 버튼
        let rightbarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        NSLayoutConstraint.activate([(rightbarButton.widthAnchor.constraint(equalToConstant: 30)),(rightbarButton.heightAnchor.constraint(equalToConstant: 30))])
        rightbarButton.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
        rightbarButton.setImage(UIImage(named: "house"), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:rightbarButton)
        
        //네비게이션바 왼쪽 버튼
        let leftbarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        NSLayoutConstraint.activate([(leftbarButton.widthAnchor.constraint(equalToConstant: 30)),(leftbarButton.heightAnchor.constraint(equalToConstant: 30))])
        leftbarButton.addTarget(self, action: #selector(leftBarButtonTapped), for: .touchUpInside)
        leftbarButton.setImage(UIImage(named: "list"), for: .normal)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:leftbarButton)
        
        /*self.navigationItem.title = "오늘"
        let titleLabel = UILabel()
        titleLabel.text = "오늘"
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.sizeToFit()  // Important part
        navigationItem.titleView = titleLabel*/
        self.navigationItem.title = "오늘뭐해"
        
        if #available(iOS 13, *)
        {
              let app = UIApplication.shared
              let statusBarHeight: CGFloat = app.statusBarFrame.size.height
              
              let statusbarView = UIView()
            statusbarView.backgroundColor =  .clear

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
                statusBar!.backgroundColor = .clear
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }
        

        //self.navigationController?.isNavigationBarHidden = false
        //self.navigationItem.titleView
    }

    override func viewDidLayoutSubviews() {
        heartImageView.image = heartImageView.image?.maskWithColor(color: .red)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func rightBarButtonTapped(){
        /*let storeViewController = self.storyboard?.instantiateViewController(withIdentifier: "storeViewController") as! storeViewController
        self.navigationController?.pushViewController(storeViewController, animated: true)*/
        let storeViewController = storyboard?.instantiateViewController(withIdentifier: "storeViewController") as! storeViewController
        //self.navigationController?.pushViewController(privacyViewController, animated: true)
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.modalPresentationStyle = .currentContext
        storeViewController.modalPresentationStyle = .overCurrentContext
        storeViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(storeViewController, animated: true, completion: nil)
    }
    
    @objc func leftBarButtonTapped(){
        if slideConstraint.constant == 0{
            slideConstraint.constant = -slideBarWidth.constant
            self.view.sendSubviewToBack(self.backgroundView)
        }else{
            slideConstraint.constant = 0
            self.view.bringSubviewToFront(self.backgroundView)
            self.view.bringSubviewToFront(self.slideBarView)
            let uid = Auth.auth().currentUser?.uid
            self.db.child("users").child(uid!).child("heart").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
                let heart = String(describing: datasnapshot.value!)
                self.label_heartNum.text = heart
            })
            self.db.child("users").child(uid!).child("freeCoupon").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
                let coupon = String(describing: datasnapshot.value!)
                self.label_couponNum.text = coupon
            })
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    /*@IBAction func profileButtonTapped(_ sender: Any) {
        if slideConstraint.constant == 0{
            slideConstraint.constant = -slideBarWidth.constant
            self.view.sendSubviewToBack(self.backgroundView)
        }else{
            slideConstraint.constant = 0
            self.view.bringSubviewToFront(self.backgroundView)
            self.view.bringSubviewToFront(self.slideBarView)
            let uid = Auth.auth().currentUser?.uid
            self.db.child("users").child(uid!).child("heart").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
                let heart = String(describing: datasnapshot.value!)
                self.label_heartNum.text = heart
            })
        }
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        /*if usermodel == nil{
            return
        }*/
        
        /*let myProfileController = storyboard?.instantiateViewController(withIdentifier: "myProfileController") as! myProfileController
        //myProfileController.usermodel = usermodel
        self.navigationController?.pushViewController(myProfileController, animated: true)*/
        
        /*let myInfoView = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
        myInfoView.prevPage = 3
        
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.modalPresentationStyle = .currentContext
        myInfoView.modalPresentationStyle = .overCurrentContext
        myInfoView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        //self.present(self.navigationController!, animated: true, completion: nil)
        
        self.present(myInfoView, animated: true, completion: nil)
        //self.navigationController?.pushViewController(myInfoView, animated: true)*/
        
    }*/
    
    func showBlockList(){
        let blockListController = storyboard?.instantiateViewController(withIdentifier: "blockListController") as! blockListController
        self.navigationController?.pushViewController(blockListController, animated: true)
    }
    
    func showPrivacy(){
        let privacyViewController = storyboard?.instantiateViewController(withIdentifier: "privacyViewController") as! privacyViewController
        //self.navigationController?.pushViewController(privacyViewController, animated: true)
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.modalPresentationStyle = .currentContext
        privacyViewController.modalPresentationStyle = .overCurrentContext
        privacyViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(privacyViewController, animated: true, completion: nil)
    }
    
    //이용약관 보여주기
    func showTOS(){
        let tosViewController = storyboard?.instantiateViewController(withIdentifier: "tosViewController")
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.modalPresentationStyle = .currentContext
        tosViewController!.modalPresentationStyle = .overCurrentContext
        tosViewController!.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(tosViewController!, animated: true, completion: nil)
    }
    
    func showTempLogin(){
        let uid = Auth.auth().currentUser?.uid
        //디비에 로그인체크 필드에 false(로그아웃)을 저장해준다.
        /*self.db.child("users").child(uid!).child("loginCheck").setValue(false) { (err, ref) in
            if err != nil{
                print(err)
            }else{
                let tempLoginController = self.storyboard?.instantiateViewController(withIdentifier: "tempLoginController") as! tempLoginController
                //tempLoginController.loginEmail = Auth.auth().currentUser?.email
                self.db.child("users").child(uid!).child("location").removeValue { (err, ref) in
                    UserDefaults.standard.set(false, forKey: "loginCheck")
                    tempLoginController.isInitialView = false
                    self.navigationController?.pushViewController(tempLoginController, animated: true)
                    //로그아웃을 하면 디비에서 나의 위치 삭제후 화면전환
                }
            }
        }*/
        
        //databaseRef = self.db.child("users").child(uid!)
        
        if databaseRef != nil{
            databaseRef?.removeAllObservers()
        }
        
        let tempLoginController = self.storyboard?.instantiateViewController(withIdentifier: "tempLoginController") as! tempLoginController
        db.child("users").child(uid!).child("sex").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
            let sex = String(describing: datasnapshot.value!)
            
            if (sex == "남자"){
                self.db.child("man_location").child(uid!).removeValue { (err, ref) in
                    KeychainWrapper.standard.set(false, forKey: "loginCheck")
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                    
                    self.db.child("users").child(uid!).child("pushToken").removeValue()
                    
                    self.navigationController?.pushViewController(tempLoginController, animated: true)
                    //로그아웃을 하면 디비에서 나의 위치 삭제후 화면전환
                }
            }else if(sex == "여자"){
                self.db.child("woman_location").child(uid!).removeValue { (err, ref) in
                    KeychainWrapper.standard.set(false, forKey: "loginCheck")
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                    
                    self.db.child("users").child(uid!).child("pushToken").removeValue()
                    
                    self.navigationController?.pushViewController(tempLoginController, animated: true)
                    //로그아웃을 하면 디비에서 나의 위치 삭제후 화면전환
                }
            }
        })
        /*self.db.child("users").child(uid!).child("location").removeValue { (err, ref) in
            KeychainWrapper.standard.set(false, forKey: "loginCheck")
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            
            self.navigationController?.pushViewController(tempLoginController, animated: true)
            //로그아웃을 하면 디비에서 나의 위치 삭제후 화면전환
        }*/
    }
    
    func blockSignUp(){
        
        //Dataabaseref가 동일한 행동을 하기때문에 옵저버를 지워주고 해야함.
        if databaseRef != nil{
            databaseRef?.removeAllObservers()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = Date()
        let keychainValue = dateFormatter.string(from: date)
        let save = KeychainWrapper.standard.set(keychainValue, forKey: "blockSignUp")
        let uid = Auth.auth().currentUser?.uid
        db.child("users").child(uid!).observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
            let data = datasnapshot.value as! [String:AnyObject]
            self.usermodel = userModel(JSON: data)
            //let sex:String = datasnapshot.value as! String
            let path:String?
            if (self.usermodel!.sex == "남자"){
                path = "man_location"
            }else{
                path = "woman_location"
            }
            self.db.child(path!).child(uid!).removeValue(completionBlock: { (err, ref) in
                if err != nil{
                    return
                }else{
                    ////////////////////////////////////////하트리스트 지워주기
                    
                    ////////////////////////////////////////차단 멤버 지워주기
                    for blockman in (self.usermodel?.blockList.keys)!{
                        self.db.child("users").child(blockman).child("blockedList").child(uid!).removeValue()
                    }
                    for blockedman in (self.usermodel?.blockedList.keys)!{
                        self.db.child("users").child(blockedman).child("blockList").child(uid!).removeValue()
                    }
                    ////////////////////////////////////////관리자페이지에서 사진심사삭제
                    self.db.child("administer").child("users").child(uid!).removeValue()
                    ////////////////////////////////////////Buys데이터 지워주기
                    self.db.child("Buys").child(uid!).removeValue()
                    ////////////////////////////////////////디바이스인포 지워주기
                    let email = Auth.auth().currentUser?.email

                    self.db.child("deviceinfo").queryOrdered(byChild: "/email").queryEqual(toValue: email).observeSingleEvent(of: DataEventType.value,with: {(DataSnapshot) in
                        if DataSnapshot.exists(){
                            let data = DataSnapshot.value as! [String:AnyObject]
                            
                            for item in data{
                                print(item.key)
                                self.db.child("deviceinfo").child(item.key).removeValue()
                            }
                        }
                    })
                    /////////////////////////////////////////
                    self.db.child("users").child(uid!).removeValue(completionBlock: { (Err, ref) in
                        if Err != nil{
                            return
                        }else{
                            self.db.child("chatrooms").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                                for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                                    self.db.child("chatrooms").child(item.key).removeValue(completionBlock: { (err, ref) in
                                        print("채팅방삭제완료")
                                    })
                                }
                                //탈퇴하면 채팅방 모두 삭제
                                
                                /*for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                                    if let chatRoomdic = item.value as? [String:AnyObject]{
                                        let chatmodel = chatModel(JSON: chatRoomdic)
                                        chatmodel?.roomid = item.key
                                        let uids:[String] = (chatmodel?.users.keys.sorted())!
                                        var destinationUid:String?
                                        for data in uids{
                                            if data != uid{
                                                destinationUid = data
                                            }
                                        }
                                        if(chatmodel?.users[destinationUid!] == false){
                                            //상대방이 채팅방을 나가있는 경우 채팅방을 삭제함
                                        self.db.child("chatRooms").child(chatmodel!.roomid!).removeValue()
                                            print("채팅방 삭제")
                                        }else{
                                            //상대방이 존재하는 채팅방은 나를 false로 만들어줌
                                            self.db.child("chatRooms").child(chatmodel!.roomid!).child("users").child(uid!).setValue(false, withCompletionBlock: { (err, ref) in
                                            })
                                            print("채팅방 삭제는 안하고 나를 false로 바꿈")
                                        }
                                        //roomid 삭제 (완료)// 및 사진 삭제 및 푸시리스트 처리 필요
                                    }
                                }*/
                                
                                let storageRef = Storage.storage().reference().child("userImages").child(uid!)
                                for photoPath in self.usermodel!.photo.values{
                                    if (photoPath.imageHashCode != nil){
                                        storageRef.child(photoPath.imageHashCode!).delete(completion: { (err) in})
                                    }
                                    if (photoPath.tempHashCode != nil){
                                        storageRef.child(photoPath.tempHashCode!).delete(completion: { (err) in})
                                    }
                                }
                                
                                //계정 삭제 후 로그아웃하고 첫페이지로 넘어감
                                Auth.auth().currentUser?.delete(completion: { (err) in
                                    if err != nil{
                                        print(err as Any)
                                    }else{
                                        
                                        let firebaseAuth = Auth.auth()
                                        do {
                                            try firebaseAuth.signOut()
                                        } catch let signOutError as NSError {
                                            print ("Error signing out: %@", signOutError)
                                        }
                                        //키체인에서 이메일 비밀번호 삭제
                                        KeychainWrapper.standard.removeObject(forKey: "email")
                                        KeychainWrapper.standard.removeObject(forKey: "pwd")
                                        KeychainWrapper.standard.removeObject(forKey: "loginCheck")

                                        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                                        let loginPage = storyBoard.instantiateViewController(withIdentifier: "firstPageController") as! firstPageController
                                        loginPage.modalPresentationStyle = .overCurrentContext
                                        loginPage.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                        self.present(loginPage, animated: true, completion: nil)
                                    }
                                })
                            })
                        }
                    })
                }
            })
        })
    }
    
    func showPushSetting(){
        let pushSetting = storyboard?.instantiateViewController(withIdentifier: "notiSettingViewController") as! notiSettingViewController
        navigationController?.pushViewController(pushSetting, animated: true)
    }
    
    
    /*func reauthenticateUserWith(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("재인증성공")
            }else {
                //handle error
                print("재인증에 실패하였습니다.")
            }
        }
    }*/
    
}

extension tabBarController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //print(UserDefaults.standard.value(forKey: "startPage"))
        let startPage = UserDefaults.standard.value(forKey: "startPage") as! String

        if (indexPath.row == 0){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabBarCell", for: indexPath) as! tabBarCell
            cell.label_Title.text = "지도"
            //cell.label_Title.font = .boldSystemFont(ofSize: 18)
            
            if (UserDefaults.standard.value(forKey: "startPage") != nil){
                if (startPage != "3" && startPage != "2"){
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])//생성할때 첫번째 인자가 기본선택됨
                     cell.label_Title.font = .systemFont(ofSize: 18, weight: UIFont.Weight.regular)
                }
            }else{
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])//생성할때 첫번째 인자가 기본선택됨
            }
            return cell
        }else if(indexPath.row == 1){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabBarCell", for: indexPath) as! tabBarCell
            cell.label_Title.text = "채팅리스트"
            if (UserDefaults.standard.value(forKey: "startPage") != nil){
                if (startPage != "3" && startPage != "1"){
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])//생성할때 첫번째 인자가 기본선택됨
                     cell.label_Title.font = .systemFont(ofSize: 18, weight: UIFont.Weight.regular)
                }
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tabBarCell", for: indexPath) as! tabBarCell
            cell.label_Title.text = "하트리스트"
            if (UserDefaults.standard.value(forKey: "startPage") != nil){
                if (startPage != "2" && startPage != "1"){
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])//생성할때 첫번째 인자가 기본선택됨
                     cell.label_Title.font = .systemFont(ofSize: 18, weight: UIFont.Weight.regular)
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width/3
        let screenHeight = collectionView.frame.height
        return CGSize(width: screenWidth, height: screenHeight)
     }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //print(UserDefaults.standard.value(forKey: "startPage") as! String)
        //let startPage = UserDefaults.standard.value(forKey: "startPage") as! String
        //self.db.child("notepad").setValue(startPage)
        
        indicatorViewLeadingConstraint.constant = (self.view.frame.width / 3) * CGFloat((indexPath.row))+20
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? tabBarCell else {return}
        //cell.label_Title.font = .boldSystemFont(ofSize: 18)
        cell.label_Title.font = .systemFont(ofSize: 18, weight: UIFont.Weight.regular)
        
        if(indexPath.row == 0){
            mapCV.isHidden = false
            chatCV.isHidden = true
            listCV.isHidden = true
        }else if(indexPath.row == 1){
            mapCV.isHidden = true
            chatCV.isHidden = false
            listCV.isHidden = true
        }else if(indexPath.row == 2){
            mapCV.isHidden = true
            chatCV.isHidden = true
            listCV.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? tabBarCell else {return}
        //cell.label_Title.font = .boldSystemFont(ofSize: 15)
        cell.label_Title.font = .systemFont(ofSize: 15, weight: UIFont.Weight.ultraLight)
    }
}

extension tabBarController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = slideBarTableView.dequeueReusableCell(withIdentifier: "menuBarCell", for: indexPath) as! menuBarCell
        switch indexPath.row {
        case 0:
            cell.label_Title!.text = "프로필 설정"
            cell.menuImageView.image = UIImage(named: "baseline_perm_identity_black_24pt")
            break
        case 1:
            cell.label_Title!.text = "알람설정"
            cell.menuImageView.image = UIImage(named:"baseline_add_alert_black_24pt")
            break
        case 2:
            cell.label_Title!.text = "지도설정"
            cell.menuImageView.image = UIImage(named: "baseline_map_black_24pt")
            break
        case 3:
            cell.label_Title!.text = "차단목록"
            cell.menuImageView.image = UIImage(named:"baseline_not_interested_black_24pt")
            break
        case 4:
            cell.label_Title!.text = "공지사항/FAQ"
            cell.menuImageView.image = UIImage(named: "baseline_policy_black_24pt")
            break
        case 5:
            cell.label_Title!.text = "이용약관"
            cell.menuImageView.image = UIImage(named: "baseline_note_black_24pt")
            break
        case 6:
            cell.label_Title!.text = "개인정보 취급방침"
            cell.menuImageView.image = UIImage(named: "baseline_note_black_24pt")
            break
        case 7:
            cell.label_Title!.text = "로그아웃"
            cell.menuImageView.image = UIImage(named: "baseline_home_black_24pt")
            break
        case 8:
            cell.label_Title!.text = "계정탈퇴"
            cell.menuImageView.image = UIImage(named: "baseline_add_alert_black_24pt")
            break
        default:
            break
        }
        //cell.textLabel!.text = "차단목록"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let myInfoView = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
            myInfoView.prevPage = 3
            
            self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.navigationController?.modalPresentationStyle = .currentContext
            myInfoView.modalPresentationStyle = .overCurrentContext
            myInfoView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(myInfoView, animated: true, completion: nil)
            break
        case 1:
            showPushSetting()
            break
        case 2:
            let mapSettingView = storyboard?.instantiateViewController(withIdentifier: "mapSettingViewController") as! mapSettingViewController
            navigationController?.pushViewController(mapSettingView, animated: true)
            break
        case 3:
            showBlockList()
            break
        case 4:
            let noticeView = storyboard?.instantiateViewController(withIdentifier: "noticeViewController") as! noticeViewController
            navigationController?.pushViewController(noticeView, animated: true)
            break
        case 5:
            showTOS()
            break
        case 6:
            showPrivacy()
            break
        case 7:
            /*let msg = "로그아웃 하시겠습니까?"
             let alert = UIAlertController(title: "로그아웃", message: msg, preferredStyle: .alert)
             
             let cancelAction = UIAlertAction(title: "취소", style: .cancel){
             (action : UIAlertAction) -> Void in
             //self.dismiss(animated: true)
             }
             
             let okayAction = UIAlertAction(title: "확인", style: .default){
             (action : UIAlertAction) -> Void in
             //확인 클릭 했을때 처리할 내용
             self.showTempLogin()
             }
             alert.addAction(cancelAction)
             alert.addAction(okayAction)
             self.present(alert, animated: true, completion: nil)*/
            
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
            popupVC.okAction = showTempLogin
            popupVC.alertTitle = "로그아웃"
            popupVC.alertContent = "로그아웃하시겠습니까?"
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(popupVC, animated: true, completion: nil)
            break
        case 8:
            let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
            let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
            popupVC.okAction = gotoBlockSignUp
            popupVC.alertTitle = "계정탈퇴"
            popupVC.alertContent = "30일동안 이용하실 수 없습니다.\n정말로 계정탈퇴를 하시겠습니까?"
            popupVC.modalPresentationStyle = .overCurrentContext
            popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(popupVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    func gotoBlockSignUp(){
        dismiss(animated: true, completion: nil)
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "pwdConfirmViewController") as! pwdConfirmViewController
        popupVC.okAction = blockSignUp
        //popupVC.label_alertTitle.text = "회원탈퇴 비밀번호 확인"
        //popupVC.label_alertContent.text = "회원탈퇴를 하면 30일간 회원가입을 할 수 없습니다."
        popupVC.alertTitle = "비밀번호 재확인"
        popupVC.alertContent = "비밀번호 입력"
        popupVC.loginState = true
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
    }
    
}

class menuBarCell:UITableViewCell{
    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var label_Title: UILabel!
}


class tabBarCell:UICollectionViewCell{
    @IBOutlet weak var label_Title: UILabel!
}

//네비게이션바 바닥 선 그리기위함
extension UINavigationBar {
    func setBottomBorderColor(color: UIColor, height: CGFloat) {
        let bottomBorderRect = CGRect(x: 0, y: frame.height, width: frame.width, height: height)
        let bottomBorderView = UIView(frame: bottomBorderRect)
        bottomBorderView.backgroundColor = color
        addSubview(bottomBorderView)
    }
    
    func removeBorderColor(){
        for subview in self.subviews{
            subview.removeFromSuperview()
        }
    }
}
