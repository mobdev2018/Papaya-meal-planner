//
//  WalkthroughContentViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/4/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

protocol SkipDelegate {
    func skip()
}

class WalkthroughContentViewController: UIViewController {

    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var onboardingImage: UIImageView!
    
    var delegate: SkipDelegate?
    
    var pageIndex: Int!
    let images = ["home-1", "home-2", "home-3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onSkip(_ sender: AnyObject) {
        
        self.delegate?.skip()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.pageIndex == 0 {
            setFirstView()
        } else {
            onboardingImage.image = UIImage(named: images[pageIndex - 1])
            setSecondView()
        }
        
    }
    
    public func setFirstView()
    {
        self.firstView.isHidden = false
        self.secondView.isHidden = true
    }
    
    public func setSecondView()
    {
        self.firstView.isHidden = true
        self.secondView.isHidden = false
    }

}
