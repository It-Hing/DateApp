//
//  signUp_EnrollProfileController.swift
//  drink
//
//  Created by user on 14/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreImage
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Firebase
import SwiftKeychainWrapper
import Alamofire

class signUp_EnrollProfileController:UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,DimissManager{
    
    func vcDismissed() {
        if UserDefaults.standard.value(forKey: "age") != nil{
            let age = UserDefaults.standard.value(forKey: "age") as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyy"
            let date = Date()
            let today = Int(dateFormatter.string(from: date))
            let birthyear = Int(age)
            let userage = today! - birthyear! + 1
            
            label_ageContent.text = "\(userage)세"
            label_ageContent.textColor = .black
            
            birthYear = age
            UserDefaults.standard.removeObject(forKey: "age")
        }
        if UserDefaults.standard.value(forKey: "personality") != nil{
            let personality = UserDefaults.standard.value(forKey: "personality") as! String
            label_personalityContent.text = personality
            label_personalityContent.textColor = .black
            UserDefaults.standard.removeObject(forKey: "personality")
        }
        if UserDefaults.standard.value(forKey: "tall") != nil{
            let tall = UserDefaults.standard.value(forKey: "tall") as! String
            label_tallContent.text = tall
            label_tallContent.textColor = .black
            UserDefaults.standard.removeObject(forKey: "tall")
        }
        if UserDefaults.standard.value(forKey: "body") != nil{
            let body = UserDefaults.standard.value(forKey: "body") as! String
            label_bodyContent.text = body
            label_bodyContent.textColor = .black
            UserDefaults.standard.removeObject(forKey: "body")
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var confirmImageView: UIImageView!
    @IBOutlet weak var profileTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageUnselectConstraint: NSLayoutConstraint!//필요없는 변수(추후 삭제)
    @IBOutlet weak var userNameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var label_username: UILabel!
    @IBOutlet weak var label_userage: UILabel!
    @IBOutlet weak var label_userpersonality: UILabel!
    @IBOutlet weak var label_usertall: UILabel!
    @IBOutlet weak var label_userbody: UILabel!
    @IBOutlet weak var label_userName: UILabel!
    @IBOutlet weak var label_userAge: UILabel!
    @IBOutlet weak var label_userPersonality: UILabel!
    @IBOutlet weak var label_userTall: UILabel!
    @IBOutlet weak var label_userBody: UILabel!
    @IBOutlet weak var label_recommend: UILabel!
    @IBOutlet weak var label_Recommend: UILabel!
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var label_ageContent: UILabel!
    @IBOutlet weak var label_personalityContent: UILabel!
    @IBOutlet weak var label_tallContent: UILabel!
    @IBOutlet weak var label_bodyContent: UILabel!
    @IBOutlet weak var label_userNameAlert: UILabel!
    @IBOutlet weak var recommendTextField: UITextField!
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var label_checkImage: UILabel!
    
    @IBOutlet weak var bottomContraint: NSLayoutConstraint!
    
    let db = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var isAdd:Bool = false//사진이 추가되었는지 아닌지 체크하는 변수
    var nameIsEnable:Bool? = nil
    //var nameList:[String] = []
    var list:[String] = []//팝업창을 띄울 때 팝업창의 테이블뷰에 들어갈 내용
    var birthYear:String?
    
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
        }
        
        
        confirmImageView.isHidden = true
        userNameTextField.delegate = self
        //userNameTextField.isEnabled = false
        
        //
        userImageView.layer.cornerRadius = 10.0
        let borderColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        plusImageView.image = plusImageView.image?.maskWithColor(color: borderColor)
        userImageView.layer.borderColor = borderColor.cgColor
        userImageView.layer.borderWidth = 1.0
        confirmImageView.layer.cornerRadius = 10.0
        userImageView.layer.masksToBounds = true
        confirmImageView.layer.masksToBounds = true
        //
        label_username.layer.borderWidth = 0.5
        label_username.layer.borderColor = UIColor.lightGray.cgColor
        label_userName.layer.borderWidth = 0.5
        label_userName.layer.borderColor = UIColor.lightGray.cgColor
        label_userage.layer.borderWidth = 0.5
        label_userage.layer.borderColor = UIColor.lightGray.cgColor
        label_userAge.layer.borderWidth = 0.5
        label_userAge.layer.borderColor = UIColor.lightGray.cgColor
        label_userpersonality.layer.borderWidth = 0.5
        label_userpersonality.layer.borderColor = UIColor.lightGray.cgColor
        label_userPersonality.layer.borderWidth = 0.5
        label_userPersonality.layer.borderColor = UIColor.lightGray.cgColor
        label_usertall.layer.borderWidth = 0.5
        label_usertall.layer.borderColor = UIColor.lightGray.cgColor
        label_userTall.layer.borderWidth = 0.5
        label_userTall.layer.borderColor = UIColor.lightGray.cgColor
        label_userbody.layer.borderWidth = 0.5
        label_userbody.layer.borderColor = UIColor.lightGray.cgColor
        label_userBody.layer.borderWidth = 0.5
        label_userBody.layer.borderColor = UIColor.lightGray.cgColor
        label_recommend.layer.borderWidth = 0.5
        label_recommend.layer.borderColor = UIColor.lightGray.cgColor
        label_Recommend.layer.borderWidth = 0.5
        label_Recommend.layer.borderColor = UIColor.lightGray.cgColor
        //
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        label_ageContent.isUserInteractionEnabled = true
        label_ageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ageTapped)))
        label_personalityContent.isUserInteractionEnabled = true
        label_personalityContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(personalityTapped)))
        label_tallContent.isUserInteractionEnabled = true
        label_tallContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tallTapped)))
        label_bodyContent.isUserInteractionEnabled = true
        label_bodyContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTapped)))
        //
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    /*func getNameList(){
        if userNameTextField.text == ""{
            return
        }
        db.child("users").queryOrdered(byChild: "/userName").queryEqual(toValue: userNameTextField.text).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
            if dataSnapshot.exists(){
                self.userNameHeight.constant = 50
                self.label_userNameAlert.textColor = UIColor.red
                self.label_userNameAlert.text = "이미 사용중인 이름입니다."
                self.nameIsEnable = false
            }else{
                self.userNameHeight.constant = 50
                self.label_userNameAlert.textColor = UIColor.green
                self.label_userNameAlert.text = "사용 가능한 이름입니다."
                self.nameIsEnable = true
            }
        })
    }*/
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func signUpCancelTapped(_ sender: Any) {
        
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = signUpCancel
        popupVC.alertTitle = "가입취소"
        popupVC.alertContent = "가입을 취소하시겠습니까?"
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        //popupVC.ver = 1
        self.present(popupVC, animated: true, completion: nil)
        
    }
    
    func signUpCancel(){
        let email = KeychainWrapper.standard.string(forKey: "email")
        let password = KeychainWrapper.standard.string(forKey: "pwd")
        
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, error) in
            if error == nil {
                Auth.auth().currentUser?.delete(completion: { (err) in
                    if err != nil{
                        print(err as Any)
                    }else{
                        KeychainWrapper.standard.removeObject(forKey: "email")
                        KeychainWrapper.standard.removeObject(forKey: "pwd")
                        KeychainWrapper.standard.removeObject(forKey: "enrollProfile")
                        KeychainWrapper.standard.removeObject(forKey: "mysex")
                        //UserDefaults.standard.removeObject(forKey:"enrollProfile")
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }else {
                //handle error
            }
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
        })
    }
    
    @objc func keyboardWillHide(notification:Notification){
        self.bottomContraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func ageTapped(){
        list.removeAll()
        for i in 0...23{
            let item = i+1980
            list.append(String(item))
        }
        showSelectPopUp(kind: "나이")
    }
    
    @objc func personalityTapped(){
        list.removeAll()
        
        var Sex:String?
        
        if KeychainWrapper.standard.string(forKey: "mysex") != nil{
            Sex = KeychainWrapper.standard.string(forKey: "mysex")
        }
        
        if(Sex == "남자"){
            list.append("지적인")
            list.append("차분한")
            list.append("유머있는")
            list.append("낙천적인")
            list.append("내향적인")
            list.append("외향적인")
            list.append("감성적인")
            list.append("상냥한")
            list.append("귀여운")
            list.append("열정적인")
            list.append("듬직한")
            list.append("개성있는")
        }else{
            list.append("지적인")
            list.append("차분한")
            list.append("유머있는")
            list.append("낙천적인")
            list.append("내향적인")
            list.append("외향적인")
            list.append("감성적인")
            list.append("상냥한")
            list.append("귀여운")
            list.append("섹시한")
            list.append("4차원")
            list.append("발랄한")
            list.append("도도한")
        }
        
        showSelectPopUp(kind: "성격")
    }
    
    @objc func tallTapped(){
        list.removeAll()
        for i in 0...50{
            let item = i+150
            list.append(String(item))
        }
        showSelectPopUp(kind: "키")
    }
    
    @objc func bodyTapped(){
        list.removeAll()
        
        var Sex:String?
        
        if KeychainWrapper.standard.string(forKey: "mysex") != nil{
            Sex = KeychainWrapper.standard.string(forKey: "mysex")
        }
        
        if(Sex == "남자"){
            list.append("평범한")
            list.append("통통한")
            list.append("근육질")
            list.append("건장한")
            list.append("마른")
            list.append("슬림탄탄")
        }else{
            list.append("평범한")
            list.append("통통한")
            list.append("살짝볼륨")
            list.append("글래머")
            list.append("마른")
            list.append("슬림탄탄")
        }
        showSelectPopUp(kind: "체형")
    }
    
    func showSelectPopUp(kind:String){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC = storyBoard.instantiateViewController(withIdentifier: "profilePopUpController") as! profilePopUpController
        popupVC.delegate = self
        popupVC.list = list
        popupVC.kindOfList = kind
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(popupVC, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        if isAdd == false{
            label_checkImage.isHidden = true
            checkImageView.isHidden = true
            profileTopConstraint.constant = -confirmImageView.frame.height
        }else{
            label_checkImage.isHidden = false
            checkImageView.isHidden = false
            profileTopConstraint.constant = 20
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)//키보드가 나타나는 동작 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)//키보드가 사라지는 동작 등록
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        self.view.endEditing(true)

        loadingVC.show()
        
        if (label_ageContent.text!.count == 0 || label_personalityContent.text!.count == 0 || label_tallContent.text!.count == 0 || label_bodyContent.text!.count == 0){
            loadingVC.hide()
            ToastViewController.show(message: "필수항목을 모두 기재해주세요.", controller: self)
            print("칸이 비었음")
            return
        }
        
        if isAdd == false{
            loadingVC.hide()
            ToastViewController.show(message: "필수항목을 모두 기재해주세요.", controller: self)
            print("사진이 없음")
            return
        }
        
        if userNameTextField.text!.count == 0{
            userNameHeight.constant = 50
            label_userNameAlert.text = "닉네임을 입력해주세요."
            label_userNameAlert.textColor = UIColor.red
            loadingVC.hide()
            return
        }
        
        //닉네임 중복검사
        db.child("users").queryOrdered(byChild: "/userName").queryEqual(toValue: userNameTextField.text).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
            if dataSnapshot.exists(){
                self.userNameHeight.constant = 50
                self.label_userNameAlert.textColor = UIColor.red
                self.label_userNameAlert.text = "이미 사용중인 이름입니다."
                loadingVC.hide()
                return
            }else{
                self.userNameHeight.constant = 50
                self.label_userNameAlert.textColor = UIColor.green
                self.label_userNameAlert.text = "사용 가능한 이름입니다."
                if (self.recommendTextField.text != ""){
                    self.db.child("users").queryOrdered(byChild: "/userName").queryEqual(toValue: self.recommendTextField.text).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                        if (!dataSnapshot.exists()){
                            ToastViewController.show(message: "존재하지 않는 추천인입니다.", controller: self)
                            loadingVC.hide()
                            return
                        }else{
                            self.signUpAction()
                        }
                    })
                }else{
                    self.signUpAction()
                }
            }
        })
    }
    
    func signUpAction(){
        var Sex:String?
        if KeychainWrapper.standard.string(forKey: "mysex") != nil{
            Sex = KeychainWrapper.standard.string(forKey: "mysex")
        }
        
        guard let username = userNameTextField.text,
            username != "",
            let age = birthYear,
            age != "",
            let personality = label_personalityContent.text,
            personality != "",
            let tall = label_tallContent.text,
            tall != "",
            let body = label_bodyContent.text,
            body != "",
            let sex = Sex,
            sex != ""
            else{
                loadingVC.hide()
                ToastViewController.show(message: "필수항목을 모두 기재해주세요.", controller: self)
                print("guard let 에서 걸림")
                return
        }
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges { (error) in}//사용자프로필등록
        //
        let storage = Storage.storage()
        let storageRef = storage.reference().child("userImages").child(uid!)
        //
        let userImage = userImageView.image?.jpegData(compressionQuality: 0.1)
        
        let freeHeart = 100
        
        db.child("users").child(uid!).setValue([
            "email" : Auth.auth().currentUser?.email! as Any,
            "userName" : username,
            "sex" : sex,
            "age" : age,
            "personality" : personality,
            "tall" : tall + "cm",
            "body" : body,
            "photo" : "",
            "heart" : "\(freeHeart)",
            "platform" : "ios",
            "flagMessage" : 0,
            "flagPropose" : 0,
            "flagRecive" : 0
            ],withCompletionBlock: {(err,ref) in
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ko_KR")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                var date = Date()
                var time = dateFormatter.string(from: date)
                
                self.db.child("Buys").child(self.uid!).childByAutoId().setValue([
                    "buys_change" : "+\(freeHeart)",
                    "buys_comment" : "무료충전",
                    "buys_date" : time,
                    "buys_id" : "ios",
                    "current_heart" : "\(freeHeart)"
                    ])
                //추천인 입력했을 때 하트 100개 더해주는 부분
                if (self.recommendTextField.text != ""){
                    self.db.child("users").queryOrdered(byChild: "/userName").queryEqual(toValue: self.recommendTextField.text).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                        if dataSnapshot.exists(){
                            let data = dataSnapshot.value as! [String:AnyObject]
                            self.db.child("users").child(data.keys.first!).child("heart").observeSingleEvent(of: DataEventType.value,with: { (datasnapshot) in
                                var heart = String(describing: datasnapshot.value!)
                                var heartNum = Int(heart)
                                heartNum = heartNum! + 100
                                heart = String(describing: heartNum!)
                                self.db.child("users").child(data.keys.first!).child("heart").setValue(heart, withCompletionBlock: { (err, ref) in
                                    
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    date = Date()
                                    time = dateFormatter.string(from: date)
                                    self.db.child("Buys").child(self.uid!).childByAutoId().setValue([
                                        "buys_change" : "+100",
                                        "buys_comment" : "추천인",
                                        "buys_date" : time,
                                        "buys_id" : "ios",
                                        "current_heart" : "200"
                                        ])
                                })
                            })
                            self.db.child("users").child(self.uid!).child("heart").observeSingleEvent(of: DataEventType.value,with: { (datasnapshot) in
                                var heart = String(describing: datasnapshot.value!)
                                var heartNum = Int(heart)
                                heartNum = heartNum! + 100
                                heart = String(describing: heartNum!)
                                self.db.child("users").child(self.uid!).child("heart").setValue(heart)
                            })
                        }
                    })
                }
                
                var imageHash:String?
                
                //let dateFormatter = DateFormatter()
                //dateFormatter.locale = Locale(identifier: "ko_KR")
                dateFormatter.dateFormat = "yyyyMMddHHmmss"
                date = Date()
                imageHash = dateFormatter.string(from: date)
                
                //let imageHash = String(userImage.hashValue)//이미지 해쉬코드
                storageRef.child(imageHash!).putData(userImage!, metadata: nil, completion: { (data, error)in
                    if(error != nil){
                        print(error as Any)
                        return
                    }
                    // Fetch the download URL
                    storageRef.child(imageHash!).downloadURL { url, error in
                        if let error = error {
                            print(error)
                            return
                        } else {
                            // Get the download URL
                            let imageUrl:String = (url?.absoluteString) ?? ""
                            self.db.child("users").child(self.uid!).child("photo").childByAutoId().updateChildValues([
                                "temp":imageUrl,
                                "tempHashCode":imageHash as Any
                                ], withCompletionBlock: { (err, ref) in
                                    let uid = Auth.auth().currentUser?.uid
                                    InstanceID.instanceID().instanceID { (result, error) in
                                        if let error = error {
                                            print("Error fetching remote instance ID: \(error)")
                                        } else if let result = result {
                                            print("Remote instance ID token: \(result.token)")
                                            self.db.child("users").child(uid!).child("pushToken").setValue(result.token)
                                        }
                                    }
                                    
                                    ///////////////////////관리자 페이지에 업데이트해줌
                                    self.db.child("administer").child("users").child(uid!).setValue(true)
                                    ///////////////////////
                                    
                                    //가입하면 자동으로 로그인되기때문에 토큰값을 넣어줘야 푸시받을 수 있음
                                    //UserDefaults.standard.removeObject(forKey:"enrollProfile")
                                    KeychainWrapper.standard.removeObject(forKey: "enrollProfile")
                                    KeychainWrapper.standard.removeObject(forKey: "mysex")
                                    UserDefaults.standard.set("전체", forKey: "sex")
                                    UserDefaults.standard.synchronize()
                                    //userdefault를 지워주고 뷰이동
                                    KeychainWrapper.standard.set(true, forKey: "loginCheck")
                                    //로그인 되어 있다고 표시
                                    self.sendFCM()
                                    loadingVC.hide()
                                    
                                    if let mapController = self.storyboard?.instantiateViewController(withIdentifier: "tabBarNavigationBar"){
                                        mapController.modalPresentationStyle = .fullScreen
                                        mapController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                        self.present(mapController, animated: true, completion: nil)
                                    }
                                    //서버에서 등록이 끝나면 자동으로 맵으로 뷰이동
                            })
                            
                        }
                    }
                })
        })
    }
    
    @objc func imagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            userImageView.image = image
            confirmImageView.isHidden = false
            confirmImageView.image = image
            isAdd = true
            //profileTopConstraint.constant = 20

            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func sendFCM(){
        let url = "https://fcm.googleapis.com/fcm/send"
        let header:HTTPHeaders = [
            "Content-Type":"application/json",
            "Authorization":"key = AAAAj2R4qNg:APA91bH2ZoT0hU5yDFYF24aea9CIw7m7gGHjb08PIHxgcIyLQfDhS_hDVG6tO8ld3yRR3Wabr4pawOiDSFGWC1wxoMmutG-gsXjIO4crrn7HDie0t2MaGBftNJQhSk4PY9y2rZwpBqVq"
            //클라우드 메세지 이전서버키
        ]
        var pushToken:String?
        db.child("administer").child("sinabro").child("hyeon").observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
            
            let destinationUid = String(describing: dataSnapshot.value!)
            self.db.child("users").child(destinationUid).child("pushToken").observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                pushToken = String(describing: dataSnapshot.value!)
                
                let notificationmodel = notificationModel()
                notificationmodel.to = pushToken
                
                let title = "심사요청"
                let kind = "p"
                let pushText = "신규고객이 사진심사를 요청하셨습니다."
                
                notificationmodel.data.title = title
                //푸시를 받은 상대방이 보낸 사람의 정보를 보기위해 uid를 같이 보냄.
                notificationmodel.data.text = pushText
                notificationmodel.data.click_action =  kind+""
                let params = notificationmodel.toJSON()
                
                Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: header).responseJSON{(response) in
                    //print((response.result.value)!)
                }
            })
        })
    }

}

extension signUp_EnrollProfileController:UITextFieldDelegate{
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if userNameTextField.text == ""{
            self.userNameHeight.constant = 40
            self.label_userNameAlert.text = ""
        }else{
            //getNameList()
        }
        return true
    }
    
}

protocol DimissManager {
    func vcDismissed()
}
