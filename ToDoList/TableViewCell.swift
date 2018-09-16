//
//  TableViewCell.swift
//  lista
//
//  Created by Filip  Gonera on 10/08/2018.
//  Copyright © 2018 Filip  Gonera. All rights reserved.
//

import UIKit
import CoreData

protocol ButtonSelectionDelegate: class {
    func fetch()
    func updateTableView()
}

class TableViewCell: UITableViewCell  {    
    
    let checkmarkBtn = CheckmarkBtn()
    
    weak var selectionDelegate: ButtonSelectionDelegate!
    
    @IBOutlet  var checkmarkButton: UIButton!
    @IBOutlet  var cellLabel: UILabel!
   
    @IBAction func checkmarkBtnTapped(_ sender: UIButton) {
        let item = list[indexPath!.row]
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let doneCheckmarkButton = checkmarkButton.currentImage?.isEqual(checkmarkBtn.doneImage)
        let notDoneCheckmarkButton = checkmarkButton.currentImage?.isEqual(checkmarkBtn.notDoneImage)
        
        // this checks current icon image of the button, which represents value of Atrribute in Core Data for this item, then it changes value of the Attribute to opposite, and reload TableView that takes care of updating icon for the button
        if  doneCheckmarkButton! {
            item.setValue(false, forKey: "isChecked")
            selectionDelegate?.updateTableView()
            print("Button value changed to false")
        } else if notDoneCheckmarkButton! {
            item.setValue(true, forKey: "isChecked")
            selectionDelegate?.updateTableView()
            print("Button value changed to true")
        }
        
        do{
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// this extensions allows us to access list[indexPath.row] from TableViewController
extension UIResponder {

    func next<T: UIResponder>(_ type: T.Type) -> T? {
        return next as? T ?? next?.next(type)
    }
}

extension UITableViewCell {
    
    var tableView: UITableView? {
        return next(UITableView.self)
    }
    
    var indexPath: IndexPath? {
        return tableView?.indexPath(for: self)
    }
}


















