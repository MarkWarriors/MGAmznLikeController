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
        self.mgController.setControlBackgroundImage(UIImage.init(named: "doge.jpg"))
        self.mgController.setControlImage(UIImage.init(named: "play_icon.png"), forStatus: MGAmznLikeController.ControlStatus.play)
        self.mgController.setControlImage(UIImage.init(named: "pause_icon.png"), forStatus: MGAmznLikeController.ControlStatus.pause)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigation = segue.destination as? MGNavigationController {
            navController = navigation
        }
        self.mgController.delegate = navController
    }
    

    

}
