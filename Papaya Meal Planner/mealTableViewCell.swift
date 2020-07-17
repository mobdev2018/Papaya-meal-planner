//
//  mealTableViewCell.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/5/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class mealTableViewCell: UITableViewCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeServing: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeBorder: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
