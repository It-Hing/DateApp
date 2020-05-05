//
//  mapController.swift
//  drink
//
//  Created by user on 13/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Firebase
import Kingfisher

class mapController:UIViewController{
    let db = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    //var manusers:[userModel] = []
    //var womanusers:[userModel] = []
    //var users:[userModel] = []
    var myInfo:userModel?
    @IBOutlet var mapShowView: UIView!
    //@IBOutlet var authSwitch: UISwitch!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var label_blankMent: UILabel!
    @IBOutlet weak var constraintSearchBar: NSLayoutConstraint!
    @IBOutlet weak var constraintSearchOn: NSLayoutConstraint!
    @IBOutlet weak var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchConstraint: NSLayoutConstraint!
    @IBOutlet weak var serchBarHeight: NSLayoutConstraint!
    
    @IBOutlet weak var searchBarXCoor: NSLayoutConstraint!
    
    @IBOutlet weak var serachBtnXCoor: NSLayoutConstraint!
    @IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btn_refresh: UIButton!
    @IBOutlet weak var label_refreshbg: UILabel!
    @IBOutlet weak var label_searchbg: UILabel!
    
    var mapView:GMSMapView?
    var clusterManager: GMUClusterManager!
    var locationManager = CLLocationManager()
    var showStatus:Int = 0 //0=전체 1=남자 2=여자
    var isFisrt:Bool = true //맵 초기세팅을 위한 변수
    var clusterPeople:[userModel] = []
    var blockList:[String] = []//내가 차단한 사람들 목록
    var blockedList:[String] = []//나를 차단한 사람들 목록
    var myLocation:Bool?
    var mySex:String?
    //var myLocation:String?
    
    //블락리스트 옵저버 다루는 변수들
    var ref_blkList:DatabaseReference?
    var ref_blkedList:DatabaseReference?
    var observe_blk:UInt?
    var observe_blked:UInt?
    var default_image:UIImage?
    //
    var markerColor:UIColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(false, forKey: "myLocation")
        UserDefaults.standard.synchronize()
        
        //authCheckAndRemove(ment: "내위치를 업데이트하려면 위치정보를 새로 설정해주세요.")
        removeMyLocation()
        isFisrt = true
        
        markerColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        searchBar.delegate = self
        searchBar.isHidden = true
        searchBar.placeholder = "ex) 건대, 홍익대, 이태원, 강남"
        searchBar.showsScopeBar = false
        searchBar.scopeButtonTitles = nil
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.layer.cornerRadius = 10.0
        collectionView.layer.masksToBounds = true
        //collectionView.layer.borderWidth = 0.5
        //collectionView.layer.borderColor = UIColor.lightGray.cgColor
        
        mapShowView.layer.cornerRadius = 10.0
        mapShowView.layer.masksToBounds = true
        
        label_refreshbg.layer.cornerRadius = label_refreshbg.frame.height/2
        label_refreshbg.layer.masksToBounds = true
        label_searchbg.layer.cornerRadius = label_refreshbg.frame.height/2
        label_searchbg.layer.masksToBounds = true
        //navigationController?.navigationBar.isTranslucent = true
        //navigationController?.view?.backgroundColor = .clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        //let tabBarColor = UIColor(red: 192.0/255, green: 192.0/255, blue: 192.0/255, alpha: 1.0)
        //tabBarController?.tabBar.isTranslucent = false
        //tabBarController?.tabBar.unselectedItemTintColor = tabBarColor
        
        mapShowView.layer.borderColor = UIColor.lightGray.cgColor
        mapShowView.layer.borderWidth = 0.5
        
