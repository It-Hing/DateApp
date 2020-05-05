//
//  storeObserver.swift
//  drink
//
//  Created by user on 09/12/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import StoreKit
import FirebaseAuth
import FirebaseDatabase

class storeObserver:NSObject,SKPaymentTransactionObserver{
    
    var purchased = [SKPaymentTransaction]()
    
    override init(){
        super.init()
        //생성자를 위한 초기화 메소드
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions{
            switch transaction.transactionState{
            case .purchasing:
                print("결제가 진행중입니다.")
                break
            case .purchased:
                print("결제를 성공했습니다.")
                handlePurchased(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
                queue.finishTransaction(transaction)
                break
            case .failed:
                print("결제를 실패하였습니다.")
                SKPaymentQueue.default().finishTransaction(transaction)
                queue.finishTransaction(transaction)
                break
            case .restored:
                print("상품을 검증하였습니다.")
                SKPaymentQueue.default().finishTransaction(transaction)
                queue.finishTransaction(transaction)
                break
            case .deferred:
                print("아이폰이 잠기는 등의 이유로 결제창을 띄우지 못했습니다.")
                SKPaymentQueue.default().finishTransaction(transaction)
                queue.finishTransaction(transaction)
                break
            @unknown default:
                print("알 수 없는 오류를 만났습니다.")
                SKPaymentQueue.default().finishTransaction(transaction)
                queue.finishTransaction(transaction)
                break
            }
            
            if let error = transaction.error {
                // message += "\n\(Messages.error) \(error.localizedDescription)"
                // print("\(Messages.error) \(error.localizedDescription)")
                print(error.localizedDescription)
            }
            
            // Do not send any notifications when the user cancels the purchase.
            if (transaction.error as? SKError)?.code != .paymentCancelled {
                DispatchQueue.main.async {
                    //self.delegate?.storeObserverDidReceiveMessage(message)
                }
            }
            
        }
    }
    
    func handlePurchased(transaction:SKPaymentTransaction){
        purchased.append(transaction)
        
        SKPaymentQueue.default().restoreCompletedTransactions()
        
        print("영수증 주소 : \(Bundle.main.appStoreReceiptURL)")
        
        let receiptData = NSData(contentsOf: Bundle.main.appStoreReceiptURL!)
        print(receiptData)
        
        let receiptString = receiptData!.base64EncodedString(options: NSData.Base64EncodingOptions())
        
        let uid = Auth.auth().currentUser?.uid
        let db = Database.database().reference()
        var heart:String?
        var beforeHeart:Int?
        var afterHeart:Int?
        
        db.child("users").child(uid!).child("heart").observeSingleEvent(of: DataEventType.value,with: { (dataSnapshot) in
            heart = String(describing:dataSnapshot.value!)
            beforeHeart = Int(heart!)
            afterHeart = Int(heart!)
            var getNum = 0
            
            switch transaction.payment.productIdentifier{
            case "com.sinabro.drink.heart1":
                getNum = 120
                break
            case "com.sinabro.drink.heart2":
                getNum = 240
                break
            case "com.sinabro.drink.heart3":
                getNum = 660
                break
            case "com.sinabro.drink.heart4":
                getNum = 1380
                break
            default:
                break
            }
            afterHeart = afterHeart!+getNum
            
            //하트수가 변했을 때 디비에 저장
            if (beforeHeart != afterHeart){
                heart = String(describing: afterHeart!)
                db.child("users").child(uid!).child("heart").setValue(heart!, withCompletionBlock: { (err, ref) in
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "ko_KR")
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let date = Date()
                    let time = dateFormatter.string(from: date)

                    db.child("Buys").child(uid!).childByAutoId().setValue([
                        "buys_change" : "+\(getNum)",
                        "buys_comment" : "하트구입",
                        "buys_date" : time,
                        "buys_id" : "ios",
                        "current_heart" : "\(heart!)"
                        ])
                })
            }
        })
        
        print("구매성공 트렌젝션 아이디 : \(transaction.transactionIdentifier!)")
        print("상품 아이디 : \(transaction.payment.productIdentifier)")
        print("구매 영수증 : \(receiptString)")
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}
