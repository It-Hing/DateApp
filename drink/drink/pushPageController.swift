//
//  pushPageController.swift
//  drink
//
//  Created by user on 02/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

struct push {
    var date:String?
    var uid:String?
    
    init() { }
    
    init(date: String, uid: String) {
        self.date = date
        self.uid = uid
    }
}

class pushPageController:UIViewController{
    
    let db = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var databaseRef_user:DatabaseReference?
    var observe_user:UInt?//채팅방에서 나갔을 때 더이상 디비를 참조하지 않기 위한 변수
    //var pushList:[String] = []
    var pushList:[push] = []
    //public var blockedList:Dictionary<String,Bool> = [:]

    //var usermodels:[userModel] = []
    var usermodels:[userModel] = []
    var tapIsPossible = false//채팅방을 누를 수 있도록 허용
    var default_image:UIImage?
    
    @IBOutlet weak var mentView: UIView!
    
    @IBOutlet weak var pushListCollectionView: UICollectionView!
    
    @IBOutlet weak var label_zeroRequest: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pushListCollectionView.delegate = self
        pushListCollectionView.dataSource = self
        
        navigationItem.hidesBackButton = true
        
        /*let backButton: UIBarButtonItem = UIBarButtonItem(title: "뒤로", style: UIBarButtonItem.Style.plain, target: self, action: #selector(backTapped))
        navigationItem.leftBarButtonItem = backButton*/
        
        label_zeroRequest.numberOfLines = 0
        tapIsPossible = false
        getPushList()
    }
    
    /*override func viewWillAppear(_ animated: Bool) {

        tapIsPossible = false
        getPushList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if databaseRef != nil{
            databaseRef?.removeAllObservers()
        }
    }*/
    
    /*@objc public func backTapped(){
        if databaseRef != nil{
            databaseRef?.removeAllObservers()
        }
        
        self.navigationController?.popViewController(animated: true)
    }*/
    
    public func getPushList(){
        databaseRef_user = db.child("users").child(uid!).child("pushList")
        observe_user = databaseRef_user!.observe(DataEventType.value, with: {(datasnapshot) in
            self.tapIsPossible = false
            self.pushList.removeAll()
            self.usermodels.removeAll()
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                /*let destinationUid = item.key
                print(item.key)
                self.pushList.append(destinationUid)*/
                var _push:push = push()
                var pushDate = String(describing: item.value!)

                _push.date = pushDate
                _push.uid = item.key
                
                self.pushList.append(_push)
            }
            
            var temp:push = push()
            
            print(self.pushList)
            
            if (self.pushList.count == 0){
                self.pushListCollectionView.reloadData()
                return
            }
            
            for i in 0..<(self.pushList.count-1){
                for j in (i+1)..<(self.pushList.count){
                    if((self.pushList[i].date!) < (self.pushList[j].date!)){
                        temp = self.pushList[i]
                        self.pushList[i] = self.pushList[j]
                        self.pushList[j] = temp
                    }
                }
            }
            
            print(self.pushList)
            self.pushListCollectionView.reloadData()
        })
    }
}