        //getBlockList()//해당 함수에서 getUsersLocation() 실행
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        //constraintSearchBar.constant = 0
        //mapViewTopConstraint.constant = 60
        if(searchConstraint.constant == view.frame.width-10){
            searchConstraint.constant = 56
            searchBarXCoor.constant = -35
            //serachBtnXCoor.constant = -35
            searchBar.isHidden = true
            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
        }else{
            searchBarXCoor.constant = 0
            //serachBtnXCoor.constant = -view.frame.width/2+35
            searchConstraint.constant = view.frame.width-10
            searchBar.isHidden = false
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
    
        searchBar.showsCancelButton = true
        //constraintSearchOn.constant = -1000
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //해당부분에서 지도설정값을 비교하여 지도를 업데이트할지 결정
        
        //myLocation = UserDefaults.standard.value(forKey: "myLocation") as? Bool
        
        var nowLocationAuth = UserDefaults.standard.value(forKey: "myLocation") as? Bool
        
        //////////////////////////////////////////////
        print("nowLocation: \(nowLocationAuth)")
        //////////////////////////////////////////////
        
        //앱을 깔고 처음 켜서 myLocation값이 없을 때 해당 조건문 실행됨
        if (nowLocationAuth == nil){
            UserDefaults.standard.set(false,forKey: "myLocation")
            UserDefaults.standard.synchronize()
            myLocation = nowLocationAuth
            getBlockList()
            return
        }
        
        if(myLocation != nil){
            /*if (myLocation != UserDefaults.standard.value(forKey: "myLocation") as? Bool){
                myLocation = UserDefaults.standard.value(forKey: "myLocation") as? Bool
                getBlockList()
                return
            }*/
            if (myLocation != nowLocationAuth){
                myLocation = nowLocationAuth
                getBlockList()
                return
            }
        }else{
            //처음실행은 아니고 앱을 켰을 때
            //UserDefaults.standard.set(false,forKey: "myLocation")
            //UserDefaults.standard.synchronize()
            //내위치에 대한 설정값이 없으면 기본값으로 꺼진값을 준다.
            //앱을 지우고 새로 깔았을 때 기본값으로 꺼진 값을 주기위해
            print("myLocation이 nil값을 가짐")
        }
        
        //남여전체에 대한 설정값이 없으면 기본값을 전체로 설정
        //값이 있으면 해당값대로 지도 업데이트

        if mySex == nil{
            //mySex != UserDefaults.standard.value(forKey: "sex") as? String
            if (UserDefaults.standard.value(forKey: "sex") == nil){
                UserDefaults.standard.set("전체", forKey: "sex")
                UserDefaults.standard.synchronize()
                mySex = "전체"
            }else{
                mySex = UserDefaults.standard.value(forKey: "sex") as? String
            }
            getBlockList()
            return
        }else{
            if (mySex != UserDefaults.standard.value(forKey: "sex") as? String){
                mySex = UserDefaults.standard.value(forKey: "sex") as? String
                getBlockList()
                return
            }
        }
    }
    
    @IBAction func renewLocationTapped(_ sender: Any) {
        //앱에대한 위치권한이 없다면 새로고침을 눌렀을 때 알림창을 띄운다.
        //앱내 지도설정에서 내위치권한을 껐다면 새로고침후 유저프로필을 볼 수 없도록 한다.
        let status = CLLocationManager.authorizationStatus()
        if (status != CLAuthorizationStatus.authorizedWhenInUse && status != CLAuthorizationStatus.authorizedAlways){
            showAuthAlert(ment: "환경설정에서 위치권한을 확인해주세요.")
        }
        self.clusterPeople.removeAll()
        collectionView.reloadData()
        btn_refresh.isEnabled = false
        getBlockList()
    }
    
    func showAuthAlert(ment:String){
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC =  storyBoard.instantiateViewController(withIdentifier: "alertViewController") as! alertViewController
        popupVC.okAction = getInAppLocationAuth
        popupVC.alertTitle = "위치정보"
        popupVC.alertContent = ment //
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
    }
    
    func getInAppLocationAuth(){
        //앱내 위치권한을 키기 위해서는 환경설정의 위치 권한을 가지고 있어야한다.
        let status = CLLocationManager.authorizationStatus()
        if (status != CLAuthorizationStatus.authorizedWhenInUse && status != CLAuthorizationStatus.authorizedAlways){
            btn_refresh.isEnabled = true
            return
        }else{
            UserDefaults.standard.set(true, forKey: "myLocation")
            UserDefaults.standard.synchronize()
            getBlockList()
        }
    }
    
