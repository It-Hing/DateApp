//
//  myPageController.swift
//  drink
//
//  Created by user on 30/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Firebase
import CoreImage
import FirebaseStorage

class myPageController:UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    @IBOutlet weak var myPageTableView: UITableView!
    let db = Database.database().reference()
    var usermodel:userModel?
    let storage = Storage.storage()
    var tempImage:UIImage? = nil //처음엔 널 값이고 변경하면 데이터가 들어간다.
    var isSelect:[Bool] = [false,false,false]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //myPageTableView.delegate = self
        //myPageTableView.dataSource = self
    }
    
    @objc func firstImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        isSelect[0] = true
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func secondImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        isSelect[1] = true
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func thirdImagePicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        isSelect[2] = true
        //이미지 픽커 보여주기
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //서버에 이미지를 저장한 후 테이블뷰 리로드
            //print("in imagePickerController")
            tempImage = image
            self.myPageTableView.reloadData()
            
            if isSelect[0] == true{
                let storageRef = storage.reference().child("users").child(Auth.auth().currentUser!.uid).child("profileImage1.jpg")
                let userimage = image.jpegData(compressionQuality: 0.1)

                storageRef.putData(userimage!, metadata: nil, completion: { (data, error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    //print("in putData")
                    storageRef.downloadURL { url, error in
                        if error != nil{
                            print(error as Any)
                            return
                        }
                        //print(url)
                        //print("in downloadURL")
                        let imageUrl:String = (url?.absoluteString) ?? ""
                        self.db.child("users").child((Auth.auth().currentUser?.uid)!).child("photoURL").updateChildValues(["first":imageUrl], withCompletionBlock: { (err, ref) in
                            //self.myPageTableView.reloadData()
                            print("첫번째 사진변경완료")
                            self.isSelect[0] = false
                        })
                    }
                })
            }
            if isSelect[1] == true{
                let storageRef = storage.reference().child("users").child(Auth.auth().currentUser!.uid).child("profileImage2.jpg")
                let userimage = image.jpegData(compressionQuality: 0.1)

                storageRef.putData(userimage!, metadata: nil, completion: { (data, error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    //print("in putData")
                    storageRef.downloadURL { url, error in
                        if error != nil{
                            print(error as Any)
                            return
                        }
                        //print(url)
                        //print("in downloadURL")
                        let imageUrl:String = (url?.absoluteString) ?? ""
                        self.db.child("users").child((Auth.auth().currentUser?.uid)!).child("photoURL").updateChildValues(["second":imageUrl], withCompletionBlock: { (err, ref) in
                            //self.myPageTableView.reloadData()
                            print("두번째 사진변경완료")
                            self.isSelect[1] = false
                        })
                    }
                })
            }
            if isSelect[2] == true{
                let storageRef = storage.reference().child("users").child(Auth.auth().currentUser!.uid).child("profileImage3.jpg")
                let userimage = image.jpegData(compressionQuality: 0.1)

                storageRef.putData(userimage!, metadata: nil, completion: { (data, error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    //print("in putData")
                    storageRef.downloadURL { url, error in
                        if error != nil{
                            print(error as Any)
                            return
                        }
                        //print(url)
                        //print("in downloadURL")
                        let imageUrl:String = (url?.absoluteString) ?? ""
                        self.db.child("users").child((Auth.auth().currentUser?.uid)!).child("photoURL").updateChildValues(["third":imageUrl], withCompletionBlock: { (err, ref) in
                            //self.myPageTableView.reloadData()
                            print("세번째 사진변경완료")
                            self.isSelect[2] = false
                        })
                    }
                })
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension myPageController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = myPageTableView.dequeueReusableCell(withIdentifier: "myPageFirstCell", for: indexPath) as! myPageFirstCell
            return cell
        }
        else {
            let cell = myPageTableView.dequeueReusableCell(withIdentifier: "myPageSecondCell", for: indexPath) as! myPageSecondCell
            //getMyInfo()

            cell.firstImageView.tintColor = UIColor.white
            cell.secondImageView.tintColor = UIColor.white
            cell.thirdImageView.tintColor = UIColor.white
            
            cell.firstImageView.isUserInteractionEnabled = true
            cell.firstImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(firstImagePicker)))
            cell.secondImageView.isUserInteractionEnabled = true
            cell.secondImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(secondImagePicker)))
            cell.thirdImageView.isUserInteractionEnabled = true
            cell.thirdImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thirdImagePicker)))
            
            //db.child("users").child(Auth.auth().currentUser!.uid).remove
            
            if tempImage == nil{
                db.child("users").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
                    self.usermodel = userModel(JSON: DataSnapshot.value as! [String:AnyObject])
                    //let url = URL(string:self.usermodel!.photoURL!)
                    //self.firstImageView.kf.setImage(with:url)
                    /*if let firstUrl = URL(string: self.usermodel!.photo["first"]!){
                        cell.firstImageView.kf.setImage(with: firstUrl)
                    }
                    if self.usermodel!.photo["second"] != nil{
                        if let secondUrl = URL(string:self.usermodel!.photo["second"]!){
                            cell.secondImageView.kf.setImage(with: secondUrl)
                        }
                    }
                    if self.usermodel!.photo["third"] != nil{
                        if let thirdUrl = URL(string: self.usermodel!.photo["third"]!){
                            cell.thirdImageView.kf.setImage(with: thirdUrl)
                        }
                    }*/

                })
            }else{
                if isSelect[0] == true{
                    cell.firstImageView.image = tempImage
                    isSelect[0] = false
                }else if isSelect[1] == true{
                    cell.secondImageView.image = tempImage
                    isSelect[1] = false
                }else if isSelect[2] == true{
                    cell.thirdImageView.image = tempImage
                    isSelect[2] = false
                }else{
                    //return cell
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

class myPageFirstCell:UITableViewCell{
    
}

class myPageSecondCell:UITableViewCell{
    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    @IBOutlet weak var thirdImageView: UIImageView!
}
