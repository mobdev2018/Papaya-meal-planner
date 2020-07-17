//
//  MacrosTableViewCell.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 1/17/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit
import Charts

class MacrosTableViewCell: UITableViewCell {

    @IBOutlet weak var carbsColorView: UIView!
    @IBOutlet weak var fatColorView: UIView!
    @IBOutlet weak var proteinColorView: UIView!
    
    @IBOutlet weak var carbsTotalPercentLabel: UILabel!
    @IBOutlet weak var fatTotalPercentLabel: UILabel!
    @IBOutlet weak var proteinTotalPercentLabel: UILabel!
    
    @IBOutlet weak var carbsTargetPercentLabel: UILabel!
    @IBOutlet weak var fatTargetPercentLabel: UILabel!
    @IBOutlet weak var proteinTargetPercentLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