    func getBlockList(){
        print("getBlockList")
        
        let auth = UserDefaults.standard.value(forKey: "myLocation")
        
        print(auth)
        /*if UserDefaults.standard.value(forKey: "myLocation") != nil{
            let myloc = UserDefaults.standard.value(forKey: "myLocation") as! Bool
            if myloc == false{
                clusterManager.clearItems()
                showAuthAlert()
                btn_refresh.isEnabled = true
                return
            }
        }*/

        ref_blkList = self.db.child("users").child(uid!).child("blockList")
        ref_blkedList = self.db.child("users").child(uid!).child("blockedList")
        
        if (observe_blk != nil){
            ref_blkList?.removeAllObservers()
        }
        if (observe_blked != nil){
            ref_blkedList?.removeAllObservers()
        }
        //이전에 있던 옵저버들을 모두 지워주고 새로운 옵저버를 등록해준다.
        
        observe_blk = ref_blkList?.observe(DataEventType.value, with: { (DataSnapshot) in
            self.observe_blked = self.ref_blkedList?.observe(DataEventType.value, with: { (datasnapshot) in
                self.db.child("users").child(self.uid!).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
                    let data = datasnapshot.value as! [String:AnyObject]
                    self.myInfo = userModel(JSON: data)
                    self.myInfo?.uid = datasnapshot.key
                    let imageIndex = self.myInfo?.photo.keys.sorted()
                    if self.myInfo?.photo.count != 0{
                        self.myInfo?.mainPhoto = self.myInfo?.photo[imageIndex![0]]!
                    }
                    self.locationManager.startUpdatingLocation()
                    self.getUsersLocation()
                })
            })
        })
    }
    
    
    func getUsersLocation(){
        //위치권한이 없는데 데이터를 가져오는 것을 방지
        let status = CLLocationManager.authorizationStatus()
        if (status != CLAuthorizationStatus.authorizedWhenInUse && status != CLAuthorizationStatus.authorizedAlways){
            //isFisrt = false
            return
        }
        
        //위치버튼의 정보를 받아옴 데이터가 없으면 True로 설정
        if UserDefaults.standard.value(forKey: "myLocation") != nil{
            myLocation = UserDefaults.standard.value(forKey: "myLocation") as? Bool
        }else{
            myLocation = true
        }
        
        if UserDefaults.standard.value(forKey: "sex") == nil{
            UserDefaults.standard.set("전체", forKey: "sex")
            UserDefaults.standard.synchronize()
        }
        
        if UserDefaults.standard.value(forKey: "sex") != nil{
            let selectSex = UserDefaults.standard.value(forKey: "sex") as! String
            
            //self.users.removeAll()
            if (clusterManager != nil){
                self.clusterManager.clearItems()
                //self.locationManager.startUpdatingLocation()
            }else{
                //self.locationManager.startUpdatingLocation()
                setDefaultLocation(auth: true)
            }
            
            presentMyMarker()//내위치찍기
            
            if selectSex == "전체"{
                getSeparatedUser(route: "man_location")
                getSeparatedUser(route: "woman_location")
            }else if (selectSex == "남자"){
                getSeparatedUser(route: "man_location")
            }else if (selectSex == "여자"){
                getSeparatedUser(route: "woman_location")
            }
            /*if self.myLocation == true{
                self.locationManager.startUpdatingLocation()
            }else{//내위치가 꺼져있다면
                //처음실행시나 위치갱신 버튼이 눌렷을 때 스위치가 꺼져있다면 해당 구문으로 들어옴
                //중간에 갑자기 위치 권한이 변경되었을 때 스위치가 껴져있어도 해당구문
                if (self.isFisrt == true){
                    self.isFisrt = false
                }
            }*/
        }
    }
    
    func getSeparatedUser(route:String?){
        
        db.child(route!).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            print("인원:\(datasnapshot.childrenCount)")
            if !datasnapshot.exists(){
                let selectSex = UserDefaults.standard.value(forKey: "sex") as! String
                self.clusterManager.cluster()

                if (route == "woman_location"){
                    self.btn_refresh.isEnabled = true
                }else{
                    if(selectSex == "남자"){
                        self.btn_refresh.isEnabled = true
                    }
                }
                return
            }
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                
                let data = item.value as! [String:AnyObject]
                let usermodel = userModel(JSON: data)
                usermodel!.uid = item.key
                self.db.child("users").child(usermodel!.uid!).child("photo").observeSingleEvent(of: DataEventType.value, with: {(dataSnapshot) in
                    
                    for photo in dataSnapshot.children.allObjects as! [DataSnapshot]{
                        let data = photo.value
                        usermodel?.mainPhoto = userModel.Photo(JSON: data as! [String: AnyObject])
                        break
                        //첫번째 사진 하나만 받고 빠져나옴.
                    }
                                        
                    if usermodel!.uid == self.uid!{
                        if self.myLocation == true{
                        }
                    }else{
                        //self.users.append(usermodel!)
                        if self.myInfo!.blockList.keys.contains(item.key){
                            print("내가 차단한 사람: \(item.key)")
                        }else if self.myInfo!.blockedList.keys.contains(item.key){
                            print("나를 차단한 사람: \(item.key)")
                        }else{
                            let position = CLLocationCoordinate2D(latitude:usermodel!.latitude!, longitude: usermodel!.longitude!)
                            
                            print("마커 생성")
                            let marker = POIItem(position:position, data: usermodel!)
                            self.clusterManager.add(marker)
                            self.clusterManager.cluster()
                        }
                    }
                    
                    if(item.key == (datasnapshot.children.allObjects.last as! DataSnapshot).key){
                        let selectSex = UserDefaults.standard.value(forKey: "sex") as! String
                        
                        print(selectSex)

                        if (route == "woman_location"){
                            self.btn_refresh.isEnabled = true
                        }else{
                            if(selectSex == "남자"){
                                self.btn_refresh.isEnabled = true
                            }
                        }
                    }
                })
            }
        })
    }
    
    func setDefaultLocation(auth:Bool){
        print("setdefaultlocation")
        
        var location:CLLocationCoordinate2D?
        if auth == true{
            location = locationManager.location?.coordinate
        }else{
            //강남역
            location = CLLocationCoordinate2D(latitude: 37.49794199999999, longitude: 127.02762099999995)
        }
        
        var camera:GMSCameraPosition?
        
        if (location != nil){
            camera = GMSCameraPosition.camera(withLatitude:location!.latitude, longitude: location!.longitude, zoom: 14.0)
        }else{
            //위치를 못잡아오는 경우 예외처리(종종 발생하는 버그 -> 앱종료)
            location = CLLocationCoordinate2D(latitude: 37.49794199999999, longitude: 127.02762099999995)
            camera = GMSCameraPosition.camera(withLatitude:location!.latitude, longitude: location!.longitude, zoom: 14.0)
        }
        
        mapView = GMSMapView.map(withFrame: CGRect(x: 0,y: 0,width: mapShowView.frame.width,height: mapShowView.frame.height), camera: camera!)
        mapShowView.addSubview(mapView!)
        mapView?.delegate = self
        mapView?.setMinZoom(0.0, maxZoom: 15.0)
        //지도 확대범위 설정
        
        /*print("setdefaultlocation")
        let location = locationManager.location?.coordinate
        let camera = GMSCameraPosition.camera(withLatitude:location!.latitude, longitude: location!.longitude, zoom: 5.0)
        
        mapView = GMSMapView.map(withFrame: CGRect(x: 0,y: 0,width: mapShowView.frame.width,height: mapShowView.frame.height), camera: camera)
        mapShowView.addSubview(mapView!)
        mapView?.delegate = self*/
        
        //let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //view!.addGestureRecognizer(tap)
        
        createCluster()
    }
    
    @objc func dismissKeyboard(){
       view.endEditing(true)
    }
    
    func createCluster(){
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        
        //let iconGenerator = MapClusterIconGenerator()
        let purple = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        let iconGenerator = GMUDefaultClusterIconGenerator(buckets: [10,20,50,100,200,500], backgroundColors: [purple,purple,purple,purple,purple,purple])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!,clusterIconGenerator: iconGenerator)
        renderer.delegate = self

        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm,
                                           renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        // Call cluster() after items have been added to perform the clustering
        // and rendering on map.
        //clusterManager.cluster()
    }
    
    func presentMyMarker(){
        print("내 마커 찍기")
        //스위치가 켜져있는 상태에서만 내위치를 보여줌, 수정하면 남에겐 보이지않고 나만 내위치를 보는 것도 가능
        myLocation = UserDefaults.standard.value(forKey: "myLocation") as? Bool

        if(myLocation == true){
            let location = locationManager.location?.coordinate
            //위치를 받아오지 못하는 경우 앱종료 방지를 위해 리턴
            if (location == nil){
                return
            }
            let latitude = location!.latitude
            let longitude = location!.longitude
            myInfo?.latitude = latitude
            myInfo?.longitude = longitude
            UserDefaults.standard.set(latitude, forKey: "latitude")
            UserDefaults.standard.set(longitude, forKey: "longitude")
            UserDefaults.standard.synchronize()
            
            let camera = GMSCameraPosition.camera(withLatitude:latitude, longitude: longitude, zoom: 14.0)
            self.mapView?.camera = camera//카메라를 내위치로 이동
            let position = CLLocationCoordinate2D(latitude:latitude, longitude: longitude)

            print("내마커 생성")
            let marker = POIItem(position:position, data: myInfo!)
            clusterManager.add(marker)
        }else{
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)//키보드가 나타나는 동작 등록
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)//키보드가 사라지는 동작 등록
    }
    
    @objc func keyboardWillShow(notification: Notification){
        if let keyboardSize = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            searchBarBottomConstraint.constant = keyboardSize.height+20
            //채팅텍스트 필드와 전송버튼의 위치변경 (키보드 높이만큼)
        }
        
        //키보드는 자동으로 에니메이션 효과가 있지만 버튼과 텍스트 필드는 그렇지 않다.
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }, completion: {(completion) in

        })
    }
    
    @objc func keyboardWillHide(notification:Notification){
        searchBarBottomConstraint.constant = 30
        self.view.layoutIfNeeded()
    }
    
    func authCheckAndRemove(ment:String?){
        //앱 자체에 대한 위치 권한이 꺼졌을 때 동작
        //앱내 지도설정에서 내위치를 꺼준다.
        //db에서 내위치 정보를 삭제한다.
        
        //showAuthAlert(ment: "환경설정에서 위치권한을 켜주세요.")
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let popupVC =  storyBoard.instantiateViewController(withIdentifier: "simpleAlertViewController") as! simpleAlertViewController
        popupVC.alertTitle = "위치정보"
        popupVC.alertContent =  ment
        popupVC.modalPresentationStyle = .overCurrentContext
        popupVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(popupVC, animated: true, completion: nil)
                
        removeMyLocation()
    }
    
    func removeMyLocation(){
        UserDefaults.standard.set(false, forKey: "myLocation")
        UserDefaults.standard.synchronize()//값을 넣은 후 바로 동기화
        
        self.locationManager.startUpdatingLocation()
        setDefaultLocation(auth: false)
        
        if myInfo != nil{
            if myInfo?.sex == "남자"{
                self.db.child("man_location").child(uid!).removeValue()
            }else{
                self.db.child("woman_location").child(uid!).removeValue()
            }
        }else{
            self.db.child("users").child(uid!).child("sex").observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
                let sex = String(describing: datasnapshot.value!)
                
                if sex == "남자"{
                    self.db.child("man_location").child(self.uid!).removeValue()
                }else{
                    self.db.child("woman_location").child(self.uid!).removeValue()
                }
            })
        }
    }
    
}



