//
//  chatCell.swift
//  drink
//
//  Created by user on 08/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit

class myChatCell:UITableViewCell{
    @IBOutlet weak var message_label: UILabel!
    @IBOutlet weak var label_timestamp: UILabel!
    @IBOutlet weak var label_readCounter: UILabel!
    @IBOutlet weak var label_date: UILabel!
    @IBOutlet weak var constraint_dateTop: NSLayoutConstraint!
    @IBOutlet weak var constraint_dateBottom: NSLayoutConstraint!
    @IBOutlet weak var message_imageView: UIImageView!
    
    //@IBOutlet weak var dateHeight: NSLayoutConstraint!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //label_date.layer.cornerRadius = label_date.frame.height/2
        label_date.layer.cornerRadius = 8
        label_date.layer.masksToBounds = true
        label_date.clipsToBounds = true
    }
}
