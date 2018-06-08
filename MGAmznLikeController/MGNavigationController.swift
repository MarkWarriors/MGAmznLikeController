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
    private var modalVC : UIViewController?
    
    private var dogeImages : [UIImage?] = [
        UIImage.init(named: "doge.jpg"),
        UIImage.init(named: "doge2.jpg"),
        UIImage.init(named: "doge3.jpg"),
        UIImage.init(named: "doge4.jpg"),
        UIImage.init(named: "doge5.jpg"),
        UIImage.init(named: "doge6.jpg"),
    ]
    
    public var mgController: MGAmznLikeController?{
        didSet {
            self.mgController!.delegate = self
            self.mgController!.setControlBackgroundImage(dogeImages[0])
            self.mgController!.setControlImage(UIImage.init(named: "play_icon.png"), forStatus: MGAmznLikeController.ControlStatus.play)
            self.mgController!.setControlImage(UIImage.init(named: "pause_icon.png"), forStatus: MGAmznLikeController.ControlStatus.pause)
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard.init(name: "Main", bundle: self.nibBundle)
        self.firstVC = storyboard.instantiateViewController(withIdentifier: "firstVC") as? FirstVC
        self.secondVC = storyboard.instantiateViewController(withIdentifier: "secondVC")
        self.thirdVC = storyboard.instantiateViewController(withIdentifier: "thirdVC")
        self.fourthVC = storyboard.instantiateViewController(withIdentifier: "fourthVC")
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "modalVC")
        self.viewControllers.append(firstVC!)
    }
    
    private func showModalView(){
        self.performSegue(withIdentifier: "segueToModal", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToModal" {
            let modal = segue.destination as! ModalVC
            modal.dogeImages = self.dogeImages
        }
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
        switch trigger {
        case .topAction:
            showModalView()
            break
        case .leftAction:
            var previousIndex = (self.dogeImages.index(of: self.mgController?.controllerBckgImg.image) ?? 1) - 1
            if previousIndex == -1 {
                previousIndex = self.dogeImages.count - 1
            }
            self.mgController?.setControlBackgroundImage(dogeImages[previousIndex])
            break
        case .rightAction:
            var nextIndex = (self.dogeImages.index(of: self.mgController?.controllerBckgImg.image) ?? -1) + 1
            if nextIndex == self.dogeImages.count {
                nextIndex = 0
            }
            self.mgController?.setControlBackgroundImage(dogeImages[nextIndex])
            break
        case .noAction:
            break
        }
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
