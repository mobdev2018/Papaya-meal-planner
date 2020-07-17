//
//  RecipeViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/14/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class RecipeViewController: UIViewController {

    var recipe: Recipe?
    
    
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var cookTimeLabel: UILabel!
    @IBOutlet weak var yieldTextLabel: UILabel!
    
    @IBOutlet weak var btnIngredients: UIButton!
    @IBOutlet weak var btnInstructions: UIButton!
    @IBOutlet weak var btnNutrition: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var swipeView: UIView!
    
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up the views for the tabs
        setupView()
        
        // Set prep and cook time label
        prepTimeLabel.text = recipe?.prepTime
        cookTimeLabel.text = recipe?.cookTime
        
        // Add servings label
        if let servings = recipe?.servings {
            if servings > 1 {
                yieldTextLabel.text = "Yields: \(servings) servings"
            } else {
                yieldTextLabel.text = "Yields: \(servings) serving"
            }
        }
        
        let urlString = recipe?.imageUrl
        recipeName.text = recipe?.name
        
        if (urlString != ""){
            // Get recipe image
            let url = URL(string: urlString!)
            
            if url != nil {
                recipeImage.kf.setImage(with: url)
            }
        }
        
        if recipeImage.image == nil {
            recipeImage.image = UIImage(named: "dish")
        }
        
        addImageGradient()
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeUp1 = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeUp))
        swipeUp1.direction = UISwipeGestureRecognizerDirection.up
        self.swipeView.addGestureRecognizer(swipeUp1)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeUp))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Remove back button navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    func addImageGradient() {
        // gradient overlay
        let screenSize = UIScreen.main.bounds.size
        let gradient = CAGradientLayer() as CAGradientLayer
        let rect = CGRect(x: 0, y: 0, width: screenSize.width, height: 250)
        
        gradient.frame = rect
        let whiteColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        let blackColor = UIColor.init(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
        gradient.colors = [whiteColor.cgColor, blackColor.cgColor]
        overlayView.layer.insertSublayer(gradient, at: 0)
    }
    
    func respondToSwipeUp(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                self.swipeView.isHidden = true
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.topConstraint.constant = 0.0
                    self.view.layoutIfNeeded()
                })
            case UISwipeGestureRecognizerDirection.down:
                
                self.swipeView.isHidden = false
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.topConstraint.constant = 300.0
                    self.view.layoutIfNeeded()
                })
                
            default:
                break
            }
        }
    }
    
    private func setupView(){
        
        let pinkColor = UIColor.init(colorLiteralRed: 210/255.0, green: 57/255.0, blue: 101/255.0, alpha: 1.0)
        self.btnIngredients.layer.borderColor = pinkColor.cgColor
        self.btnInstructions.layer.borderColor = pinkColor.cgColor
        self.btnNutrition.layer.borderColor = pinkColor.cgColor
        
        self.btnIngredients.layer.borderWidth = 1.0
        self.btnInstructions.layer.borderWidth = 1.0
        self.btnNutrition.layer.borderWidth = 1.0
        
        self.btnIngredients.layer.cornerRadius = 20;
        self.btnInstructions.layer.cornerRadius = 20;
        self.btnNutrition.layer.cornerRadius = 20;
        
        selectedIndex = 0
        updateView()
    }
    
    @IBAction func onFavoriteButton(_ sender: UIBarButtonItem) {
        addFavorite()
    }
    
    func addFavorite() {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        guard let id = recipe?.recipeId else {
            // Show error if we don't have any data
            let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        let parameters: Parameters = ["recipe": "\(id)"]
        
        favoriteRecipe(parameters: parameters, headers: headers) { response in
            switch response.result {
            case .success:
                
                guard let data = response.data else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                let json = JSON(data: data),
                result = json["result"]
                
                // get favorite id
                let favoriteId = result["id"].intValue
                
                // add favorite id to recipe
                self.recipe?.favoriteId = favoriteId
                
                // Sends notification to favorites page to update
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFavorites"), object: nil)
            case .failure:
                guard let statusCode = response.response?.statusCode else {
                    return
                }
                // Check if favorite already exists
                if statusCode == 409 {
                    let alert = UIAlertController(title: "", message: "This recipe is already favorited.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    }
                }
        }
    }

    private lazy var IngredientsController: IngredientsTableViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "IngredientsController") as! IngredientsTableViewController
        viewController.recipe = self.recipe
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var InstructionsController: InstructionsTableViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "InstructionsController") as! InstructionsTableViewController
        viewController.recipe = self.recipe
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var NutritionController: NutritionTableViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "NutritionController") as! NutritionTableViewController
        viewController.recipe = self.recipe
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private func add(asChildViewController viewController: UIViewController){
        // Add Child View Controller
        addChildViewController(viewController)
        
        // Add Child View as Subview
        //view.addSubview(viewController.view)
        containerView.addSubview(viewController.view)
        
        // Configure Child View
        let rect = containerView.frame;
        viewController.view.frame = CGRect(x: 0 , y: 0, width: rect.size.width, height: rect.size.height)
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController){
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        //Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }
    
    @IBAction func onIngredients(_ sender: AnyObject) {
        
        let pinkColor = UIColor.init(colorLiteralRed: 210/255.0, green: 57/255.0, blue: 101/255.0, alpha: 1.0)
        btnIngredients.backgroundColor = pinkColor
        btnInstructions.backgroundColor = UIColor.clear
        btnNutrition.backgroundColor = UIColor.clear
        
        btnIngredients.setTitleColor(UIColor.white, for: UIControlState.normal)
        btnInstructions.setTitleColor(UIColor.black, for: UIControlState.normal)
        btnNutrition.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        selectedIndex = 0
        updateView()
    }
    
    @IBAction func onInstructions(_ sender: AnyObject) {
        let pinkColor = UIColor.init(colorLiteralRed: 210/255.0, green: 57/255.0, blue: 101/255.0, alpha: 1.0)
        btnIngredients.backgroundColor = UIColor.clear
        btnInstructions.backgroundColor = pinkColor
        btnNutrition.backgroundColor = UIColor.clear
        
        btnIngredients.setTitleColor(UIColor.black, for: UIControlState.normal)
        btnInstructions.setTitleColor(UIColor.white, for: UIControlState.normal)
        btnNutrition.setTitleColor(UIColor.black, for: UIControlState.normal)
        
        selectedIndex = 1
        updateView()
    }
    
    
    @IBAction func onNutrition(_ sender: AnyObject) {
        let pinkColor = UIColor.init(colorLiteralRed: 210/255.0, green: 57/255.0, blue: 101/255.0, alpha: 1.0)
        btnIngredients.backgroundColor = UIColor.clear
        btnInstructions.backgroundColor = UIColor.clear
        btnNutrition.backgroundColor = pinkColor
        
        btnIngredients.setTitleColor(UIColor.black, for: UIControlState.normal)
        btnInstructions.setTitleColor(UIColor.black, for: UIControlState.normal)
        btnNutrition.setTitleColor(UIColor.white, for: UIControlState.normal)
        
        selectedIndex = 2
        updateView()
    }
    
    private func updateView(){
        if selectedIndex == 0 {
            remove(asChildViewController: InstructionsController)
            add(asChildViewController: IngredientsController)
        }
        if selectedIndex == 1 {
            remove(asChildViewController: IngredientsController)
            add(asChildViewController: InstructionsController)
        }
        
        if selectedIndex == 2 {
            remove(asChildViewController: InstructionsController)
            add(asChildViewController: NutritionController)
        }
    }


}
