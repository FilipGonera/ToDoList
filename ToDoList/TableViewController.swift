//
//  ViewController.swift
//  lista
//
//  Created by Filip  Gonera on 10/07/2018.
//  Copyright © 2018 Filip  Gonera. All rights reserved.
//

import UIKit
import CoreData

var list: [NSManagedObject] = []

class TableViewController: UITableViewController, ButtonSelectionDelegate, SaveDelegate {

    let checkmarkBtn = CheckmarkBtn()
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,  action: #selector(addSegue))
        navigationItem.title = "List"
            
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editItems))
           
        let cellNib = UINib(nibName: "TableViewCell", bundle: nil)
        self.tableView.register(cellNib, forCellReuseIdentifier: "cell")
            
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        fetch()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    
    func save(name: String, state: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Item", in: managedObjectContext)!
        let Item = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        
        Item.setValue(name, forKeyPath: "name")
        Item.setValue(state, forKeyPath: "isChecked")
        do{
            try managedObjectContext.save()
            list.append(Item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func updateBtnState(state: Bool){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Item", in: managedObjectContext)!
        let Item = NSManagedObject(entity: entity, insertInto: managedObjectContext)
        
        Item.setValue(state, forKeyPath: "isChecked")
        do{
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
    }
    
    func fetch(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Item")
        
        do{
            list = try managedObjectContext.fetch(fetchRequest)
            for item in list {
                print(item.value(forKey: "isChecked")!)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func update(indexPath: IndexPath, name: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let item = list[indexPath.row]
        
        do{
            try managedObjectContext.save()
            list[indexPath.row] = item
           
        } catch let error as NSError {
            print("Couldnt update. \(error)")
        }
    }
    
    
    func delete(_ Item: NSManagedObject, at indexPath: IndexPath){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        let item = list[indexPath.row]
        
        managedObjectContext.delete(item)
        list.remove(at: indexPath.row)
        
        do{
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Couldnt update. \(error)")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list.count == 0 {
            self.tableView.setEmptyMessage("Add some items to your list!")
        } else {
            self.tableView.restore()
        }
        return(list.count)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let item = list[indexPath.row]
            
        cell.selectionDelegate = self
            
        cell.cellLabel.text = item.value(forKeyPath: "name") as? String
            
        // this configure button depending on Attribute value attached to it in CoreData
        var checkmarkBtnState: Bool
        checkmarkBtnState = item.value(forKeyPath: "isChecked") as! Bool
            
        if checkmarkBtnState == true{
            cell.checkmarkButton.setImage(checkmarkBtn.doneImage, for: .normal)
            cell.checkmarkButton.tintColor = checkmarkBtn.doneColor
        } else if checkmarkBtnState == false {
            cell.checkmarkButton.setImage(checkmarkBtn.notDoneImage, for: .normal)
            cell.checkmarkButton.tintColor = checkmarkBtn.notDoneColor
        }
        return cell
    }
    
    
    func updateTableView(){
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
       return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let item = list[indexPath.row]
                delete(item, at: indexPath)
                tableView.reloadData()
            }
        }
    }
   
    @objc func editItems(sender: UIBarButtonItem){
      tableView.setEditing(true, animated: true)
        if tableView.isEditing == true{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneButton))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editItems))
        }
    }
    
    @objc func doneButton(sender: UIBarButtonItem){
        tableView.setEditing(false, animated: true)
        if tableView.isEditing == false{
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(editItems))
        }
    }
    
    @objc func addSegue(){ // this opens InsertInfoViewController
        performSegue(withIdentifier: "AddItemSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "AddItemSegue"{
            let insertInfoVC = segue.destination as! InsertInfoViewController
            insertInfoVC.saveDelegate = self

        }
    }
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {}
}


extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "San Francisco", size: 18)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}





