extension pushPageController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (pushList.count == 0){
            label_zeroRequest.text = "아직 대화요청이 없습니다.\n먼저 상대방에게 대화를 신청해보세요."
            label_zeroRequest.isHidden = false
            mentView.isHidden = true
        }else{
            label_zeroRequest.isHidden = true
            mentView.isHidden = false
        }
        return pushList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = pushListCollectionView.dequeueReusableCell(withReuseIdentifier: "pushPageCell", for: indexPath) as! pushPageCell
        let destinationUid = pushList[indexPath.row].uid
        
        if(default_image == nil){
            default_image = cell.userFaceView.image
        }
        
        cell.userFaceView.image = default_image

        /*db.child("users").child(destinationUid).observeSingleEvent(of: DataEventType.value,  with: { (DataSnapshot) in
            if !DataSnapshot.exists(){
                self.db.child("users").child(self.uid!).child("pushList").child(destinationUid).removeValue(completionBlock: { (err, ref) in
                })
                return
            }
            
            let usermodel = userModel(JSON: DataSnapshot.value as! [String:AnyObject])
            usermodel!.uid = destinationUid
            cell.userNameView.text = usermodel?.username
            //let temp_usermodel = usermodel
            //self.usermodels[indexPath.row] = usermodel!
            self.usermodels.append(usermodel!)
            
            let imageIndex = usermodel?.photo.keys.sorted()
            let url = URL(string:(usermodel!.photo[imageIndex![0]]!.temp!))
            
            cell.userFaceView.kf.setImage(with: url)
            if self.pushList.count == self.usermodels.count{
                self.tapIsPossible = true//채팅방을 누를 수 있도록 허용
            }
        })*/
        //let usermodel:userModel?
        db.child("users").child(destinationUid!).child("userName").observeSingleEvent(of: DataEventType.value,  with: { (DataSnapshot) in
            //삭제된 이용자의 경우 삭제
            if (!DataSnapshot.exists()){
                self.db.child("users").child(self.uid!).child("pushList").child(destinationUid!).removeValue()
                return
            }
                        
            let username = String(describing: DataSnapshot.value!)
            cell.userNameView.text = username
            
            self.db.child("users").child(destinationUid!).child("photo").observeSingleEvent(of: DataEventType.value,  with: { (DataSnapshot) in
                if !DataSnapshot.exists(){
                    
                }else{
                    for photo in DataSnapshot.children.allObjects as! [DataSnapshot]{
                        let data = photo.value
                        let mainPhoto = userModel.Photo(JSON: data as! [String: AnyObject])
                        
                        if(mainPhoto?.image != nil){
                            let url = URL(string: mainPhoto!.image!)
                            cell.userFaceView.kf.setImage(with: url)
                        }else{
                            cell.userFaceView.image = self.default_image
                        }
                        break
                        //첫번째 사진 하나만 받고 빠져나옴.
                    }
                }
                self.tapIsPossible = true
            })
        })
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date()
        let today = dateFormatter.string(from: date)
        
        let newToday = today.components(separatedBy: " ")
        let separatedToday = newToday[0].components(separatedBy: ".")
        
        let pushDate = pushList[indexPath.row].date
        let newDate = pushDate!.components(separatedBy: " ")
        let separatedDate = newDate[0].components(separatedBy: ".")
        
        if (newDate[0] == newToday[0]){
            let time = newDate[1].components(separatedBy: ":")
            if (Int(time[0])! > 12){
                cell.label_date.text = "오후 \(Int(time[0])!-12):\(time[1])"
            }else{
                cell.label_date.text = "오전 \(time[0]):\(time[1])"
            }
        }else if(separatedDate[0] == separatedToday[0] && separatedDate[1] == separatedToday[1] && Int(separatedToday[2])! - Int(separatedDate[2])! == 1){
            cell.label_date.text = "어제"
        }else{
            if(separatedDate[0] == separatedToday[0]){
                cell.label_date.text = separatedDate[1]+"월"+separatedDate[2]+"일"

            }else{
                cell.label_date.text = separatedDate[0]+"."+separatedDate[1]+"월"+separatedDate[2]+"일"
            }
        }
        
        //let myDate = separatedDate[0]+"."+separatedDate[1]+"월"+separatedDate[2]+"일"
        
        //cell.label_date.text = pushList[indexPath.row].date
        
        let cellRadius:CGFloat = 5.0

        cell.label_bg.layer.borderWidth = 0.5
        cell.label_bg.layer.borderColor = UIColor.lightGray.cgColor
        cell.label_bg.layer.cornerRadius = cellRadius
        cell.label_bg.layer.masksToBounds = true
        cell.userFaceView.layer.cornerRadius = cellRadius
        if #available(iOS 11.0, *) {
            cell.userFaceView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        //cell.userFaceView.roundCorners(corners:.allCorners,radius: cellRadius)
        cell.userFaceView.layer.masksToBounds = true
        cell.userFaceView.clipsToBounds = true
        cell.userFaceView.layer.borderWidth = 0.5
        cell.userFaceView.layer.borderColor = UIColor.lightGray.cgColor
        //cell.userNameView.layer.cornerRadius = cellRadius
        cell.userNameView.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = pushListCollectionView.frame.width/3-10
        let screenHeight = screenWidth+40
        return CGSize(width: screenWidth, height: screenHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if tapIsPossible == false{
            print("데이터가 아직 로드되지 않았습니다.")
            return
        }
        //guard let cell = pushListCollectionView.cellForItem(at: indexPath) as? pushPageCell else {return}

        let userInfoViewController = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
        //userInfoViewController.usermodel = usermodels[indexPath.row]
        userInfoViewController.prevPage = 2
        userInfoViewController.destinationUid = pushList[indexPath.row].uid
        userInfoViewController.modalPresentationStyle = .overCurrentContext
        userInfoViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(userInfoViewController, animated: true, completion: nil)
    }
}

class pushPageCell:UICollectionViewCell{
    @IBOutlet weak var userFaceView: UIImageView!
    @IBOutlet weak var userNameView: UILabel!
    @IBOutlet weak var label_bg: UILabel!
    var destinationUid:String?
    
    @IBOutlet weak var label_date: UILabel!
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
