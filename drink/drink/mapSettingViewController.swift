//
//  mapSettingViewController.swift
//  drink
//
//  Created by user on 06/11/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FirebaseDatabase
import FirebaseAuth

class mapSettingViewController:UIViewController{
    
    @IBOutlet weak var locSwitch: UISwitch!
    let db = Database.database().reference()
    
    @IBOutlet weak var label_myLocation: UILabel!
    @IBOutlet weak var label_myLocationShadow: UILabel!
    
    @IBOutlet weak var label_allShow: UILabel!
    @IBOutlet weak var label_manShow: UILabel!
    @IBOutlet weak var label_womanShow: UILabel!
    
    @IBOutlet weak var label_allShowBg: UILabel!
    @IBOutlet weak var label_manShowBg: UILabel!
    @IBOutlet weak var label_womanShowBg: UILabel!
    
    @IBOutlet weak var btn_allShow: UIButton!
    @IBOutlet weak var btn_manShow: UIButton!
    @IBOutlet weak var btn_womanShow: UIButton!
    
    var check:UIImage?
    var uncheck:UIImage?
    
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
        }else{
            let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            if statusBar!.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar!.backgroundColor = UIColor(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }
        
        if UserDefaults.standard.value(forKey: "myLocation") != nil{
            locSwitch.isOn = UserDefaults.standard.value(forKey: "myLocation") as! Bool
        }else{
            locSwitch.isOn = true
        }
        
        //baseline_check_box_black_24pt 체크표시된 이미지
        //baseline_check_box_outline_blank_black_24pt 체크표시안된 이미지
        
        check = UIImage(named: "baseline_check_box_black_24pt")
        uncheck = UIImage(named: "baseline_check_box_outline_blank_black_24pt")

        if UserDefaults.standard.value(forKey: "sex") != nil{
            let sex = UserDefaults.standard.value(forKey: "sex") as! String
            if (sex == "전체"){
                btn_allShow.setImage(check, for: UIControl.State.normal)
            }else if(sex == "남자"){
                btn_manShow.setImage(check, for: UIControl.State.normal)
            }else{
                btn_womanShow.setImage(check, for: UIControl.State.normal)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        drawShadow(settingLabel: label_myLocationShadow, bg: label_myLocation)
        drawShadow(settingLabel: label_allShow, bg: label_allShowBg)
        drawShadow(settingLabel: label_manShow, bg: label_manShowBg)
        drawShadow(settingLabel: label_womanShow, bg: label_womanShowBg)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.barStyle = .default
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.tintColor = .darkGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)
    }
    
    func drawShadow(settingLabel:UILabel, bg:UILabel){
        settingLabel.layer.cornerRadius = 10

        settingLabel.layer.masksToBounds = true
        
        //label_myLocation.layer.cornerRadius = 10
        let shadowPath = UIBezierPath(roundedRect: label_myLocation.bounds, cornerRadius: 10)
        bg.layer.masksToBounds = false
        bg.layer.shadowRadius = 10.0
        bg.layer.shadowColor = UIColor.black.cgColor
        bg.layer.shadowOffset = CGSize(width: 1, height: 1)
        bg.layer.shadowOpacity = 0.2
        bg.layer.shadowPath = shadowPath.cgPath//그림자 넣기
    }
    
    @IBAction func myLocationTapped(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid
        if locSwitch.isOn == false{
            UserDefaults.standard.set(locSwitch.isOn, forKey: "myLocation")
            UserDefaults.standard.synchronize()//값을 넣은 후 바로 동기화
            db.child("users").child(uid!).child("sex").observeSingleEvent(of:DataEventType.value,with: {(datasnapshot) in
                let sex = String(describing: datasnapshot.value!)
                if sex == "남자"{
                    self.db.child("man_location").child(uid!).removeValue()
                }else{
                    self.db.child("woman_location").child(uid!).removeValue()
                }
            })
        }else{
            let status = CLLocationManager.authorizationStatus()
            if (status != CLAuthorizationStatus.authorizedWhenInUse && status != CLAuthorizationStatus.authorizedAlways){
                
                locSwitch.isOn = false
                let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
                let popupVC = storyBoard.instantiateViewController(withIdentifier: "simpleAlertViewController") as! simpleAlertViewController
                popupVC.alertTitle = "위치정보"
                popupVC.alertContent = "환경설정에서 위치권한을 확인해주세요."
                popupVC.modalPresentationStyle = .overCurrentContext
                popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                self.present(popupVC, animated: true, completion: nil)
                
                return
            }
            UserDefaults.standard.set(locSwitch.isOn, forKey: "myLocation")
            UserDefaults.standard.synchronize()//값을 넣은 후 바로 동기화
            print("권한 버튼 눌림->새로 맵을 받아옴")
        }
    }
    
    @IBAction func allShowTapped(_ sender: Any) {
        UserDefaults.standard.set("전체", forKey: "sex")
        UserDefaults.standard.synchronize()
        btn_allShow.setImage(check, for: UIControl.State.normal)
        btn_manShow.setImage(nil, for: UIControl.State.normal)
        btn_womanShow.setImage(nil, for: UIControl.State.normal)
    }
    
    @IBAction func manShowTapped(_ sender: Any) {
        UserDefaults.standard.set("남자", forKey: "sex")
        UserDefaults.standard.synchronize()
        btn_manShow.setImage(check, for: UIControl.State.normal)
        btn_allShow.setImage(nil, for: UIControl.State.normal)
        btn_womanShow.setImage(nil, for: UIControl.State.normal)
    }
    
    @IBAction func womanShowTapped(_ sender: Any) {
        UserDefaults.standard.set("여자", forKey: "sex")
        UserDefaults.standard.synchronize()
        btn_womanShow.setImage(check, for: UIControl.State.normal)
        btn_allShow.setImage(nil, for: UIControl.State.normal)
        btn_manShow.setImage(nil, for: UIControl.State.normal)
    }
}

















