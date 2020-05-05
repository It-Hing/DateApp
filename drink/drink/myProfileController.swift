//
//  myProfileController.swift
//  drink
//
//  Created by user on 22/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftKeychainWrapper
import Alamofire

class myProfileController:UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,DimissManager{
    
    func vcDismissed() {
        let uid = Auth.auth().currentUser?.uid
        
        if UserDefaults.standard.value(forKey: "personality") != nil{
            let personality = UserDefaults.standard.value(forKey: "personality") as! String
            label_personalityContent.text = personality
            label_personalityContent.textColor = .black
            UserDefaults.standard.removeObject(forKey: "personality")
            self.db.child("users").child(uid!).child("personality").setValue(personality)
        }
        if UserDefaults.standard.value(forKey: "tall") != nil{
            let tall = UserDefaults.standard.value(forKey: "tall") as! String
            label_tallContent.text = tall
            label_tallContent.textColor = .black
            UserDefaults.standard.removeObject(forKey: "tall")
            self.db.child("users").child(uid!).child("tall").setValue(tall+"cm")
        }
        if UserDefaults.standard.value(forKey: "body") != nil{
            let body = UserDefaults.standard.value(forKey: "body") as! String
            label_bodyContent.text = body
            label_bodyContent.textColor = .black
            UserDefaults.standard.removeObject(forKey: "body")
            self.db.child("users").child(uid!).child("body").setValue(body)
        }
    }
    
    //
    @IBOutlet weak var label_nameBox: UILabel!
    @IBOutlet weak var label_ageBox: UILabel!
    @IBOutlet weak var label_personalityBox: UILabel!
    @IBOutlet weak var label_tallBox: UILabel!
    @IBOutlet weak var label_bodyBox: UILabel!
    @IBOutlet weak var label_mentBox: UILabel!
    
    @IBOutlet weak var label_nameKey: UILabel!
    @IBOutlet weak var label_ageKey: UILabel!
    @IBOutlet weak var label_personalityKey: UILabel!
    @IBOutlet weak var label_tallKey: UILabel!
    @IBOutlet weak var label_bodyKey: UILabel!
    @IBOutlet weak var label_mentKey: UILabel!
    
    @IBOutlet weak var label_nameContent: UILabel!
    @IBOutlet weak var label_ageContent: UILabel!
    @IBOutlet weak var label_personalityContent: UILabel!
    @IBOutlet weak var label_tallContent: UILabel!
    @IBOutlet weak var label_bodyContent: UILabel!
    @IBOutlet weak var TF_ment: UITextField!
    //
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var imageList:[UIImage] = [] //이미지를 관리하는 리스트
    var usermodel:userModel?
    var imageIndex:Int?
    var imageHash:[String] = [] //이미지 해시코드를 관리하는 배열
    //var imageCount:Int? = 0
    let db = Database.database().reference()
    var imageRoomId:[String] = []//이미지객체를 담고 있는 방의 값을 보관하는 리스트
    var list:[String] = []//팝업창을 띄울 때 팝업창의 테이블뷰에 들어갈 내용

    //이미지를 담아서 보관할 리스트
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        navigationBar.backgroundColor = .clear
        navigationBar.isTranslucent = true
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = true
        //self.navigationController?.view.backgroundColor = .clear
        
        screenSetting()
        self.getImage()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy"
        let date = Date()
        let today = Int(dateFormatter.string(from: date))
        let birthYear = Int(self.usermodel!.age!)
        let age = today! - birthYear! + 1
        //let userage:String?

