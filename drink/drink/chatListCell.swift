//
//  chatListCell.swift
//  drink
//
//  Created by user on 09/08/2019.
//  Copyright © 2019 user. All rights reserved.
//

import Foundation
import UIKit

class chatListCell:UITableViewCell{
    @IBOutlet weak var destination_face: UIImageView!
    @IBOutlet var label_username: UILabel!
    @IBOutlet var label_lastChat: UILabel!
    @IBOutlet var label_chatTime: UILabel!
    @IBOutlet var label_noReadCount: UILabel!
    var pushToken:String?
    var platform:String?
}