extension mapController:CLLocationManagerDelegate{
    //startUpdatelocation()메소드 실행시 자동으로 실행되는 메소드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("위치 업데이트")

        let status = CLLocationManager.authorizationStatus()
        if (status != CLAuthorizationStatus.authorizedWhenInUse && status != CLAuthorizationStatus.authorizedAlways){
            return
        }
        
        /*if(isFisrt == true){
            isFisrt = false
        }*/
        
        myLocation = UserDefaults.standard.value(forKey: "myLocation") as? Bool
        
        if self.myLocation == false{
            locationManager.stopUpdatingLocation()
            return
        }
        
        //내위치를 서버에 전송
        let location: CLLocation = locations.last!
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        let locationDic:Dictionary<String,Any> = [
            "latitude":latitude,
            "longitude":longitude,
            "userName":myInfo?.username as Any
        ]
        
        var myGender:String?
        
        if myInfo!.sex == "남자"{
            myGender = "man_location"
        }else if myInfo?.sex == "여자"{
            myGender = "woman_location"
        }
        
        db.child(myGender!).child(uid!).updateChildValues(locationDic, withCompletionBlock: {(err, ref) in
        })
        
        locationManager.stopUpdatingLocation()
        //동작을 마친 후 위치 업데이트를 끝낸다. -> 실시간으로 위치를 받아오지 않기위해
    }
    
    //위치권한이 변경되었을 때를 감지하여 나타나는 메소드
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted:
            authCheckAndRemove(ment: "환경설정에서 위치권한을 켜주세요.")
            break
        case .denied:
            authCheckAndRemove(ment: "환경설정에서 위치권한을 켜주세요.")
            break
        case .notDetermined:
            authCheckAndRemove(ment: "환경설정에서 위치권한을 켜주세요.")
            break
        case .authorizedAlways:
            if isFisrt == true{
                isFisrt = false
                showAuthAlert(ment: "앱을 새로 실행하면 새로운 위치설정이 필요합니다\n확인을 누르시면 위치가 업데이트됩니다.")
                break
            }
            getBlockList()
            break
        case .authorizedWhenInUse:
            if isFisrt == true{
                isFisrt = false
                showAuthAlert(ment: "앱을 새로 실행하면 새로운 위치설정이 필요합니다\n확인을 누르시면 위치가 업데이트됩니다.")
                break
            }
            getBlockList()
            break
        @unknown default:
            //현재는 발생하지 않을 예외
            print("default")
        }
    }
}

