//
//  chatViewController.swift
//  drink
//
//  Created by user on 07/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import CoreImage

class chatViewController:UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
        
    @IBOutlet weak var alert_userCheck: UILabel!
    @IBOutlet weak var messageField: UITextField!
    
    let db = Database.database().reference()
    @IBOutlet weak var sendButton: UIButton!
    public var destinationUid:String? //= "IU8EwHpUKXNxtLfy9C6ugbl6Mii1"//임시입력계정
    var chatRoomUid:String?//채팅방 이름을 받아옴
    var pushToken:String?
    @IBOutlet weak var chatTableView: UITableView!
    
    var destinationImage:UIImage?
    var destinationName:String?
    var destinationPlatform:String?
    //@IBOutlet weak var bottomContraint: NSLayoutConstraint!
    //@IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    var comments:[chatModel.Comment] = []//comment를 담는 comment class 형식의 리스트
    //var UserModel:userModel?
    let myName:String = (Auth.auth().currentUser?.displayName)!
    
    var databaseRef:DatabaseReference?
    var databaseRef_user:DatabaseReference?
    var observe:UInt?//채팅방에서 나갔을 때 더이상 디비를 참조하지 않기 위한 변수
    var observe_user:UInt?//상대방이 나가는지 확인하는 옵저버
    var userCheck = true
    var imageIndex:[String]? = []
    var pushText:String?
    //푸시를 보낼때 텍스창을 미리지워버리기 때문에 저장해놓는게 필요하다.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("viewdidload")
        /*if (pushToken == nil){
            db.child("chatRooms").child("users").child(destinationUid!).setValue(Any?)
        }*/
        
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
        
        alert_userCheck.isHidden = true
        alert_userCheck.layer.cornerRadius = alert_userCheck.frame.height/2
        alert_userCheck.layer.masksToBounds = true
        
        chatTableView.delegate = self
        chatTableView.dataSource = self //테이블뷰 관련 델리게이트 맡기
        chatTableView.separatorStyle = .none
        
        //sendButton.layer.cornerRadius = sendButton.frame.width/10
        /*let buttonColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0).cgColor
        sendButton.layer.borderColor = buttonColor
        sendButton.layer.borderWidth = 1.0
        sendButton.layer.masksToBounds = true*/
        
        messageField.layer.borderWidth = 0
        messageField.layer.borderColor = UIColor.white.cgColor
        
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRooms()
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        addRightBarButtonItem()
        
        self.chatTableView.estimatedRowHeight = 140
        self.chatTableView.rowHeight = UITableView.automaticDimension
        sendButton.layer.cornerRadius = sendButton.frame.height/3
        sendButton.layer.masksToBounds = true
        
        //print("myName :\(myName)")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    
    
    @IBAction func addImageTapped(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                    
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func showUserInfo(){
        let userInfoViewController = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
        userInfoViewController.navigationItem.title = destinationName
        userInfoViewController.destinationUid = destinationUid
        userInfoViewController.prevPage = 4
        userInfoViewController.modalPresentationStyle = .overCurrentContext
        userInfoViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(userInfoViewController, animated: true, completion: nil)
    }
    
    public func addRightBarButtonItem(){
        let rightButton: UIBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(exitTapped))
        rightButton.image = UIImage(named: "baseline_exit_to_app_black_24pt")
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    
    @objc func exitTapped(){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = exitAction
        popupVC.alertTitle = "채팅방 나가기"
        popupVC.alertContent = "채팅방을 나가시겠습니까?"
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
        /*let msg = "채팅방을 나가면 대화기록이 모두 삭제됩니다."
        let alert = UIAlertController(title: "나가기", message: msg, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel){
            (action : UIAlertAction) -> Void in
            //self.dismiss(animated: true)
        }
        
        let okayAction = UIAlertAction(title: "나가기", style: .default){
            (action : UIAlertAction) -> Void in
            //확인 했을때 처리할 내용
            let uid = Auth.auth().currentUser?.uid
            self.db.child("chatRooms").child(self.chatRoomUid!).child("users").child(uid!).setValue(false, withCompletionBlock: { (err, ref) in
                self.navigationController?.popViewController(animated: true)
            })
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)*/
    }
    
    func exitAction(){
        let uid = Auth.auth().currentUser?.uid
        self.db.child("chatrooms").child(self.chatRoomUid!).child("users").child(uid!).setValue(false, withCompletionBlock: { (err, ref) in
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    //send버튼 클릭할때 마다 함수호출
    @objc func createRoom(){
        //print("createRoom")
        let createRoomInfo=["users":[
                Auth.auth().currentUser?.uid : true,
                destinationUid : true
            ]
        ]
        if chatRoomUid == nil//방생성이 되어있지 않으면
        {
            self.sendButton.isEnabled = false
            db.child("chatrooms").childByAutoId().setValue(createRoomInfo,withCompletionBlock:{ (err,ref) in
                if (err == nil){
                    self.checkChatRooms()
                }
            })
        }else//이미 생성된 방이 있으면
        {

            if messageField.text != ""{

                let value:Dictionary<String,Any> = [
                    "uid" : Auth.auth().currentUser?.uid as Any,
                    "message" : messageField.text!,
                    "timestamp" : ServerValue.timestamp()
                ]//메세지 포맷
                ///setValue
                db.child("chatrooms").child(chatRoomUid!).child("comments").childByAutoId().setValue(value,withCompletionBlock: {(err,ref) in
                    //print("디비에 업뎃")
                    self.pushText = self.messageField.text
                    self.sendFCM()
                    self.messageField.text = ""//메세지 입력이 끝났을 때 텍스트창 비워주기
                })
            }
        }
    }
    
    func checkChatRooms(){
        /*db.child("chatRooms").queryOrdered(byChild: "users/"+Auth.auth().currentUser!.uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
            print("checkChatRooms")

            for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatRoomdic = item.value as? [String:AnyObject]{
                    let chatmodel = chatModel(JSON: chatRoomdic)
                    if (chatmodel?.users[self.destinationUid!] == true){
                        self.chatRoomUid = item.key
                        self.sendButton.isEnabled = true
                        //self.getMessageList()//채팅방 중복검사할때마다 메세지 리스트를 받아옴
                        self.getDestinationInfo()
                    }else if(chatmodel?.users[self.destinationUid!] == false){
                        self.chatRoomUid = item.key
                        self.getDestinationInfo()
                        self.userCheck = false
                        self.alert_userCheck.isHidden = false
                        //상대방이 메세지를 보내고 나가는 경우
                    }
                }//채팅방에 현재로그인된 사용자와 상대방이 모두 입장해있으면 중복 판정
            
            }
        })*/
        
        if chatRoomUid == nil{
            return
        }
        db.child("chatrooms").child(chatRoomUid!).child("users").observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
            //print(dataSnapshot.value)
            var users:Dictionary<String,Bool> = [:]//대화에 참여한 사람들
            users = dataSnapshot.value as! Dictionary<String, Bool>
            
            if let index = users.index(forKey: self.destinationUid!)  {
                //print(users[index].key, ":", users[index].value)
                if (users[index].value == true){
                    self.sendButton.isEnabled = true
                    self.getDestinationInfo()
                }else if(users[index].value == false){
                    self.getDestinationInfo()
                    self.userCheck = false
                    self.alert_userCheck.isHidden = false
                    //상대방이 메세지를 보내고 나가는 경우
                }
            }
        })
    }
    
    /*func getMessageList(){
        print("getMessageList")
        //observe 타입으로 데이터가 갱신되면 자동으로 동작
        databaseRef = db.child("chatRooms").child(self.chatRoomUid!).child("comments")
        observe = databaseRef!.observe(DataEventType.value, with: {(DataSnapshot) in
            print("메세지 받는 메소드 동작 시작")
            self.comments.removeAll()//comment가 쌓이는 것 방지
            var readUsersDic:Dictionary<String,AnyObject> = [:]
            
            for item in DataSnapshot.children.allObjects as! [DataSnapshot]{
                let key = item.key as String //채팅방의 이름을 담는 변수
                let comment = chatModel.Comment(JSON: item.value as! [String : AnyObject])
                let comment_modify = chatModel.Comment(JSON: item.value as! [String : AnyObject])
                comment_modify?.readUsers[Auth.auth().currentUser?.uid] = true//읽은 사람의 uid값을 true로 저장한다.
                
                //comment?.readUsers[Auth.auth().currentUser?.uid] = true
                readUsersDic[key] = comment_modify?.toJSON() as! NSDictionary
                self.comments.append(comment!)//JSON을 파싱한 데이터를 comment변수에 담아서 리스트에 저장
            }
            let nsDic = readUsersDic as NSDictionary
            
            
            if(self.comments.last?.readUsers.keys == nil){
                return
            }
            
            if(!(self.comments.last?.readUsers.keys.contains(Auth.auth().currentUser?.uid))!){//읽지 않은 채팅은 디비에 읽음표시해준다.
                print("읽지 않은 채팅")
                //내가 쓴 채팅이 아닐때만 읽음 표시를 업뎃해준다.(서버 과부하 방지 차원)두명이라 굳이 둘다 읽음 표시 할 필요없음
                    DataSnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: { (err,ref) in
                        self.chatTableView.reloadData()//메세지를 받아올 때마다 테이블뷰 리로드
                        
                        print("디비 업데이트 완료")
                        
                        if self.comments.count>0{
                            self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                            //키보드가 올라오면 테이블뷰 하단으로 이동(에니메이션효과)
                        }
                    })
            }else{//이미 읽은 채팅은 채팅방에 표시만 해준다.
                self.chatTableView.reloadData()//메세지를 받아올 때마다 테이블뷰 리로드
                print("디비 필요없음")

                if self.comments.count>0{
                    self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                    //키보드가 올라오면 테이블뷰 하단으로 이동(에니메이션효과)
                }
            }
        })
    }*/
    
    func sendFCM(){
       
        let url = "https://fcm.googleapis.com/fcm/send"
        let header:HTTPHeaders = [
            "Content-Type":"application/json",
            "Authorization":"key = AAAAj2R4qNg:APA91bH2ZoT0hU5yDFYF24aea9CIw7m7gGHjb08PIHxgcIyLQfDhS_hDVG6tO8ld3yRR3Wabr4pawOiDSFGWC1wxoMmutG-gsXjIO4crrn7HDie0t2MaGBftNJQhSk4PY9y2rZwpBqVq"
            //클라우드 메세지 서버키
        ]
        //print("sendFCM")
        //print(self.pushToken)
        
        let notificationmodel = notificationModel()
        notificationmodel.to = self.pushToken
        
        if (self.destinationPlatform == "android"){
            notificationmodel.data.title = self.myName
            notificationmodel.data.text = pushText
            notificationmodel.data.click_action = "m"
            let params = notificationmodel.toJSON()
            
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON{(response) in
                print(response.result.value)
            }
        }else if(self.destinationPlatform == "ios"){
            db.child("users").child(destinationUid!).child("flagMessage").observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
                let flag = DataSnapshot.value as! Int
                
                if (flag == 0){
                    notificationmodel.notification.title = self.myName
                    notificationmodel.notification.text = self.pushText
                    notificationmodel.notification.sound = "default"
                    //notificationmodel.notification.badge = 0
                    notificationmodel.notification.content_available = "true"
                    notificationmodel.notification.click_action = "m"
                    notificationmodel.data.title = self.myName
                    notificationmodel.data.text = self.pushText
                    notificationmodel.data.click_action = "m"
                    
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
    
    func getMessageList(){
        //print("getMessageList")
        //observe 타입으로 데이터가 갱신되면 자동으로 동작
        databaseRef = db.child("chatrooms").child(self.chatRoomUid!).child("comments")
        observe = databaseRef!.observe(DataEventType.value, with: {(DataSnapshot) in
            //print("메세지 받는 메소드 동작 시작")
            //print("메시지 수: \(self.comments.count)")
            self.comments.removeAll()//comment가 쌓이는 것 방지
            var readUsersDic:Dictionary<String,AnyObject> = [:]
            
            for item in DataSnapshot.children.allObjects as! [DataSnapshot]{
                let key = item.key as String //채팅방의 이름을 담는 변수
                let comment = chatModel.Comment(JSON: item.value as! [String : AnyObject])
                let comment_modify = chatModel.Comment(JSON: item.value as! [String : AnyObject])
                //comment_modify?.readUsers[Auth.auth().currentUser?.uid] = true//읽은 사람의 uid값을 true로 저장한다.
                
                //내가쓴채팅이 아닐때만 readUsers에 값을 넣어준다. 이렇게하지않으면 내가쓴것도 내가 읽게 됨
                if(comment_modify?.uid != Auth.auth().currentUser?.uid){
                    comment_modify?.readUsers = Auth.auth().currentUser?.uid
                }
                //comment?.readUsers[Auth.auth().currentUser?.uid] = true
                readUsersDic[key] = comment_modify?.toJSON() as! NSDictionary
                self.comments.append(comment!)//JSON을 파싱한 데이터를 comment변수에 담아서 리스트에 저장
            }
            let nsDic = readUsersDic as NSDictionary
            
            /*if(self.comments.last?.readUsers.keys == nil){
                //디비에 코멘트가 하나라도 있으면 걸리지 않음
                print("읽은 사람이 없음")
                return
            }*/
            /*if (self.comments.last?.readUsers == nil){
                print("읽은 사람이 없음")
                self.chatTableView.reloadData()//메세지를 받아올 때마다 테이블뷰 리로드
                
                print("디비 필요없음")
                
                if self.comments.count>0{
                    self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                    //키보드가 올라오면 테이블뷰 하단으로 이동(에니메이션효과)
                }
                return
            }*/
            if (self.comments.count == 0){
                //print("메세지 없음 ")
                return
            }
            //print(self.comments.last?.readUsers)
            
            if (self.comments.last!.uid != Auth.auth().currentUser?.uid){
                DataSnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: { (err,ref) in
                    self.chatTableView.reloadData()//메세지를 받아올 때마다 테이블뷰 리로드
                    
                    //print("디비 업데이트 완료")
                    
                    if self.comments.count>0{
                        self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                        //키보드가 올라오면 테이블뷰 하단으로 이동(에니메이션효과)
                    }
                })
            }else{
                self.chatTableView.reloadData()//메세지를 받아올 때마다 테이블뷰 리로드
                
                //print("디비 필요없음")
                
                if self.comments.count>0{
                    self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
                    //키보드가 올라오면 테이블뷰 하단으로 이동(에니메이션효과)
                }
            }
        })
    }
    
    func getDestinationInfo(){
        //print("getDestinationInfo")
        /*db.child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
            self.UserModel = userModel(JSON: DataSnapshot.value as! [String:AnyObject])
            let temp_usermodel = self.UserModel
            self.db.child("users_more").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
                self.UserModel = userModel(JSON: DataSnapshot.value as! [String:AnyObject])
                self.UserModel?.username = temp_usermodel?.username
                self.UserModel?.sex = temp_usermodel?.sex
            })
            
            self.getMessageList()
            let destinationName:String = (self.UserModel!.username)!
            UserDefaults.standard.set(true, forKey: destinationName)
            print(destinationName)
            UserDefaults.standard.synchronize()//값을 넣은 후 바로 동기화
        })*/
        
        self.getMessageList()
        //let destinationName:String = (self.UserModel!.username)!
        UserDefaults.standard.set(true, forKey: destinationName!)
        //print(destinationName)
        UserDefaults.standard.synchronize()//값을 넣은 후 바로 동기화
        checkUsers()
    }
    
    public func checkUsers(){
        var users:Dictionary<String,Bool> = [:]
        
        databaseRef_user = db.child("chatrooms").child(chatRoomUid!).child("users")
        observe_user =
        db.child("chatrooms").child(chatRoomUid!).child("users").observe(DataEventType.value) { (DataSnapshot) in
            
            for item in DataSnapshot.children.allObjects as! [DataSnapshot]{
                users[item.key] = item.value as? Bool
            }
            let uid = Auth.auth().currentUser?.uid

            if(users[self.destinationUid!] == true && users[uid!] == false){
                //내가 나간경우
                self.navigationController?.popViewController(animated: true)
            }
            else if(users[self.destinationUid!] == false && users[uid!] == false){
                //상대방과 내가 모두 나가는 경우
                self.db.child("chatrooms").child(self.chatRoomUid!).removeValue()
            }else if(users[self.destinationUid!] == false && users[uid!] == true){
                //상대방이 나가는 경우
                self.sendButton.isEnabled = false
                self.sendButton.isHidden = true
                self.messageField.isHidden = true
                self.userCheck = false
                self.alert_userCheck.isHidden = false
                //print("상대방이 나갔습니다.")
            }else{
                self.alert_userCheck.isHidden = true
                self.messageField.isHidden = false
                self.sendButton.isHidden = false
                self.sendButton.isEnabled = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)//키보드가 나타나는 동작 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)//키보드가 사라지는 동작 등록
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)
        //들어올때 네비게이션 바 색 바꿔줌
        //self.navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        self.navigationController?.navigationBar.tintColor = .darkGray
        self.navigationItem.title = destinationName
    }
    
    //뒤로갈때 네비게이션바 색바꿔줌
    override func willMove(toParent parent: UIViewController?) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    //뒤로 가기가 눌렸을 때
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        if observe != nil{
            //print("옵저버 제거")
            databaseRef!.removeObserver(withHandle: observe!)
        }
        if observe_user != nil{
            //print("user 옵저버 제거")
            databaseRef_user!.removeAllObservers()
        }
        //tabBarController?.tabBar.isHidden = false
        //tabBarController?.tabBar.isTranslucent = false
        
        if self.destinationName != nil{
            let destinationName:String = (self.destinationName)!
            UserDefaults.standard.set(false, forKey: destinationName)
            //UserDefaults.standard.set(true, forKey: myName)
            UserDefaults.standard.synchronize()//값을 넣은 후 바로 동기화
        }
    }
    
    @objc func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            self.bottomContraint.constant = keyboardSize.height
            //채팅텍스트 필드와 전송버튼의 위치변경 (키보드 높이만큼)
        }
        
        //키보드는 자동으로 에니메이션 효과가 있지만 버튼과 텍스트 필드는 그렇지 않다.
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }, completion: {(completion) in
            if self.comments.count>0{
                self.chatTableView.scrollToRow(at: IndexPath(item: self.comments.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                //키보드가 올라오면 테이블뷰 하단으로 이동(에니메이션효과)
            }
        })
    }
    
    @objc func keyboardWillHide(notification:Notification){
        self.bottomContraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    func setReadCount(label:UILabel, position:Int){
        /*let readCount = self.comments[position].readUsers!.count
        let noReadCount = 1-readCount//일대일 카톡방만 제공하므로 채팅방인원수는 2명고정 따로 디비를 불러서 셀필요 없음 -> 두명일 필요없이 한명만 세기(효율)
        
        if noReadCount>0{
            label.isHidden = false
            label.text = String(noReadCount)
        }else{
            label.isHidden = true
        }*/
        let read = self.comments[position].readUsers
        if read == nil{
            label.isHidden = false
            label.text = "1"
        }
        else{
            label.isHidden = true
        }
    }
}


extension chatViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = chatTableView.dequeueReusableCell(withIdentifier: "firstChatCell", for: indexPath) as! firstChatCell
            return cell
        }
        
        if(self.comments[indexPath.row].uid == Auth.auth().currentUser?.uid){
            
            let cell = chatTableView.dequeueReusableCell(withIdentifier: "myChatCell", for: indexPath) as! myChatCell
            
            cell.message_label.text = self.comments[indexPath.row].message
            cell.message_label.numberOfLines = 0
        
            cell.label_date.text = ""
            cell.label_date.layoutIfNeeded()
            //cell.dateHeight.constant = 0
            //cell.label_date.layer.cornerRadius = cell.label_date.frame.height/2
            //cell.label_date.layer.masksToBounds = true
            //cell.label_date.clipsToBounds = true
            
            cell.message_imageView.layer.cornerRadius = 8.0
            cell.message_imageView.layer.masksToBounds = true
            
            if let time = self.comments[indexPath.row].timestamp{
                let separatedDate = time.toDayTime.components(separatedBy: " ")//날짜 쪼개기
                let printedDate = separatedDate[0].components(separatedBy: ".")
                let date = "\(printedDate[0])년 \(printedDate[1])월 \(printedDate[2])일"
                
                if indexPath.row != self.comments.count-1{
                    if( self.comments[indexPath.row+1].timestamp?.toDayTime != self.comments[indexPath.row].timestamp?.toDayTime ||
                        self.comments[indexPath.row+1].uid != self.comments[indexPath.row].uid){
                        
                        //cell.label_timestamp.text = time.toDayTime
                        //시간이랑 분쪼개기
                        let hour = Int(separatedDate[1].components(separatedBy: ":")[0])
                        let minute = separatedDate[1].components(separatedBy: ":")[1]
                        if(hour! > 11){
                            cell.label_timestamp.text = "오후 \(hour!-12):\(minute)"
                        }else{
                            cell.label_timestamp.text = "오전 \(hour!):\(minute)"
                        }

                        //cell.label_timestamp.text = separatedDate[1]
                    }
                    else{
                        cell.label_timestamp.text = ""
                    }
                }else{
                    //cell.label_timestamp.text = time.toDayTime
                    //cell.label_timestamp.text = separatedDate[1]
                    let hour = Int(separatedDate[1].components(separatedBy: ":")[0])
                    let minute = separatedDate[1].components(separatedBy: ":")[1]
                    if(hour! > 11){
                        cell.label_timestamp.text = "오후 \(hour!-12):\(minute)"
                    }else{
                        cell.label_timestamp.text = "오전 \(hour!):\(minute)"
                    }
                }
                
                if indexPath.row != 1 {
                    let prevTime = comments[indexPath.row-1].timestamp?.toDayTime.components(separatedBy: " ")
                    if(separatedDate[0] != prevTime![0]){
                        
                        cell.label_date.text = date
                        //cell.label_date.text = separatedDate[0]
                        //cell.constraint_dateTop.constant = 8
                        cell.constraint_dateBottom.constant = 8
                    }else{
                        cell.constraint_dateTop.constant = 2
                        cell.constraint_dateBottom.constant = 0
                    }
                }else {//방성생 후 첫번째 채팅인경우->(1이 첫번째 채팅이 됨)
                    //print("첫번째 행의 날짜찍기")
                    cell.label_date.text = date
                    //cell.label_date.text = separatedDate[0]
                    cell.constraint_dateTop.constant = 8
                    cell.constraint_dateBottom.constant = 8
                }
            }
            /*if let time = self.comments[indexPath.row].timestamp{
                cell.label_timestamp.text = time.toDayTime
            }*/
            setReadCount(label: cell.label_readCounter, position: indexPath.row)
            
            //cell.label_date.layer.cornerRadius = cell.label_date.frame.height/2
            //cell.label_date.layer.masksToBounds = true
            //cell.label_date.clipsToBounds = true

            return cell
        }else{
            let cell = chatTableView.dequeueReusableCell(withIdentifier: "destinationChatCell", for: indexPath) as! destinationChatCell
            
            cell.destination_face.isUserInteractionEnabled = true
            cell.destination_face.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserInfo)))
            
            cell.message_label.text = self.comments[indexPath.row].message
            cell.message_label.numberOfLines = 0
            cell.destination_name.text = destinationName
        
            cell.label_date.text = ""
            cell.label_date.layoutIfNeeded()

            //cell.dateHeight.constant = 0
            //cell.label_date.layer.cornerRadius = cell.label_date.frame.height/2
            //cell.label_date.layer.masksToBounds = true
            //cell.label_date.clipsToBounds = true

            cell.message_imageView.layer.cornerRadius = 8.0
            cell.message_imageView.layer.masksToBounds = true
            //얼굴사진은 직전 코멘트와 비교해서 보여줄 유무를 판단한다.
            if indexPath.row != 1{
                if(self.comments[indexPath.row-1].uid == self.comments[indexPath.row].uid){
                    cell.destination_face.isHidden = true
                }else{
                    cell.destination_face.isHidden = false
                }
            }else{
                cell.destination_face.isHidden = false
            }
        
            //타임스탬프는 직후 코멘트와 비교해서 보여줄 유무를 판단한다.
            if let time = self.comments[indexPath.row].timestamp{
                let separatedDate = time.toDayTime.components(separatedBy: " ")//날짜 쪼개기
                let printedDate = separatedDate[0].components(separatedBy: ".")
                let date = "\(printedDate[0])년 \(printedDate[1])월 \(printedDate[2])일"

                if indexPath.row != self.comments.count-1{
                    if( self.comments[indexPath.row+1].timestamp?.toDayTime != self.comments[indexPath.row].timestamp?.toDayTime ||
                        self.comments[indexPath.row+1].uid != self.comments[indexPath.row].uid){
                        //cell.label_timestamp.text = time.toDayTime
                        //cell.label_timestamp.text = separatedDate[1]
                        let hour = Int(separatedDate[1].components(separatedBy: ":")[0])
                        let minute = separatedDate[1].components(separatedBy: ":")[1]
                        if(hour! > 11){
                            cell.label_timestamp.text = "오후 \(hour!-12):\(minute)"
                        }else{
                            cell.label_timestamp.text = "오전 \(hour!):\(minute)"
                        }
                        cell.constraint_bottomArea.constant = 10
                    }
                    else{
                        cell.label_timestamp.text = ""
                        cell.constraint_bottomArea.constant = 0
                    }
                }else{
                    //cell.label_timestamp.text = time.toDayTime
                    //cell.label_timestamp.text = separatedDate[1]
                    let hour = Int(separatedDate[1].components(separatedBy: ":")[0])
                    let minute = separatedDate[1].components(separatedBy: ":")[1]
                    if(hour! > 11){
                        cell.label_timestamp.text = "오후 \(hour!-12):\(minute)"
                    }else{
                        cell.label_timestamp.text = "오전 \(hour!):\(minute)"
                    }
                    //cell.label_forSpace.text = " "
                }
                
                //메세지를 보낸 날짜가 다를 경우 날짜를 찍어주는 부분
                if indexPath.row != 1 {
                    let prevTime = comments[indexPath.row-1].timestamp?.toDayTime.components(separatedBy: " ")
                    if(separatedDate[0] != prevTime![0]){
                        cell.label_date.text = date
                        //cell.constraint_dateTop.constant = 8
                        cell.constraint_dateBottom.constant = 8
                    }else{
                        cell.constraint_dateTop.constant = 2
                        cell.constraint_dateBottom.constant = 0
                    }
                }else{
                    //print("첫번째 행의 날짜찍기")
                    cell.label_date.text = date
                    cell.constraint_dateTop.constant = 8
                    cell.constraint_dateBottom.constant = 8
                }
                
                //타임스탬프를 이용하여 보낸시간이 다른경우 얼굴사진을 보여주는 예외처리
                if indexPath.row != 0{
                    if(self.comments[indexPath.row-1].timestamp?.toDayTime != self.comments[indexPath.row].timestamp?.toDayTime){
                        cell.destination_face.isHidden = false
                    }
                }
            }
            
            //얼굴사진보이도록 설정되어있으면 사진삽입
            if cell.destination_face.isHidden == false {
                //self.imageIndex = self.UserModel?.photo.keys.sorted()
                //let url = URL(string:(self.UserModel!.photo[imageIndex![0]]!.temp)!)
                //cell.destination_face.layer.cornerRadius = cell.destination_face.frame.width/2
                cell.destination_face.layer.cornerRadius = cell.destination_face.frame.width/3
                cell.destination_face.layer.masksToBounds = true
                cell.destination_face.image = destinationImage
                //cell.destination_face.kf.setImage(with:url)
            }else{
                cell.destination_name.text = ""
            }
            
            //얼굴사진이 보이면 이름도 보이도록 설정
            //cell.destination_name.isHidden = cell.destination_face.isHidden
            setReadCount(label: cell.label_readCounter, position: indexPath.row)
            
            //cell.label_date.layer.cornerRadius = cell.label_date.frame.height/2
            //cell.label_date.layer.masksToBounds = true
            //cell.label_date.clipsToBounds = true
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
    //셀크기 설정도 뷰마다 다르게 해줘야함
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 10
        }
        return UITableView.automaticDimension
        //if(self.comments[indexPath.row].uid == Auth.auth().currentUser?.uid){
        
        
        
        /*if let time = self.comments[indexPath.row].timestamp{
            if indexPath.row != 1 {
                let separatedDate = time.toDayTime.components(separatedBy: " ")//날짜 쪼개기
                let prevTime = comments[indexPath.row-1].timestamp?.toDayTime.components(separatedBy: " ")
                if(separatedDate[0] != prevTime![0]){
                    return UITableView.automaticDimension//+140
                }else{
                    return UITableView.automaticDimension
                }
            }
            else {//방성생 후 첫번째 채팅인경우
                return UITableView.automaticDimension//+130
            }
        }else{
            return UITableView.automaticDimension
        }*/
        
        
        
        /*}else{
            if let time = self.comments[indexPath.row].timestamp{
                if indexPath.row != 0 {
                    
                    let separatedDate = time.toDayTime.components(separatedBy: " ")//날짜 쪼개기
                    
                    let prevTime = comments[indexPath.row-1].timestamp?.toDayTime.components(separatedBy: " ")
                    if(separatedDate[0] != prevTime![0]){
                        return UITableView.automaticDimension+115
                    }else{
                        return UITableView.automaticDimension
                    }
                }
                    
                else{//방성생 후 첫번째 채팅인경우
                    return UITableView.automaticDimension+115
                }
            }
            else{
                return UITableView.automaticDimension
            }
        }*/
    }
    
    /*func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }*/
}

extension Int{
    var toDayTime:String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        
        return dateFormatter.string(from: date)
    }
}
