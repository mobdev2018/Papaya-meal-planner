//
//  HomeViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/4/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UIPageViewControllerDataSource, SkipDelegate {

    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var pageViewController = UIPageViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the background to a gradient
        setGradientBackground()
        
        // add border to login/sign up button
        addButtonBorder(button: loginButton)
        addButtonBorder(button: signUpButton)
    

        //instantiate view controller
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(index: 0) as WalkthroughContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRect(x: 0, y: 30, width: self.view.frame.width, height: self.view.frame.size.height - 180)
        
        
        addChildViewController(self.pageViewController)
        self.view.addSubview((self.pageViewController.view)!)
        self.pageViewController.didMove(toParentViewController: self)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
        if UserInfo.isLoggedIn {
            // user is logged in - go to Feed
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
    }
   
    func setGradientBackground() {
        let colorBottom =  UIColor(red: 203.0 / 255.0, green: 24.0/255.0, blue: 75.0 / 255.0, alpha: 1.0).cgColor
        let colorTop = UIColor(red: 44.0/255.0, green: 14.0/255.0, blue: 55.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func addButtonBorder(button: UIButton) {
        let border = CALayer()
        let width = CGFloat(1.5)
        border.borderColor = UIColor(red: 220.0 / 250.0, green: 220.0/255.0, blue: 220.0 / 255.0, alpha: 0.5).cgColor
        border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.maxX, height: width)
        
        border.borderWidth = width
        button.layer.addSublayer(border)
        button.layer.masksToBounds = true
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughContentViewController {
        
        if((index >= 4)){
            
            return WalkthroughContentViewController()
        }
        
        let vc: WalkthroughContentViewController = (self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as? WalkthroughContentViewController)!
        
        vc.delegate = self
        vc.pageIndex = index

        return vc
    }
    
    func skip() {
        let startVC = self.viewControllerAtIndex(index: 1) as WalkthroughContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
    }
    // Mark: Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! WalkthroughContentViewController
        var index = vc.pageIndex as Int
        
        if(index == 0 || index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! WalkthroughContentViewController
        var index = vc.pageIndex as Int
        
        if(index == NSNotFound) {
            return nil
        }
        
        index += 1
        
        if(index == 4){
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    

}