extension mapController:GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        if UserDefaults.standard.value(forKey: "myLocation") != nil{
            let myloc = UserDefaults.standard.value(forKey: "myLocation") as! Bool
            if myloc == false{
                showAuthAlert(ment: "상대방 정보를 확인하려면 내위치를 켜야합니다.\n확인을 누르시면 내 위치가 켜집니다.")
                btn_refresh.isEnabled = true
                return true
            }
        }
        
        //marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        //marker.icon?.maskWithColor(color: .blue)
        let poiItem = marker.userData as? POIItem
        
        if myInfo != nil{
            if poiItem!.data!.uid == myInfo!.uid{
                //print("나를 클릭")
                let myInfoView = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
                myInfoView.prevPage = 3
                
                self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                self.navigationController?.modalPresentationStyle = .currentContext
                myInfoView.modalPresentationStyle = .overCurrentContext
                myInfoView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                self.present(myInfoView, animated: true, completion: nil)
                return true
            }
        }
        
        let myLoc = CLLocation(latitude: myInfo!.latitude!, longitude: myInfo!.longitude!)
        let destinationLoc = CLLocation(latitude: (poiItem?.data!.latitude)!, longitude: (poiItem?.data!.longitude)!)
        
        var distance = myLoc.distance(from: destinationLoc)
        
        var newDistance:String?
        
        if (distance > 1000){
            distance = distance / 1000
            distance = distance.rounded()
            newDistance = "거리 \(Int(distance))km"
        }else{
            newDistance = "거리 0km"
        }
        //print(newDistance)
        
        //print(poiItem!.data!.username)
        let userInfoViewController = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
        //userInfoViewController.usermodel = marker.userData as? userModel
        //userInfoViewController.usermodel = poiItem?.data
        userInfoViewController.destinationUid = poiItem!.data?.uid
        userInfoViewController.prevPage = 1
        userInfoViewController.distance = newDistance
        userInfoViewController.modalPresentationStyle = .overCurrentContext
        userInfoViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(userInfoViewController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(userInfoViewController, animated: true)
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

extension mapController:GMUClusterManagerDelegate{
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        
        print("tap cluster")
        //let user = cluster.items as! [POIItem]
        let user = cluster.items as! [POIItem]
        clusterPeople.removeAll()
        for item in user{
            //print(item.data?.username!)
            clusterPeople.append((item.data)!)
        }
        collectionView.reloadData()
        return true
    }
}

