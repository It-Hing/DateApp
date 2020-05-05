//
//  signUpController.swift
//  drink
//
//  Created by user on 02/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import CoreImage
import FirebaseStorage
import FirebaseDatabase

class signUpController:UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var useremailField: UITextField!
    @IBOutlet weak var userpwdField: UITextField!
    @IBOutlet weak var userphoneField: UITextField!
    
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!
        
    //var pnp:Bool = false
    var sexCheck:String?//0은 남자 1은 여자
    var isSelect:[Bool] = [false,false,false]//어떤 이미지뷰를 선택했는지 식별하기위해
    var isInput:[Bool] = [false,false,false]
    //이미지뷰에 이미지가 들어있는지 확인하기 위해(들어간것만 업로드)
    var imageCount = 0
    
    @IBOutlet var maleButton: UIButton!
    @IBOutlet var femaleButton: UIButton!
    
    
    @IBAction func maleButtonTapped(_ sender: Any) {
        femaleButton.backgroundColor = UIColor.white
        maleButton.backgroundColor = UIColor.blue
        sexCheck = "man"
    }
    
    @IBAction func femaleButtonTapped(_ sender: Any) {
        maleButton.backgroundColor = UIColor.white
        femaleButton.backgroundColor = UIColor.blue
        sexCheck = "woman"
    }
    
    //어떤 이미지뷰를 클릭했는지 확인하기 위해 이벤트 함수를 개별적으로 만들어줌
    @objc func firstImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        print("first")
        isSelect[0] = true
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func secondImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        print("second")
        isSelect[1] = true
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func thirdImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        print("third")
        isSelect[2] = true
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //스위치문으로 수정가능
            if isSelect[0] == true{
                firstImage.image = image
                isSelect[0] = false
                isInput[0] = true
            }else if isSelect[1] == true{
                secondImage.image = image
                isSelect[1] = false
                isInput[1] = true
            }else if isSelect[2] == true{
                thirdImage.image = image
                isSelect[2] = false
                isInput[2] = true
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //userFaceView.layer.cornerRadius = userFaceView.frame.height/2
        firstImage.isUserInteractionEnabled = true
        firstImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(firstImagePicker)))
        secondImage.isUserInteractionEnabled = true
        secondImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(secondImagePicker)))
        thirdImage.isUserInteractionEnabled = true
        thirdImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thirdImagePicker)))
        
        firstImage.tintColor = UIColor.white
        secondImage.tintColor = UIColor.white
        thirdImage.tintColor = UIColor.white
    }
    
    
    /*override func viewDidAppear(_ animated: Bool) {
        pnp = face_recognitionController.detect(img: userFaceView.image!, text: userFaceInfo)
    }*/
    
    override func viewDidLayoutSubviews() {
        firstImage.layer.cornerRadius = firstImage.frame.height/2
        secondImage.layer.cornerRadius = secondImage.frame.height/2
        thirdImage.layer.cornerRadius = thirdImage.frame.height/2
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        guard let username = usernameField.text,
        username != "",
        let email = useremailField.text,
        email != "",
        let password = userpwdField.text,
        password != "",
        let phonenumber = userphoneField.text,
        phonenumber != "",
        let sex = sexCheck
        else{
            print("양식에 맞게 입력해주세요.")
            return
        }
        //if pnp {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges { (error) in}//사용자프로필등록
                
                //let db = Firestore.firestore()  //firestore->realtime
                let db = Database.database().reference()
                let storage = Storage.storage()
                /*let storageRef = storage.reference().child("users").child(Auth.auth().currentUser!.uid).child("profileImage1.jpg")*/
                let storageRef = storage.reference().child("users").child(Auth.auth().currentUser!.uid)
                
                let firstUserImage = self.firstImage.image?.jpegData(compressionQuality: 0.1)
                let secondUserImage = self.secondImage.image?.jpegData(compressionQuality: 0.1)
                let thirdUserImage = self.thirdImage.image?.jpegData(compressionQuality: 0.1)
                
                db.child("users").child(Auth.auth().currentUser!.uid).setValue([
                    "username" : username,
                    "phonenumber" : phonenumber,
                    "photoURL" : "",
                    "sex" : sex
                    ],withCompletionBlock: {(err,ref) in
                       // self.dismiss(animated: true, completion: nil)
                })
                
                if self.isInput[0] == true{
                    storageRef.child("profileImage1.jpg").putData(firstUserImage!, metadata: nil, completion: { (data, error)in
                        if(error != nil){
                            print(error as Any)
                            return
                        }
                        // Fetch the download URL
                        storageRef.child("profileImage1.jpg").downloadURL { url, error in
                            
                            if let error = error {
                                print(error)
                                return
                            } else {
                                // Get the download URL
                                let imageUrl:String = (url?.absoluteString) ?? ""
                                //Url[0] = imageUrl
                                db.child("users").child(Auth.auth().currentUser!.uid).child("photoURL").updateChildValues(["first":imageUrl])
                            }
                        }
                    })
                }
                if self.isInput[1] == true{
                    storageRef.child("profileImage2.jpg").putData(secondUserImage!, metadata: nil, completion: { (data, error)in
                        if(error != nil){
                            print(error as Any)
                            return
                        }
                        // Fetch the download URL
                        storageRef.child("profileImage2.jpg").downloadURL { url, error in
                            
                            if let error = error {
                                print(error)
                                return
                            } else {
                                // Get the download URL
                                let imageUrl:String = (url?.absoluteString) ?? ""
                                //Url[1] = imageUrl
                                db.child("users").child(Auth.auth().currentUser!.uid).child("photoURL").updateChildValues(["second":imageUrl])

                            }
                        }
                    })
                }
                if self.isInput[2] == true{
                    storageRef.child("profileImage3.jpg").putData(thirdUserImage!, metadata: nil, completion: { (data, error)in
                        if(error != nil){
                            print(error as Any)
                            return
                        }
                        // Fetch the download URL
                        storageRef.child("profileImage3.jpg").downloadURL { url, error in
                            
                            if let error = error {
                                print(error)

                                return
                            } else {
                                // Get the download URL
                                let imageUrl:String = (url?.absoluteString) ?? ""
                                //Url[2] = imageUrl
                                db.child("users").child(Auth.auth().currentUser!.uid).child("photoURL").updateChildValues(["third":imageUrl])
                            }
                        }
                    })
                }
            }
        /*}else{
            print("사진이 올바르지 않습니다.\n")
        }*/
    }
}

/*db.collection("users").document(Auth.auth().currentUser!.uid).setData([
 "username": username,
 "phonenumber": phonenumber,
 "photoURL":imageUrl
 ])//유저의 데이터를 파베 문서로 저장 문서이름은 유저의 uid 값으로 지정*/ //firestore->realtime
