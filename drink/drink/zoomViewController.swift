//
//  zoomViewController.swift
//  drink
//
//  Created by user on 14/01/2020.
//  Copyright © 2020 user. All rights reserved.
//

import Foundation
import UIKit

class zoomViewController:UIViewController, UIScrollViewDelegate{
    
    
    @IBOutlet weak var zoomScrollView: UIScrollView!
    @IBOutlet weak var zoomImageView: UIImageView!
    var userImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        zoomImageView.image = userImage
        
        zoomScrollView.alwaysBounceVertical = false
        zoomScrollView.alwaysBounceHorizontal = false

        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 5.0
        
        zoomScrollView.delegate = self
    }
        
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
    }
    
}