extension mapController:UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
        let key = URLQueryItem(name: "key", value: "AIzaSyCU1YXfmAgNLY8k0GoGMLO0Xl5Llpa9f_Y")
        //ios키가 아니라 server key를 입력해야 동작함
        let address = URLQueryItem(name: "address", value: searchBar.text)
        components.queryItems = [key, address]
        
        let task = URLSession.shared.dataTask(with: components.url!) { data, response, error in
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print(String(describing: response))
                print(String(describing: error))
                return
            }
            
            guard let json = try! JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("not JSON format expected")
                print(String(data: data, encoding: .utf8) ?? "Not string?!?")
                return
            }
            
            guard let results = json["results"] as? [[String: Any]],
                let status = json["status"] as? String,
                status == "OK" else {
                    print("no results")
                    print(String(describing: json))
                    return
            }
            
            let geometry = results[0]["geometry"] as! [String:AnyObject]
            let location = geometry["location"] as! [String:Double]
            let lat = location["lat"]
            let lng = location["lng"]
            let camera = GMSCameraPosition.camera(withLatitude:lat!, longitude: lng!, zoom: 15.0)
            
            //맵뷰에 카메라 적용하는 부분은 메인스레드에서만 가능하므로 동기화필요(검색해보기)
            DispatchQueue.main.async{
                self.mapView?.camera = camera
                searchBar.showsCancelButton = true
                self.view.endEditing(true)
            }
        }
        task.resume()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //서치바에서 취소 클릭시 키보드 들어가게 하기
        searchConstraint.constant = 56
        searchBarXCoor.constant = -35
        serachBtnXCoor.constant = -35
        searchBar.isHidden = true
        
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
        
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = true
        //constraintSearchBar.constant = 0
        //mapViewTopConstraint.constant = 60
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //mapViewTopConstraint.constant = 5
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
        //constraintSearchBar.constant = -view.frame.width
        //constraintSearchOn.constant = 5
    }
}