//let uuid = UUID().uuidString

//let uuid = NSUUID().uuidString

/*let uuid = UIDevice.current.identifierForVendor?.uuidString
 print(uuid)
 
 var separatedUuid = uuid!.split(separator: "-")
 
 var newUuid:String = ""
 
 for item in separatedUuid{
 newUuid = newUuid + item
 }
 
 print(newUuid)*/


/*let dateFormatter = DateFormatter()
 dateFormatter.locale = Locale(identifier: "ko_KR")
 dateFormatter.dateFormat = "yyyy.MM.dd"
 let date = Date()
 let keychainValue = dateFormatter.string(from: date)
 
 let save = KeychainWrapper.standard.set("2018.11.", forKey: "keychain")
 print(save)
 let saveData = KeychainWrapper.standard.string(forKey: "keychain")*/


/*let saveData = "2019.12.02"
 let keychainValue = "2020.01.01"
 let separatedData = saveData.split(separator: ".")
 let separatedToday = keychainValue.split(separator: ".")
 
 let year2 = Int(separatedData[0])!
 let year1 = Int(separatedToday[0])!
 
 let month2 = Int(separatedData[1])!
 let month1 = Int(separatedToday[1])!
 
 let day2 = Int(separatedData[2])!
 let day1 = Int(separatedToday[2])!
 
 
 if (year1 - year2 >= 2){
 //2년이상 차이날때 -> 패스
 print("2년 이상 지남")
 }else if (year1 - year2 == 1){
 //연도가 1년 차이나는 경우
 if(month1-month2 < 0){
 //1년이 덜 지난 경우
 if(month1 + (12 - month2) <= 1){
 //연도는 바뀌었지만 한달이 채 지나지 않은 경우 -> 회원가입불가
 if(day1-day2 < 0){
 //30일 차이가 나지 않는 경우 -> 회원가입불가
 print("연도는 바뀌었지만 한달이 채 지나지 않은 경우 회원가입불가")
 }else{
 //딱 한달 지났거나 한달이 넘은 경우 -> 패스
 }
 }else{
 //연도가 바뀌고 두달이상 지난경우 -> 패스
 }
 }else{
 //1년이 넘었거나 딱1년 된 경우 -> 패스
 }
 }else{
 //연도가 1년도 차이나지 않는 경우
 if(month1-month2 >= 2){
 //2달이 넘은 경우 -> 패스
 }else if(month1 - month2 == 1){
 //1달 차이가 나는 경우
 if(day1-day2 < 0){
 //30일 차이가 나지 않는 경우 -> 회원가입불가
 print("1달 지났지만 30일 차이가 나지 않는 경우 회원가입불가")
 }else{
 //딱 한달 지났거나 한달이 넘은 경우 -> 패스
 }
 }else{
 //1달도 차이가 나지 않는경우
 if(day1-day2 > 30){
 //날짜가 30일 지난 경우 ->패스
 }else{
 //30일이 지나지 않은 경우 -> 회원가입불가
 print("30일이 지나지 않은 경우 ->회원가입불가")
 }
 }
 }
 
 KeychainWrapper.standard.removeObject(forKey: "blockSignUp")
 let Data = KeychainWrapper.standard.string(forKey: "keychain")
 print(Data)*/





/*let db = Database.database().reference()
 let uid = Auth.auth().currentUser!.uid
 
 db.child("users").queryOrdered(byChild: "tall").queryEqual(toValue: "168cm").observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
 
 print(dataSnapshot.value)
 })*/






/*(id)init{
 return [self initWithDelegate:nil];
 }
 
 (id)initWithDelegate:(id<CBeaconBroadcastDelegate>)delegate{
 self = [super init];
 if (self) {
 self.peripheral = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
 self.delegate = delegate;
 }
 return self;
 }*/
