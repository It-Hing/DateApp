//
//  privacyViewController.swift
//  drink
//
//  Created by user on 31/10/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class privacyViewController:UIViewController,WKUIDelegate,WKNavigationDelegate{
    
    @IBOutlet weak var backView: UIView!
    var webView: WKWebView!
    var statusBar:UIView?
    
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
            statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
            if statusBar!.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar!.backgroundColor = UIColor(red: 214.0/255, green: 214.0/255, blue: 214.0/255, alpha: 1.0)
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }
        
        navigationController?.navigationBar.isHidden = true
        /*let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        //view = webView
        //view.addSubview(backView)
        backView.addSubview(webView)
        
        if let url = Bundle.main.url(forResource: "이용약관", withExtension: "html") {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }*/
        //let myURL = URL(string:"https://ekts.com/main.do?mobYn=Y&conType=Y")
        //let myRequest = URLRequest(url: myURL!)
        //webView.load(myRequest)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        //navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if #available(iOS 13, *)
        {
            
        }else{
            if statusBar!.responds(to: #selector(setter: UIView.backgroundColor)) {
                statusBar!.backgroundColor = UIColor.clear
                //상태바에 색을 입혀서 웹뷰의 컨텐츠가 상태바에 보이지 않도록함
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        /*self.navigationController?.navigationBar.barStyle = .default
        let titleColor = UIColor(red: 134.0/255, green: 94.0/255, blue: 248.0/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor]
        self.navigationController?.navigationBar.tintColor = .darkGray
        navigationController?.navigationBar.setBottomBorderColor(color: .lightGray, height: 1)*/
    }
    
}