extension mapController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("생성")
        if clusterPeople.count>0{
            label_blankMent.isHidden = true
        }else{
            label_blankMent.isHidden = false
        }
        return clusterPeople.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("셀생성")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! collectionViewCell
        //print(clusterPeople[indexPath.row].photo.count)
        
        //let image = UIImage(named: "사용자사진.png")
        //let image = UIImage(named: "사용자사진.png", in: Bundle(identifier: "com.sinabro.drink"), compatibleWith: nil)
        if(default_image == nil){
            default_image = cell.userFaceView.image
        }

        if(clusterPeople[indexPath.row].mainPhoto != nil){
            if (clusterPeople[indexPath.row].mainPhoto!.image != nil){
                let url = URL(string:(clusterPeople[indexPath.row].mainPhoto!.image)!)
                cell.userFaceView.kf.setImage(with:url)
            }else{
                print("이미지 없음")
                //print(image)
                cell.userFaceView.image = default_image
                //url = URL(string:(clusterPeople[indexPath.row].mainPhoto!.temp)!)
            }
        }else{
            print("메인포토 없음")
            cell.userFaceView.image = default_image
        }
        
        //cell.userFaceView
        cell.userFaceView.layer.cornerRadius = (cell.userFaceView.frame.width)/2
        cell.userFaceView.layer.masksToBounds = true
        //cell.userFaceView.layer.borderColor = UIColor.lightGray.cgColor
        //cell.userFaceView.layer.borderWidth = 1.0
        
        cell.imageView_bg.layer.cornerRadius = (cell.imageView_bg.frame.width)/2
        //cell.label_bg.layer.cornerRadius = collectionView.frame.width/2
        cell.imageView_bg.layer.masksToBounds = true
        
        //cell.label_userName.text = clusterPeople[indexPath.row].username
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if UserDefaults.standard.value(forKey: "myLocation") != nil{
            let myloc = UserDefaults.standard.value(forKey: "myLocation") as! Bool
            if myloc == false{
                //clusterManager.clearItems()
                showAuthAlert(ment: "상대방 정보를 확인하려면 내위치를 켜야합니다.\n확인은 누르시면 내위치가 켜집니다.")
                btn_refresh.isEnabled = true
                return
            }
        }
        
        //클릭한 사람이 자신이었을 때
        if clusterPeople[indexPath.row].uid == Auth.auth().currentUser?.uid{
            let myInfoView = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
            myInfoView.prevPage = 3
            
            self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.navigationController?.modalPresentationStyle = .currentContext
            myInfoView.modalPresentationStyle = .overCurrentContext
            myInfoView.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(myInfoView, animated: true, completion: nil)
            return
        }
        
        let myLoc = CLLocation(latitude: myInfo!.latitude!, longitude: myInfo!.longitude!)
        let destinationLoc = CLLocation(latitude: (clusterPeople[indexPath.row].latitude)!, longitude: (clusterPeople[indexPath.row].longitude)!)
        
        var distance = myLoc.distance(from: destinationLoc)
        
        var newDistance:String?
        
        if (distance > 1000){
            distance = distance / 1000
            distance = distance.rounded()
            newDistance = "거리 \(Int(distance))km"
        }else{
            newDistance = "거리 0km"
        }

        
        let userInfoViewController = storyboard?.instantiateViewController(withIdentifier: "userInfoViewController") as! userInfoViewController
        userInfoViewController.navigationItem.title = clusterPeople[indexPath.row].username
        //userInfoViewController.usermodel = clusterPeople[indexPath.row]
        userInfoViewController.destinationUid = clusterPeople[indexPath.row].uid
        userInfoViewController.prevPage = 1
        userInfoViewController.distance = newDistance
        userInfoViewController.modalPresentationStyle = .overCurrentContext
        userInfoViewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(userInfoViewController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(userInfoViewController, animated: true)
    }
}

extension mapController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        //marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        marker.groundAnchor = CGPoint(x: 0.5, y: 1)
        if  let markerData = (marker.userData as? POIItem) {
            if markerData.data?.uid == myInfo?.uid{
                
            }else{
                marker.icon = GMSMarker.markerImage(with: markerColor)
            }
        }
    }
}

/*class CustomClusterRenderer: GMUClusterRendererDelegate {
    
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        
        marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        //marker.icon?.maskWithColor(color: .blue)
        //let poiItem = marker.userData as? POIItem
        
        /*if let image = UIImage(named: "marker") {
            //marker.iconView = UIImageView(image: image, highlightedImage: nil)
        }*/
    }
}*/

//클러스터에 추가할 마커를 위한 클래스
class POIItem:NSObject, GMUClusterItem{
    var position: CLLocationCoordinate2D
    var data:userModel?
    
    init(position:CLLocationCoordinate2D, data:userModel){
        self.position = position
        self.data = data
    }
}
