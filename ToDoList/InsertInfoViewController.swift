//
//  InsertInfoViewController.swift
//  lista
//
//  Created by Filip  Gonera on 10/08/2018.
//  Copyright © 2018 Filip  Gonera. All rights reserved.
//

import UIKit
import CoreData

protocol SaveDelegate: class {
    func save(name: String, state: Bool)
    func updateTableView()
}

class InsertInfoViewController: UIViewController, UITextViewDelegate {

    let checkmarkBtn = CheckmarkBtn()
    
    weak var saveDelegate: SaveDelegate!
    
    @IBOutlet var fakeBtnImage: UIImageView!
    @IBOutlet var textField: UITextField!
    @IBAction func TextfFieldAction(_ sender: Any) {
    }
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {}
    @IBOutlet var textView: UITextView!
    
    
    @IBOutlet var doneBtn: UIBarButtonItem!
    @IBAction func cancelBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "backToTableViewController", sender: self)
    }
    
    @IBAction func DoneBtnTapped(_ sender: Any) {
        let nameToSave = textView.text
        saveDelegate?.save(name: nameToSave!, state: false)
        saveDelegate?.updateTableView()
        performSegue(withIdentifier: "backToTableViewController", sender: self)
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        //this loads placeholder
        textView.text = "Add item to list"
        textView.textColor = UIColor.lightGray
        if textView.text == "Add item to list" { //this disables option to save empty string
            doneBtn.isEnabled = false
        }
        
        textView.becomeFirstResponder()
        
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Add Item"
        
        fakeBtnImage.image = checkmarkBtn.notDoneImage
        fakeBtnImage.tintColor = checkmarkBtn.notDoneColor
        
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool { //this takes care of placeholder behavior
        let currentText: String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        if updatedText.isEmpty {
            doneBtn.isEnabled = false //this disable option to save empty string
            
            textView.text = "Add item to list"
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        } else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
            
            doneBtn.isEnabled = true
        } else {
            return true
        }
        
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
