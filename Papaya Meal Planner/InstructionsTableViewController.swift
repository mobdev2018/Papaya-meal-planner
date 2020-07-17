//
//  InstructionsTableViewController.swift
//  PapayaMealPlanner
//
//  Created by Norton Gumbo on 11/27/16.
//  Copyright © 2016 Papaya LC. All rights reserved.
//

import UIKit

class InstructionsTableViewController: UITableViewController {
    
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 55
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = recipe!.instructions.count
        
        return count+1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        
        if row == 0 {
            
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "instructionsHeaderCell", for: indexPath)
            
            return headerCell;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "instructionsCell", for: indexPath) as! InstructionsTableViewCell
        
        cell.lblCounter.text = NSString.localizedStringWithFormat("%d", row) as String
        let instructions = recipe!.instructions
        let singleInstruction = instructions[row - 1]
        cell.lblTitle?.text = singleInstruction.description
        return cell
        
    }

}
