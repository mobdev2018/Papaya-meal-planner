//
//  InstructionsTableViewCell.swift
//  Papaya Meal Planner
//
//  Created by beauty on 12/20/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class InstructionsTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
