//
//  TestXibVC.swift
//  MGAmznLikeController
//
//  Created by Marco Guerrieri on 08/06/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class TestXibVC: UIViewController, MGALCDelegate {

    @IBOutlet weak var mgController: MGAmznLikeController!
    @IBOutlet weak var containerView: UIView!
    
    var navController: MGNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigation = segue.destination as? MGNavigationController {
            self.navController = navigation
        }
        self.navController!.mgController = self.mgController!
    }
    

    

}
