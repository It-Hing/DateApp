//
//  loadingVC.swift
//  drink
//
//  Created by user on 29/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation

class loadingVC:NSObject{
    private static let sharedInstance = loadingVC()//싱글톤
    private var popupView:UIImageView?
    private var backgroundView:UIView?
    
    class func show() {
        let backgroundView = UIView(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))

        let popupView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        popupView.contentMode = .scaleAspectFit
        popupView.clipsToBounds = true
        //popupView.tintColor = .red
        popupView.backgroundColor = UIColor.clear
        popupView.animationImages = loadingVC.getAnimationImageArray()
        popupView.tintColor = .red
        popupView.animationDuration = 0.4
        popupView.animationRepeatCount = 0
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(popupView)
            window.addSubview(backgroundView)
            
            popupView.center = window.center
            popupView.startAnimating()
            popupView.tintColor = .red
            
            backgroundView.frame = CGRect(x: 0, y: 0, width: window.frame.maxX, height: window.frame.maxY)
            backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            
            sharedInstance.popupView?.removeFromSuperview()
            sharedInstance.backgroundView?.removeFromSuperview()
            sharedInstance.popupView = popupView
            sharedInstance.backgroundView = backgroundView
        }
    }
    
    class func hide() {
        if let popupView = sharedInstance.popupView,

        let backgroundView = sharedInstance.backgroundView {
            popupView.stopAnimating()
            backgroundView.removeFromSuperview()
            popupView.removeFromSuperview()
        }
    }
    
    private class func getAnimationImageArray() -> [UIImage] {
        var animationArray: [UIImage] = []
        
        let purple = UIColor(red: 142.0/255, green: 130.0/255, blue: 250.0/255, alpha: 0.6)
        
        //animationArray.append(UIImage(named: "outline_favorite_black_48pt")!.maskWithColor(color: purple)!)
        //animationArray.append(UIImage(named: "outline_favorite_border_black_48pt")!.maskWithColor(color: purple)!)
        animationArray.append(UIImage(named: "frame-0")!)
        animationArray.append(UIImage(named: "frame-1")!)
        animationArray.append(UIImage(named: "frame-2")!)
        animationArray.append(UIImage(named: "frame-3")!)
        animationArray.append(UIImage(named: "frame-4")!)
        animationArray.append(UIImage(named: "frame-5")!)
        animationArray.append(UIImage(named: "frame-6")!)
        animationArray.append(UIImage(named: "frame-7")!)
        animationArray.append(UIImage(named: "frame-8")!)
        animationArray.append(UIImage(named: "frame-9")!)
        animationArray.append(UIImage(named: "frame-10")!)
        animationArray.append(UIImage(named: "frame-11")!)
        animationArray.append(UIImage(named: "frame-12")!)
        animationArray.append(UIImage(named: "frame-13")!)
        animationArray.append(UIImage(named: "frame-14")!)
        animationArray.append(UIImage(named: "frame-15")!)
        animationArray.append(UIImage(named: "frame-16")!)
        animationArray.append(UIImage(named: "frame-17")!)
        animationArray.append(UIImage(named: "frame-18")!)
        animationArray.append(UIImage(named: "frame-19")!)
        animationArray.append(UIImage(named: "frame-20")!)
        animationArray.append(UIImage(named: "frame-21")!)
        animationArray.append(UIImage(named: "frame-22")!)
        animationArray.append(UIImage(named: "frame-23")!)
        animationArray.append(UIImage(named: "frame-24")!)
        animationArray.append(UIImage(named: "frame-25")!)
        animationArray.append(UIImage(named: "frame-26")!)
        animationArray.append(UIImage(named: "frame-27")!)
        animationArray.append(UIImage(named: "frame-28")!)
        animationArray.append(UIImage(named: "frame-29")!)
        animationArray.append(UIImage(named: "frame-30")!)




        return animationArray
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}
