//
//  chatRoomListController.swift
//  drink
//
//  Created by user on 09/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import Firebase
import Kingfisher

class chatRoomListController:UIViewController{
    
    @IBOutlet weak var chatListTableView: UITableView!
    let db = Database.database().reference()
    var chatRooms:[chatModel] = []//대화방 정보를 담는 리스트
    var destinationUser:[String] = []//대화방에 참여한 사람들의 uid값을 받아옴.
    var observe:UInt?
    var databaseRef:DatabaseQuery?
    var keys:[String] = []//채팅방의 키값을 담을 리스트 마지막 채팅과 시간을 가져오기 위해 사용
    var usermodel:userModel?
    var tapIsPossible = true//viewdidappear메소드에서 getchatlist메소드를 실행하기전에 누르는것을 방지하는 변수
    var isChatRoomClick:Bool = false
    var default_image:UIImage?
    
    @IBOutlet weak var label_zeroRoom: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        //제스처로 뒤로가기 금지
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        label_zeroRoom.numberOfLines = 0
        getChatList()
    }
    
    //채팅방에 들어갔다가 뒤로가기로 다시 나오면 채팅리스트 받기 시작
    override func viewDidAppear(_ animated: Bool){
        //observe가 nil이되는 경우는 채팅방을 클릭하는 경우
        if isChatRoomClick == true{
            databaseRef?.removeAllObservers()//혹시모르니까 옵저버 한번더 삭제해줌
            tapIsPossible = false//getcharlist메소드가 실행되지않으면 눌러도 채팅을 불러오지 못함 탭불가처리
            print("viewdidappear")
            isChatRoomClick = false
            print("viewdidappear에서 observe잡기 성공")
            getChatList()
        }else{
            
        }
    }
    
    func getChatList(){
        let uid = Auth.auth().currentUser!.uid
        
        databaseRef = db.child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true)
        observe = databaseRef!.observe(DataEventType.value,with: { (dataSnapshot) in
            print("방찾기 메소드 실행")
            self.chatRooms.removeAll()
            self.destinationUser.removeAll()//새로생성할때 마다 비워주기 대화상대가 꼬임을 방지
            var lastMessages:[String] = []

            for item in dataSnapshot.children.allObjects as! [DataSnapshot]{
                
                if let chatRoomdic = item.value as? [String:AnyObject]{
                    let chatroom = chatModel(JSON: chatRoomdic)
                    if chatroom?.comments.count == 0 {
                        continue
                    }
                    chatroom?.roomid = item.key
                    //채팅방에 채팅이 하나도 없으면 리스트에 넣지 않음
                    self.chatRooms.append(chatroom!)
                    //self.keys.append(item.key)
                    let lastMessage = chatroom!.comments.keys.sorted(){$0>$1}//메세지를 정렬해서
                    if lastMessage.count > 0{
                        lastMessages.append(lastMessage[0])//가장 최신 메세지를 리스트에 저장(최신채팅방정렬용)
                    }
                }
            }
            
            //채팅방의 수가 0개이면 정렬하지않음
            if(self.chatRooms.count == 0){
                self.chatListTableView.reloadData()
                self.tapIsPossible = true//채팅방을 누를 수 있도록 허용
                return
            }
            //메세지 온 순서대로 채팅방 나열 후 테이블뷰 새로고침
            
            var temp:chatModel?
            var tempMessage:String?
            for i in 0..<(self.chatRooms.count-1){
                //print((self.chatRooms[i].comments[lastMessages[i]]?.timestamp)!)
                for j in (i+1)..<(self.chatRooms.count){
                    if((self.chatRooms[i].comments[lastMessages[i]]?.timestamp)! <  (self.chatRooms[j].comments[lastMessages[j]]?.timestamp)!){
                        //print("i = \(i), j = \(j)")
                        temp = self.chatRooms[i]
                        self.chatRooms[i] = self.chatRooms[j]
                        self.chatRooms[j] = temp!
                        tempMessage = lastMessages[i]
                        lastMessages[i] = lastMessages[j]
                        lastMessages[j] = tempMessage!
                    }
                }
            }
            self.chatListTableView.reloadData()
            self.tapIsPossible = true//채팅방을 누를 수 있도록 허용
        })//채팅방 목록이 실시간으로 업데이트되도록 고친 코드
    }
    
    
}

