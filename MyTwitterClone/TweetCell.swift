//
//  TweetCell.swift
//  MyTwitterClone
//
//  Created by Randall Leung on 10/7/14.
//  Copyright (c) 2014 Randall. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
    
    
    @IBOutlet var profilePic: UIImageView!

    @IBOutlet var textView: UITextView!

    @IBOutlet var username: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