        self.label_nameContent.text = self.usermodel?.username
        self.label_ageContent.text = "\(age)세"
        self.label_personalityContent.text = self.usermodel?.personality
        self.label_tallContent.text = self.usermodel?.tall
        self.label_bodyContent.text = self.usermodel?.body
        self.TF_ment.text = self.usermodel!.comment
        //getUsermodel()
        label_personalityContent.isUserInteractionEnabled = true
        label_personalityContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(personalityTapped)))
        label_tallContent.isUserInteractionEnabled = true
        label_tallContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tallTapped)))
        label_bodyContent.isUserInteractionEnabled = true
        label_bodyContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bodyTapped)))
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)//키보드가 나타나는 동작 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)//키보드가 사라지는 동작 등록
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            self.bottomConstraint.constant = keyboardSize.height
            //채팅텍스트 필드와 전송버튼의 위치변경 (키보드 높이만큼)
        }
        
        //키보드는 자동으로 에니메이션 효과가 있지만 버튼과 텍스트 필드는 그렇지 않다.
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }, completion: {(completion) in

        })
    }
    
    @objc func keyboardWillHide(notification:Notification){
        self.bottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /*let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor =
                UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        }
        //상태바 색변경
        self.navigationController?.setNavigationBarHidden(true, animated: false)*/
        if TF_ment.text != ""{
            let uid = Auth.auth().currentUser?.uid
            self.db.child("users").child(uid!).child("comment").setValue(TF_ment.text)
        }
    }
    
    @objc func personalityTapped(){
        list.removeAll()
        
        let Sex:String = usermodel!.sex!
        
        /*if KeychainWrapper.standard.string(forKey: "mysex") != nil{
            Sex = KeychainWrapper.standard.string(forKey: "mysex")
        }*/
        
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
        
        Sex = usermodel!.sex!
        
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
    
    func screenSetting(){
        label_nameBox.layer.borderWidth = 0.5
        label_nameBox.layer.borderColor = UIColor.lightGray.cgColor
        //label_nameBox.layer.masksToBounds = true
        label_ageBox.layer.borderWidth = 0.5
        label_ageBox.layer.borderColor = UIColor.lightGray.cgColor
        label_tallBox.layer.borderWidth = 0.5
        label_tallBox.layer.borderColor = UIColor.lightGray.cgColor
        label_bodyBox.layer.borderWidth = 0.5
        label_bodyBox.layer.borderColor = UIColor.lightGray.cgColor
        label_mentBox.layer.borderWidth = 0.5
        label_mentBox.layer.borderColor = UIColor.lightGray.cgColor
        label_personalityBox.layer.borderWidth = 0.5
        label_personalityBox.layer.borderColor = UIColor.lightGray.cgColor
        
        label_nameKey.layer.borderWidth = 0.5
        label_nameKey.layer.borderColor = UIColor.lightGray.cgColor
        label_ageKey.layer.borderWidth = 0.5
        label_ageKey.layer.borderColor = UIColor.lightGray.cgColor
        label_tallKey.layer.borderWidth = 0.5
        label_tallKey.layer.borderColor = UIColor.lightGray.cgColor
        label_bodyKey.layer.borderWidth = 0.5
        label_bodyKey.layer.borderColor = UIColor.lightGray.cgColor
        label_mentKey.layer.borderWidth = 0.5
        label_mentKey.layer.borderColor = UIColor.lightGray.cgColor
        label_personalityKey.layer.borderWidth = 0.5
        label_personalityKey.layer.borderColor = UIColor.lightGray.cgColor
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
                let pushText = "기존고객님이 사진심사를 요청하셨습니다."
                
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
    
    /*func getUsermodel(){
        let db = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        db.child("users").child(uid!).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            let data = datasnapshot.value as! [String:AnyObject]
            self.usermodel = userModel(JSON: data)
            self.usermodel!.uid = datasnapshot.key
            print("내정보받아옴")
            self.getImage()
            self.label_nameContent.text = self.usermodel?.username
            self.label_ageContent.text = self.usermodel?.age
            self.label_personalityContent.text = self.usermodel?.personality
            self.label_tallContent.text = self.usermodel?.tall
            self.label_bodyContent.text = self.usermodel?.body
        })
    }*/
    
    //처음들어왔을 때 사진을 뿌려주고 다른 상황에서는 작동하지 않음.
    func getImage(){
        let photoIndex = usermodel!.photo.keys.sorted()//.keys.sorted(){$0>$1}
        //사진이 정렬되지 않은상태로 들어오기때문에 한번 정렬을 해준뒤 사용한다.
        //키값으로 정렬하고 리스트에 접근한다.
        imageRoomId = photoIndex
        //정렬된 키값을 그대로 imageroomid리스트에 넣어준다.
        
        for index in photoIndex{
            let url:URL?
            let data = usermodel!.photo[index]
            
            //imageRoomId.append(index)
            //index = imageurl
            
            print(data?.image)
            print(data?.imageHashCode)
            
            if data!.temp != nil{
                //imageUrlList.append(data.temp!)
                url = URL(string:data!.temp!)
                imageHash.append(data!.tempHashCode!)
            }else{
                //imageUrlList.append(data.image!)
                url = URL(string:data!.image!)
                imageHash.append(data!.imageHashCode!)
            }
            
            KingfisherManager.shared.retrieveImage(with: url!, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    //print("Image: \(value.image). Got from: \(value.cacheType)")
                    self.imageList.append(value.image)
                    self.imageCollectionView.reloadData()
                    break
                case .failure(let error):
                    print("Error: \(error)")
                    break
                }
            }
            //이미지 리스트에 이미지를 담아줌

        }
    }
    
    func imagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //이미지는 실제 사용자에게 보이는 부분과 서버 부분이 동시에 동작하는 것처럼 보이면서 따로 돌아간다.(속도 때문에)
    //사용자에게 보이는 부분은 이미지 리스트를 사용해서 따로 관리해준다.
    //이미지리스트를 이용해서 화면에 보여주기 때문에 서버로 전송되는 지연시간은 사용자가 알아챌수 없다.
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            loadingVC.show()
            //이미지가 새로 추가되는 경우
            //let imageHashCode = String(image.hashValue)
            //let time = ServerValue.timestamp()
            var imageHashCode:String?
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let date = Date()
            imageHashCode = dateFormatter.string(from: date)
            print(time)
            
            print("imageHashCode: \(imageHashCode)")
            
            let storage = Storage.storage()
            let storageRef = storage.reference().child("userImages").child(usermodel!.uid!)
            let userImage = image.jpegData(compressionQuality: 0.1)
            //let imageHashCode = String(userImage.hashValue)//이미지 해쉬코드
            let imageCount:Int = imageList.count-1
            //
            if imageIndex! > imageCount{
                imageList.append(image)
            }else{
                //기존의 이미지가 변경되는 경우
                imageList[imageIndex!] = image
            }
            
            self.dismiss(animated: true, completion: nil)
            
            storageRef.child(imageHashCode!).putData(userImage!, metadata: nil, completion: { (data, error)in
                if(error != nil){
                    print(error as Any)
                    loadingVC.hide()
                    return
                }
                // Fetch the download URL
                storageRef.child(imageHashCode!).downloadURL { url, error in
                    if let error = error {
                        print(error)
                        loadingVC.hide()
                        return
                    } else {
                        //관리자 계정에 업데이트
                        let uid = Auth.auth().currentUser?.uid
                        self.db.child("administer").child("users").child(uid!).setValue(true)
                        
                        // Get the download URL
                        let imageUrl:String = (url?.absoluteString) ?? ""
                        if self.imageIndex! > imageCount{
                            //이미지가 새로 추가되는 경우
                            //위에서 이미지가 이미 추가되었기때문에
                            //imageList.count-1이 아니라 imageList.count-2가 된다.
                            print("이미지가 새로 추가됨")
                            self.db.child("users").child(self.usermodel!.uid!).child("photo").childByAutoId().updateChildValues([
                                "temp":imageUrl,
                                "tempHashCode":imageHashCode as Any
                                ], withCompletionBlock: { (err, ref) in
                                    self.imageRoomId.append(ref.key!)
                                    self.imageHash.append(imageHashCode!)
                                    //print("imageKey : \(ref.key)")
                                    //방이름을 리스트에 추가
                                    //이미지관리를 위해 해쉬코드리스트에 추가
                                    self.sendFCM()
                                    loadingVC.hide()
                            })
                        }else{
                            //기존의 이미지가 변경되는 경우
                            print("기존이미지가 변경됨")
                            self.db.child("users").child(self.usermodel!.uid!).child("photo").child(self.imageRoomId[self.imageIndex!]).child("tempHashCode").observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                                self.db.child("users").child(self.usermodel!.uid!).child("photo").child(self.imageRoomId[self.imageIndex!]).updateChildValues([
                                    "temp":imageUrl,
                                    "tempHashCode":imageHashCode as Any
                                    ], withCompletionBlock: { (err, ref) in
                                        if err != nil{
                                            print(err)
                                            loadingVC.hide()
                                        }
                                        self.sendFCM()
                                        
                                        if dataSnapshot.exists(){
                                            let tempHash = String(describing: dataSnapshot.value!)
                                            storageRef.child(tempHash).delete(completion: { (err) in
                                                if err != nil{
                                                    print(err)
                                                    loadingVC.hide()
                                                    return
                                                }
                                                loadingVC.hide()
                                            })
                                        }else{
                                            loadingVC.hide()
                                        }
                                })//db에 저장되어 있는 값도 변경해준다.->끝(이미지 업로드도 완료되어있음.)
                            })
                            
                            self.imageHash[self.imageIndex!] = imageHashCode!
                        }
                        
                    }
                }
            })
        }
        
        imageCollectionView.reloadData()
    }
    
    func deleteImage(){
        loadingVC.show()
        //print("before_imageList[imageIndex]:\(imageList[imageIndex!])")
        imageList.remove(at: imageIndex!)
        //print("after_imageList[imageIndex]:\(imageList[imageIndex!])")
        print("이미지방 아이디: \(imageRoomId[imageIndex!])")
        //print("imageIndex:\(imageIndex)")
        db.child("users").child(usermodel!.uid!).child("photo").child(imageRoomId[imageIndex!]).removeValue { (err, ref) in
            //db에서도 지워준다.
            
            let storage = Storage.storage()
            let storageRef = storage.reference().child("userImages").child(self.usermodel!.uid!)
            
            storageRef.child(self.imageHash[self.imageIndex!]).delete(completion: { (err) in
                if err != nil{
                    print(err)
                    loadingVC.hide()
                    return
                }
                self.db.child("users").child(self.usermodel!.uid!).child("photo").observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                    
                    for photo in dataSnapshot.children.allObjects as! [DataSnapshot]{
                        let data = photo.value
                        self.usermodel?.mainPhoto = userModel.Photo(JSON: data as! [String: AnyObject])
                        if self.usermodel?.mainPhoto?.temp != nil{
                            print("임시이미지 존재해서 삭제하지않음")
                            break
                        }
                        let last = dataSnapshot.children.allObjects.last! as! DataSnapshot
                        if (photo.key == last.key){
                            let uid = Auth.auth().currentUser?.uid
                            print("관리자디비에서 심사요청삭제")
                            self.db.child("administer").child("users").child(uid!).removeValue()
                        }else{
                            print(photo)
                            print(dataSnapshot.children.allObjects.last)
                            print("마지막 사진이 아님")
                        }
                    }
                })
                /*self.db.child("users").child(usermodel!.uid!).child("photo").queryOrdered(byChild:).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
                    
                })*/
                //self.db.child("administer").child("users").child(uid!).setValue(true)
                self.imageRoomId.remove(at: self.imageIndex!)
                self.imageHash.remove(at: self.imageIndex!)
                loadingVC.hide()
            })//스토리지에서 이미지를 삭제 -> 끝
        }
        imageCollectionView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func showIndex(sender : imageTapGesture){
        print(sender.index)
        imageIndex = sender.index
        
        let msg = "앨범을 선택하여 사진을 고를 수 있습니다."
        let alert = UIAlertController(title: "사진선택", message: msg, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel){
            (action : UIAlertAction) -> Void in
        }
        
        let selectAction = UIAlertAction(title: "앨범", style: .default){
            (action : UIAlertAction) -> Void in
            self.imagePicker()
            //확인 했을때 처리할 내용
        }
        
        let deleteAction = UIAlertAction(title: "사진삭제", style: .default){
            (action : UIAlertAction) -> Void in
            if self.imageList.count <= 1{
                ToastViewController.show(message: "사진은 1장 이상 등록필수입니다.", controller: self)
                //print("사진은 1장 이상 등록필수입니다.")
                return
            }
            self.deleteImage()
            //확인 했을때 처리할 내용
        }
        
        alert.addAction(cancelAction)
        alert.addAction(selectAction)
        if imageIndex! <= imageList.count-1{
            alert.addAction(deleteAction)
        }
        //이미지가 들어있지않을때는 이미지 삭제기능 띄우지 않는다.
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension myProfileController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "profileImageCell", for: indexPath) as! profileImageCell
        
        cell.userImageView.isUserInteractionEnabled = true
        let imageTap = imageTapGesture(target: self, action: #selector(showIndex(sender:)))
        imageTap.index = indexPath.row
        cell.userImageView.addGestureRecognizer(imageTap)
        cell.userImageView.layer.borderWidth = 0.5
        cell.userImageView.layer.borderColor = UIColor.lightGray.cgColor
        
        if indexPath.row > imageList.count-1{
            cell.userImageView.image = nil
            return cell
        }else{
            print(indexPath.row)
            cell.userImageView.image = imageList[indexPath.row]
        }
        
        return cell
    }
    
}

class profileImageCell:UICollectionViewCell{
    @IBOutlet weak var userImageView: UIImageView!
}

class imageTapGesture: UITapGestureRecognizer {
    var index:Int?
}
