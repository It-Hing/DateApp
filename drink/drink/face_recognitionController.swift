//
//  face_recognitionController.swift
//  drink
//
//  Created by user on 01/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class face_recognitionController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    static func detect(img: UIImage, text: UILabel)->Bool{
        text.textColor = UIColor.red
        //이미지뷰에서 이미지 가져오기
        let faceImg = CIImage(image: img)
        //userFaceView.image!
        
        //set up detector
        let accuracy = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: faceImg!, options: [CIDetectorSmile:true])
        
        var mouthShowing:Bool = false
        var eyeShowing:Bool = false
        var pnp:Bool = false
        
        if !faces!.isEmpty{
            if faces!.count > 1{
                //userFaceInfrom.text = "사람이 너무 많습니다.\n"
                text.text = "사람이 너무 많습니다.\n"
            }else{
                text.textColor = UIColor.blue
                for face in faces as! [CIFaceFeature]{
                    mouthShowing = face.hasMouthPosition
                    eyeShowing = face.hasLeftEyePosition && face.hasRightEyePosition
                    /*let mouthShowing = "입 인식여부:  \(face.hasMouthPosition)"
                    var eyeShowing = ""
                    if !face.hasRightEyePosition || !face.hasLeftEyePosition{
                        eyeShowing = "양쪽눈 인식 여부: \(false)"
                    }else{
                        eyeShowing = "양쪽눈 인식 여부: \(true)"
                    }
                    
                    //userFaceInfrom.text = "\(mouthShowing)\n\n\(eyeShowing)"*/
                    
                    if mouthShowing && eyeShowing{
                        pnp = true
                        text.text = "사용가능한 사진입니다."
                    }else{
                        pnp = false
                        text.text = "사용불가능한 사진입니다."
                    }
                    
                    //text.text = "\(mouthShowing)\n\(eyeShowing)"
                }
            }
        }else{
            //userFaceInfrom.text = "얼굴이 존재하지 않는 사진입니다.\n"
            text.text = "얼굴이 존재하지 않는 사진입니다.\n"
        }
        
        return pnp
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
