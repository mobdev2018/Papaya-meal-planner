//
//  MealTableViewHeaderCell.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/23/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class MealTableViewHeaderCell: UITableViewCell {

    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var regenerateButton: UIButton!
    @IBOutlet weak var numCalories: UILabel!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var refreshButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var checkButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkButtonView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    
    var swipeStatus = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.refreshButtonWidthConstraint.constant = 0.0
        self.checkButtonWidthConstraint.constant = 0.0
        self.layoutIfNeeded()
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.responseToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.responseToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.addGestureRecognizer(swipeLeft)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func responseToSwipeGesture(gesture: UIGestureRecognizer)
    {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if swipeStatus == 0 {
                    UIView.animate(withDuration: 0.2, animations: {
                        let screenSize = UIScreen.main.bounds.size
                        self.checkButtonWidthConstraint.constant = screenSize.width * 80 / 375.0
                        self.layoutIfNeeded()
                    })
                    
                    swipeStatus = -1
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.refreshButtonWidthConstraint.constant = 0.0
                        self.layoutIfNeeded()
                    })
                    swipeStatus = 0
                }
                break
            case UISwipeGestureRecognizerDirection.left:
                if swipeStatus == 0 {
                    UIView.animate(withDuration: 0.2, animations: {
                        let screenSize = UIScreen.main.bounds.size
                        self.refreshButtonWidthConstraint.constant = screenSize.width * 60 / 375.0
                        self.layoutIfNeeded()
                    })
                    swipeStatus = 1
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.checkButtonWidthConstraint.constant = 0.0
                        self.layoutIfNeeded()
                    })
                    swipeStatus = 0
                }
                
                break
            default:
                break
            }
        }
    }

}
