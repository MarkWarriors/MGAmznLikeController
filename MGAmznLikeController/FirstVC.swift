//
//  FirstVC.swift
//  MGAmznLikeController
//
//  Created by Marco Guerrieri on 08/06/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class FirstVC: UIViewController {
    
    @IBOutlet weak var logTF: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTF.inputView = UIView()
        logTF.inputAccessoryView = UIView()
    }
    
    public func printLog(text: String){
        DispatchQueue.main.async {
            if self.logTF.text.count > 0 && text != "" {
                self.logTF.text.append("\n")
            }
            self.logTF.text.append(text)
            let range = NSMakeRange(self.logTF.text.count - 1, 1);
            self.logTF.scrollRangeToVisible(range);
        }
    }
    
    @IBAction func cleanBtnPressed(_ sender: Any) {
        self.logTF.text = ""
        self.logTF.scrollRectToVisible(CGRect.zero, animated: false)
    }

}
