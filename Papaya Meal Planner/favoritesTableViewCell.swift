//
//  favoritesTableViewCell.swift
//  Papaya Meal Planner
//
//  Created by Norton Gumbo on 12/19/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class favoritesTableViewCell: UITableViewCell {
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var recipeBorderView: UIView!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
