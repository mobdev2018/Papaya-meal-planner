//
//  HomeVC.swift
//  Papaya Meal Planner
//
//  Created by anton on 1/20/17.
//  Copyright © 2017 Papaya LC. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import SwiftKeychainWrapper

class HomeVC: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var featuredView: UIView!
    
    @IBOutlet weak var nutritionView: UIView!
    @IBOutlet weak var lblNutritionTitle: UILabel!
    @IBOutlet weak var btnNutritionMore: UIButton!
    
    @IBOutlet weak var recipiesView: UIView!
    @IBOutlet weak var lblRecipiesTitle: UILabel!
    @IBOutlet weak var btnRecipiesMore: UIButton!
    
    @IBOutlet weak var blogpostView: UIView!
    @IBOutlet weak var lblBlogTitle: UILabel!
    @IBOutlet weak var btnBlogMore: UIButton!
    
    var videos: [[String: String]] = [
        ["url": "https://www.youtube.com/watch?v=vpzQ9D4MlDs", "thumbnail": "https://img.youtube.com/vi/vpzQ9D4MlDs/0.jpg", "title": "Types of Carbohydrates: Part I- Premium Carbohydrates", "id": "1", "time": "2:18"],
        ["url": "https://www.youtube.com/watch?v=QtKewGPaDbk", "thumbnail": "https://img.youtube.com/vi/QtKewGPaDbk/0.jpg", "title": "Types of Carbohydrates: Part II- Regular Carbohydrates", "id": "2", "time": "1:15"],
        ["url": "https://www.youtube.com/watch?v=jcnl26-f3Vc", "thumbnail": "https://img.youtube.com/vi/jcnl26-f3Vc/0.jpg", "title": "How to Select a Premium Carb: Part I- By Color", "id": "3", "time": "1:56"],
        ["url": "https://www.youtube.com/watch?v=YYTyaOKTbXs", "thumbnail": "https://img.youtube.com/vi/YYTyaOKTbXs/0.jpg", "title": "How to Select a Premium Carb: Part II- The 6:1 Rule", "id": "4", "time": "2:32"]
    ]
    
    var videos2: [[String: String]] = [
        ["url": "https://www.youtube.com/watch?v=A0j9Opy2j4w", "thumbnail": "https://img.youtube.com/vi/A0j9Opy2j4w/0.jpg", "title": "Meal prep as a college student! Bulk/Shred", "id": "5", "time": "7:59"],
        ["url": "https://www.youtube.com/watch?v=sbgEimxxr2I", "thumbnail": "https://img.youtube.com/vi/sbgEimxxr2I/0.jpg", "title": "The ULTIMATE meal prep!! PACKED WITH PROTEIN! | Bulk/ Shred", "id": "6", "time": "11:23"]
    ]
    
    var blog: [[String: String]] = [
        ["url": "https://www.papayamealprep.com/meal-prep/", "thumbnail": "https://www.papayamealprep.com/wp-content/uploads/2016/11/meal-prep-and-weighing-food-800x520.jpg", "title": "Getting Started With Meal Prep: A Quick Intro", "description": "Learn to successfully meal prep", "id": "7"],
        ["url": "http://www.papayamealprep.com/meal-prep-tools/", "thumbnail": "https://www.papayamealprep.com/wp-content/uploads/2016/11/meal-prep-foods-on-stove-800x520.jpg", "title": "Tools for Successful Meal Prepping", "description": "Learn the tools that every meal prepper must have", "id": "8"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // save the users push token
        savePushNotificationToken()
        
        // Do any additional setup after loading the view.
        let screenSize = UIScreen.main.bounds.size
        
        featuredView.layer.cornerRadius = 5
        nutritionView.layer.cornerRadius = 5
        recipiesView.layer.cornerRadius = 5
        blogpostView.layer.cornerRadius = 5
        
        lblNutritionTitle.font = UIFont(name: lblNutritionTitle.font.fontName, size: screenSize.width * 18 / 375)
        lblRecipiesTitle.font = UIFont(name: lblRecipiesTitle.font.fontName, size: screenSize.width * 18 / 375)
        lblBlogTitle.font = UIFont(name: lblBlogTitle.font.fontName, size: screenSize.width * 18 / 375)
        
        btnNutritionMore.titleLabel?.font = UIFont(name: (btnNutritionMore.titleLabel?.font.fontName)!, size: screenSize.width * 14 / 375)
        btnRecipiesMore.titleLabel?.font = UIFont(name: (btnRecipiesMore.titleLabel?.font.fontName)!, size: screenSize.width * 14 / 375)
        btnBlogMore.titleLabel?.font = UIFont(name: (btnBlogMore.titleLabel?.font.fontName)!, size: screenSize.width * 14 / 375)
        
        
    }
    
    func savePushNotificationToken() {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        guard let pushToken = UserInfo.pushToken else {
            return
        }
        
        let parameters: Parameters = ["registration_id": pushToken]
        
        savePushToken(parameters: parameters, headers: headers) { response in
            
            print(response)
        }
    }
    
    func contentClick(id: Int) {
        
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        let parameters: Parameters = ["action": "content_click"]
        
        contentAction(contentId: id, parameters: parameters, headers: headers) { response in
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            fatalError("Segue not implemented")
        }
        
        switch identifier {
        case "showVideoSegueID":
            guard let videoVC = segue.destination as? VideoViewController else {
                fatalError("Invalid segue destination")
            }
            guard let item = sender as? [String: String] else {
                fatalError("Invalid segue data")
            }
            
            videoVC.videoUrl = item["url"]
            
            if let id = item["id"]{
                if let intId = Int(id){
                    videoVC.id = intId
                }
            }
            
            break
        case "showWebView":
            guard let webVC = segue.destination as? WebViewController else {
                fatalError("Invalid segue destination")
            }
            
            guard let item = sender as? [String: String] else {
                fatalError("Invalid segue data")
            }
            
            webVC.url = item["url"]
            break
        default:
            fatalError("Segue not implemented")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize = UIScreen.main.bounds.size
        var height : CGFloat = 0
        
        switch indexPath.row {
        case 0:
            height = 0
            //height = 145
            break
        case 1:
            height = screenSize.width * 230 / 375
            break
        case 2:
            height = screenSize.width * 230 / 375
            break
        case 3:
            height = screenSize.width * 250 / 375
            break
        case 4:
            height = 0
            //height = screenSize.width * 360 / 375
            break
        default:
            break
        }
        return height
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfItems = 0;
        switch collectionView.tag {
        case 1:
            numberOfItems = 4;
            break
        case 2:
            numberOfItems = 2;
            break
        case 3:
            numberOfItems = 2;
            break
//        case 4:
//            numberOfItems = 6;
//            break
        default:
            break
        }
        return numberOfItems;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let borderColor = UIColor(red: 1, green: 245/255, blue: 248/255.0, alpha: 1)
        
        let cell = UICollectionViewCell()
        
        switch collectionView.tag {
        case 1:  // Nutrition CollectionView
            let nutritionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NutritionCell", for: indexPath) as! NutritionCell
            
            nutritionCell.view.layer.borderColor = borderColor.cgColor
            nutritionCell.view.layer.borderWidth = 2.0
            nutritionCell.view.layer.cornerRadius = 10
            
            let imageUrl = videos[indexPath.row]["thumbnail"]
            
            if let image = imageUrl {
                let url = URL(string: image)
                
                if url != nil {
                    nutritionCell.imgBackground.kf.setImage(with: url!)
                }
            }
            
            nutritionCell.lblTitle.text = videos[indexPath.row]["title"]
            nutritionCell.lblTime.text = videos[indexPath.row]["time"]
            return nutritionCell
            
        case 2: // Latest Recipies
            let nutritionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NutritionCell", for: indexPath) as! NutritionCell
            
            nutritionCell.view.layer.borderColor = borderColor.cgColor
            nutritionCell.view.layer.borderWidth = 2.0
            nutritionCell.view.layer.cornerRadius = 10
            
            let imageUrl = videos2[indexPath.row]["thumbnail"]
            
            if let image = imageUrl {
                let url = URL(string: image)
                
                if url != nil {
                    nutritionCell.imgBackground.kf.setImage(with: url!)
                }
            }
            
            nutritionCell.lblTitle.text = videos2[indexPath.row]["title"]
            nutritionCell.lblTime.text = videos2[indexPath.row]["time"]
            
            return nutritionCell
        case 3: // Latest Blog Post
            let blogpostcell = collectionView.dequeueReusableCell(withReuseIdentifier: "BlogPostCell", for: indexPath) as! BlogPostCell
            
            blogpostcell.view.layer.borderColor = borderColor.cgColor
            blogpostcell.view.layer.borderWidth = 2.0
            blogpostcell.view.layer.cornerRadius = 10
            
            
            let imageUrl = blog[indexPath.row]["thumbnail"]
            
            if let image = imageUrl {
                let url = URL(string: image)
                
                if url != nil {
                    blogpostcell.imgBackground.kf.setImage(with: url!)
                }
            }
            
            blogpostcell.lblTitle.text = blog[indexPath.row]["title"]
            blogpostcell.lblDescription.text = blog[indexPath.row]["description"]
            
            return blogpostcell
            
//        case 4:
//            let recipiesCell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipiesCell", for: indexPath) as! RecipiesCell
//            recipiesCell.view.layer.borderColor = borderColor.cgColor
//            recipiesCell.view.layer.borderWidth = 2.0
//            recipiesCell.view.layer.cornerRadius = 5
//            //recipiesCell.imgBackground
//            //recipiesCell.lblTitle.text
//            return recipiesCell
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 1:
            performSegue(withIdentifier: "showVideoSegueID", sender: videos[indexPath.item])
            if let id = videos[indexPath.item]["id"]{
                if let intId = Int(id){
                    contentClick(id: intId)
                }
            }
            break
        case 2:
           performSegue(withIdentifier: "showVideoSegueID", sender: videos2[indexPath.item])
           if let id = videos2[indexPath.item]["id"]{
            if let intId = Int(id){
                contentClick(id: intId)
            }
           }
           break
        case 3:
            performSegue(withIdentifier: "showWebView", sender: blog[indexPath.item])
            if let id = blog[indexPath.item]["id"]{
                if let intId = Int(id){
                    contentClick(id: intId)
                }
            }
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.bounds.size.width
        let collectionViewHeight = collectionView.bounds.size.height
        
        var cellWidth : CGFloat = 0.0
        var cellHeight : CGFloat = 0.0
        switch collectionView.tag {
        case 1:
            cellWidth = collectionViewWidth-20.0
            cellHeight = collectionViewHeight - 16
            break
        case 2:
            cellWidth = collectionViewWidth-20.0
            cellHeight = collectionViewHeight - 16
            break
        case 3:
            cellWidth = CGFloat(collectionViewWidth) - CGFloat(20.0)
            cellHeight = collectionViewHeight - 16

            break
//        case 4:
//            cellWidth = (collectionViewWidth-32) / 3
//            cellHeight = (collectionViewHeight - 32) / 2
//            break
        default:
            break
        }
        
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
}