extension chatRoomListController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chatRooms.count == 0{
            label_zeroRoom.text = "채팅리스트가 비어있습니다.\n사람들에게 먼저 대화를 걸어보세요!"
            label_zeroRoom.isHidden = false
        }else{
            label_zeroRoom.isHidden = true
        }
        return chatRooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatListTableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath) as! chatListCell
        
        if (default_image == nil){
            default_image = cell.destination_face.image
        }
        
        cell.label_noReadCount.isHidden = true
        var destinationUid:String?
        let uid = Auth.auth().currentUser!.uid

        for item in chatRooms[indexPath.row].users{
            if item.key != uid{
                destinationUid = item.key
                destinationUser.append(destinationUid!)
                //채팅방에 대한 정보를 받아온 후 자신의 uid가 아니면 상대방의 uid이므로 리스트에 삽입
            }
        }
        
        db.child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value, with: { (DataSnapshot) in
            if !DataSnapshot.exists(){
                print("사용자 없음")
                cell.label_username.text = "탈퇴한 회원"
                return
            }
            
            self.usermodel = userModel(JSON: DataSnapshot.value as! [String:AnyObject])
            
            /*if ((self.usermodel?.blockedList.keys.contains(uid))!){
                if (chatRooms[indexPath.row].)
                self.db.child("chatrooms").child(self.chatRooms[indexPath.row].roomid!).child("users").child(destinationUid!).setValue(false, withCompletionBlock: { (err, ref) in
                    print("나를 블락한 사람이 채팅에서 나감")
                })
                return
            }else{
                self.destinationUser.append(destinationUid!)
                //나를 차단한 사람이 아니면 채팅리스트에 넣어줌
            }*/
            
            cell.label_username.text = self.usermodel?.username
            //let temp_usermodel = self.usermodel
            let imageIndex = self.usermodel?.photo.keys.sorted()
            let url:URL?
            if (self.usermodel?.photo.count != 0){
                if(self.usermodel!.photo[imageIndex![0]]!.image != nil){
                    url = URL(string:(self.usermodel!.photo[imageIndex![0]]!.image!))
                    cell.destination_face.kf.setImage(with:url)
                }else{
                    cell.destination_face.image = self.default_image
                    //cell.destination_face.image = UIImage(named: "사용자사진")
                    //url = URL(string:(self.usermodel!.photo[imageIndex![0]]!.temp!))
                }
            }else{
                cell.destination_face.image = self.default_image
               // cell.destination_face.image = UIImage(named: "사용자사진")
            }
            cell.destination_face.layer.cornerRadius = cell.destination_face.frame.width/3
            cell.destination_face.layer.masksToBounds = true
            cell.pushToken = self.usermodel?.pushtoken
            cell.platform = self.usermodel?.platform
        })
        
        //채팅방목록을 보고 있을 때 새로운 채팅방이 다른 채팅방위에 생성되면 최근 대화내용과 시간이
        //이전에 그 행에 있던 채팅방의 정보로 표시된다.->수정완료
        cell.label_chatTime.isHidden = false
        cell.label_lastChat.isHidden = false
        
        if self.chatRooms[indexPath.row].comments.keys.count == 0{
            cell.label_chatTime.isHidden = true
            cell.label_lastChat.isHidden = true
            return cell
        }
        
        let lastMessagekey = self.chatRooms[indexPath.row].comments.keys.sorted(){$0>$1}
        cell.label_lastChat.text = self.chatRooms[indexPath.row].comments[lastMessagekey[0]]?.message
        
        let unixTime = self.chatRooms[indexPath.row].comments[lastMessagekey[0]]?.timestamp

        //오늘날짜 스트링값 생성
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date()
        let today = dateFormatter.string(from: date)
        //
        
        let separatedDate = unixTime!.toDayTime.components(separatedBy: " ")
        let separatedToday = today.components(separatedBy: " ")
        
        let year = separatedDate[0].components(separatedBy: ".")[0]
        let todayYear = separatedToday[0].components(separatedBy: ".")[0]
        
        let month = separatedDate[0].components(separatedBy: ".")[1]
        let todayMonth = separatedToday[0].components(separatedBy: ".")[1]

        let day = separatedDate[0].components(separatedBy: ".")[2]
        let todayDay = separatedToday[0].components(separatedBy: ".")[2]

        if (separatedToday[0] == separatedDate[0]){
            //오늘 온 메시지
            let hour = Int(separatedDate[1].components(separatedBy: ":")[0])
            let minute = separatedDate[1].components(separatedBy: ":")[1]
            
            if (hour == 0){
                cell.label_chatTime.text = "오전 \(12):\(minute)"
            }else if(hour! > 12){
                cell.label_chatTime.text = "오후 \(hour! - 12):\(minute)"
            }else{
                cell.label_chatTime.text = "오전 \(hour!):\(minute)"
            }
            
            /*if(hour! > 11){
                cell.label_chatTime.text = "오후 \(hour!-12):\(minute)"
            }else{
                cell.label_chatTime.text = "오전 \(hour!):\(minute)"
            }*/
            
        }else if (year != todayYear){
            //올해 받은 메시지가 아닌경우
            cell.label_chatTime.text = unixTime?.toDayTime
        }else{
            //올해받은 메시지인데 오늘이 아닌경우
            if(month == todayMonth && Int(todayDay)! - Int(day)! == 1){
                cell.label_chatTime.text = "어제"
            }else{
                cell.label_chatTime.text = "\(month)월 \(day)일"
            }
        }
        
        //cell.label_chatTime.text = unixTime?.toDayTime
        
        var noReadCount = 0
        let ref = self.chatRooms[indexPath.row]
        
        for item in lastMessagekey{
            if (ref.comments[item]!.uid == destinationUid && ref.comments[item]?.readUsers == nil){
                noReadCount += 1
                if noReadCount >= 99{
                    break
                }
            }else {
                break
            }
        }
        
        if noReadCount == 0{
            cell.label_noReadCount.isHidden = true
        }else{
            cell.label_noReadCount.text = String(noReadCount)
            cell.label_noReadCount.isHidden = false
            cell.label_noReadCount.layer.cornerRadius = cell.label_noReadCount.frame.height/2
            cell.label_noReadCount.layer.masksToBounds = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chatListTableView.deselectRow(at: indexPath, animated: true)
        
        if tapIsPossible == false{
            print("데이터가 아직 로드되지 않았습니다.")
            return
        }
        
        //print(chatRooms[indexPath.row].roomid)

        //
        if databaseRef != nil{
            databaseRef?.removeAllObservers()
            isChatRoomClick = true
            print("채팅리스트 옵저버 풀기")
        }
        //
        
        guard let cell = chatListTableView.cellForRow(at: indexPath) as? chatListCell else {return}
        let destinationUid:String = destinationUser[indexPath.row]
        
        let chatViewController = self.storyboard?.instantiateViewController(withIdentifier: "chatViewController") as! chatViewController
        
        print(indexPath.row)
        chatViewController.destinationUid = destinationUid
        chatViewController.chatRoomUid = chatRooms[indexPath.row].roomid
        chatViewController.destinationName = cell.label_username.text
        chatViewController.destinationImage = cell.destination_face.image
        chatViewController.pushToken = cell.pushToken
        chatViewController.destinationPlatform = cell.platform
        
        self.navigationController?.pushViewController(chatViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
