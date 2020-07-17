//
//  NutritionTableViewCell.swift
//  Papaya Meal Planner
//
//  Created by beauty on 12/20/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class NutritionTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var imgPoint: UIImageView!
    @IBOutlet weak var topLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
