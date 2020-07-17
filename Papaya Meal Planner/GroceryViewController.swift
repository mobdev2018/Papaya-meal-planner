//
//  GroceryViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 10/16/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON

class GroceryViewController: UITableViewController {
    // Create a rational type
    typealias Rational = (num : Int, den : Int)
    
    var groceryItems: [GroceryItem] = [GroceryItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let height = UIApplication.shared.statusBarFrame.size.height
        // TODO: Change bottom height to tabbar
        let insets = UIEdgeInsets(top: height, left: 0, bottom: 49, right: 0)
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
        // Remove Empty cells from tableview
        self.tableView.tableFooterView = UIView()
        
        // Listens for when recipe is regenerated
        NotificationCenter.default.addObserver(self, selector: #selector(GroceryViewController.reloadItems), name: NSNotification.Name(rawValue: "reloadGroceryNotification"), object: nil)
        
        loadGroceryList()
    }
    
    func loadGroceryList () {
        // Check for token
        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            return
        }
        
        let headers: HTTPHeaders = ["authorization": "Token \(token)", "Content-Type": "application/json"]
        
        getGroceryItems(headers:headers) { response in
            switch response.result {
            case .success:
                guard let data = response.result.value else {
                    // Show error if we don't have any data
                    let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                // Parse JSON
                let json = JSON(data: data)
                let groceryArr:[[String: Any]] = json["results"].arrayValue.map { $0.dictionaryObject!}
                let groceryDict: [String: Any] = ["grocery": groceryArr]
                let groceries: [GroceryItem] = try! groceryDict.value(for: "grocery")
                
                self.groceryItems = groceries
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure:
                let alert = UIAlertController(title: "", message: "Network Error. Try Again.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func reloadItems() {
        self.groceryItems.removeAll()
        loadGroceryList()
    }
    
    // Come back to this for fractions
    func rationalApproximation(of x0 : Double, withPrecision eps : Double = 1.0E-6) -> Rational {
        var x = x0
        var a = x.rounded(.down)
        var (h1, k1, h, k) = (1, 0, Int(a), 1)
        
        while x - a > eps * Double(k) * Double(k) {
            x = 1.0/(x - a)
            a = x.rounded(.down)
            (h1, k1, h, k) = (h, k, h1 + Int(a) * h, k1 + Int(a) * k)
        }
        return (h, k)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groceryCell", for: indexPath) as! GroceryItemTableViewCell
        let quantity = groceryItems[indexPath.row].quantity
        
        cell.itemQuantityLabel.text = quantity
        
        cell.itemNameLabel.text = groceryItems[indexPath.row].item
        
        return cell
    }


}
