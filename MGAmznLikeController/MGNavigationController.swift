//
//  MGNavigationController.swift
//  MGAmznLikeController
//
//  Created by Marco Guerrieri on 08/06/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class MGNavigationController: UINavigationController, MGALCDelegate {

    private var firstVC : FirstVC?
    private var secondVC : UIViewController?
    private var thirdVC : UIViewController?
    private var fourthVC : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard.init(name: "Main", bundle: self.nibBundle)
        firstVC = storyboard.instantiateViewController(withIdentifier: "firstVC") as? FirstVC
        secondVC = storyboard.instantiateViewController(withIdentifier: "secondVC")
        thirdVC = storyboard.instantiateViewController(withIdentifier: "thirdVC")
        fourthVC = storyboard.instantiateViewController(withIdentifier: "fourthVC")
        self.viewControllers.append(firstVC!)
    }
    
    
    private func printLogIfIsInFirstVC(_ text: String){
        if let first = self.firstVC {
            first.printLog(text: text)
        }
    }
    
    func didTapController(controlStatus: MGAmznLikeController.ControlStatus) {
        printLogIfIsInFirstVC("TAP CONTROLLER: \(controlStatus.rawValue)")
    }
    
    func didTapOnSubControllerAt(index: Int, sender: UIButton?) {
        printLogIfIsInFirstVC("TAP SUB CONTROLLER: \(index)")
    }
    
    func didTapOnTabBarAt(index: Int, sender: UIButton?) {
        printLogIfIsInFirstVC("TAP TABBAR: \(index)")
        switch index {
        case 0:
            self.viewControllers.removeAll()
            self.viewControllers.append(firstVC!)
            break
        case 1:
            self.viewControllers.removeAll()
            self.viewControllers.append(secondVC!)
            break
        case 2:
            self.viewControllers.removeAll()
            self.viewControllers.append(thirdVC!)
            break
        case 3:
            self.viewControllers.removeAll()
            self.viewControllers.append(fourthVC!)
            break
        default:
            break
        }
    }
    
    func didPerformSwipeAction(trigger: MGAmznLikeController.ActionTriggered) {
        printLogIfIsInFirstVC("SWIPE ACTION TRIGGERED: \(trigger.rawValue)")
    }
    
    func didOpenSubController() {
        printLogIfIsInFirstVC("DID OPEN SUB CONTROLLER")
    }
    
    func didCloseSubController() {
        printLogIfIsInFirstVC("DID CLOSE SUB CONTROLLER")
    }
    
    func willOpenSubController() {
        printLogIfIsInFirstVC("WILL OPEN SUB CONTROLLER")
    }
    
    func willCloseSubController() {
        printLogIfIsInFirstVC("WILL CLOSE SUB CONTROLLER")
    }
}
