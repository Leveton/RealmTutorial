//
//  LogCell.swift
//  RWRealmStarterProject
//
//  Created by Bill Kastanakis on 8/13/14.
//  Copyright (c) 2014 Bill Kastanakis. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
