//
//  ViewController.swift
//  MGAmznLikeController
//
//  Created by Marco Guerrieri on 07/06/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import AudioToolbox
import UIKit

class ViewController: UIViewController {
    
    enum ActionTriggered : Int {
        case noAction
        case topAction
        case leftAction
        case rightAction
    }
    
    enum ControlMovement : Int {
        case noMovement
        case vertical
        case horizontal
    }
    
    enum ControlStatus : Int {
        case play
        case pause
    }
    
    @IBOutlet weak var horizontalActionLeftCnstr: NSLayoutConstraint!
    @IBOutlet weak var horizontalActionRightCnstr: NSLayoutConstraint!
    @IBOutlet weak var horizontalActionView: UIView!
    @IBOutlet weak var horizontalActionLeftImage: UIImageView!
    @IBOutlet weak var horizontalActionRightImage: UIImageView!
    @IBOutlet weak var controllerView: UIView!
    @IBOutlet weak var subControllerView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var controllerVertCenterCnstr: NSLayoutConstraint!
    @IBOutlet weak var controllerHoriCenterCnstr: NSLayoutConstraint!
    
    @IBOutlet weak var controllerBckgImg: UIImageView!
    @IBOutlet weak var controllerCentralImg: UIImageView!
    
    var actionTriggered : ActionTriggered = .noAction
    var controlMovement : ControlMovement = .noMovement
    var controlStatus : ControlStatus = .pause
    var panGesture : UIPanGestureRecognizer?
    var maxHorizontalMovement : CGFloat = 0
    let maxVerticalMovement : CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subControllerView.alpha = 0
        self.controllerView.isUserInteractionEnabled = true
        self.controllerBckgImg.isUserInteractionEnabled = true
        self.panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(pan(recognizer:)))
        self.controllerView.addGestureRecognizer(panGesture!)
        self.controllerBckgImg.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap(recognizer:))))
        self.controllerBckgImg.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(recognizer:))))
       
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetController()
        self.maxHorizontalMovement = self.controllerView.frame.origin.x / 3
    }
    
    @objc func tap(recognizer: UIPanGestureRecognizer){
        if controlStatus == .pause {
            print("PLAY")
            controlStatus = .play
            controllerCentralImg.image = UIImage.init(named: "play_icon.png")
        }
        else {
            controlStatus = .pause
            controllerCentralImg.image = UIImage.init(named: "pause_icon.png")
            print("PAUSE")
        }
    }
    
    
    @objc func longPress(recognizer: UIPanGestureRecognizer){
        if recognizer.state == .began {
            self.vibrate()
            self.subControllerView.isHidden = !self.subControllerView.isHidden
        }
    }

    func resetController(){
        UIView.animate(withDuration: TimeInterval(0.3),
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.controllerVertCenterCnstr.constant = 0
                        self.controllerHoriCenterCnstr.constant = 0
                        self.view.layoutSubviews()
        }, completion: {
            //Code to run after animating
            (value: Bool) in
        })
        self.horizontalActionRightCnstr.constant = -self.controllerView.frame.size.width / 2
        self.horizontalActionLeftCnstr.constant = self.controllerView.frame.size.width / 2
        self.horizontalActionView.alpha = 0
        self.subControllerView.alpha = 0.8
        self.subControllerView.isHidden = true
        self.controllerView.alpha = 1
        self.controlMovement = .noMovement
        self.actionTriggered = .noAction
        self.panGesture!.isEnabled = true
    }

    
    @objc func pan(recognizer: UIPanGestureRecognizer){
        let yMove = max(0, -recognizer.translation(in: self.view).y)
        let xMove = recognizer.translation(in: self.view).x
        
        if self.controlMovement == .noMovement {
            if abs(yMove) > abs(xMove) {
                self.controlMovement = .vertical
            }
            else if abs(yMove) < abs(xMove) {
                self.controlMovement = .horizontal
            }
            else {
                return
            }
        }
        
        if !self.subControllerView.isHidden && self.controlMovement == .horizontal {
            self.controlMovement = .noMovement
            return
        }
        

        if recognizer.state == UIGestureRecognizerState.ended {
            self.controlDidEndMove()
        }
        else {
            switch self.controlMovement{
            case .horizontal:
                let controllerMove = xMove / 3
                self.controllerHoriCenterCnstr.constant = controllerMove
                self.horizontalActionView.alpha = min(abs(controllerMove/(self.maxHorizontalMovement)), 0.8)
                
                if xMove > 0 {
                    self.horizontalActionLeftImage.isHidden = true
                    self.horizontalActionRightImage.isHidden = false
                    self.horizontalActionRightCnstr.constant = min(self.maxHorizontalMovement * 2, xMove * 2)
                    self.horizontalActionLeftCnstr.constant = self.controllerView.frame.size.width / 2
                    
                    if self.actionTriggered != .rightAction && xMove > (self.maxHorizontalMovement / 2) {
                       self.actionTriggered = .rightAction
                        self.vibrate()
                    }
                    else if self.actionTriggered == .rightAction && xMove < (self.maxHorizontalMovement / 2){
                        self.actionTriggered = .noAction
                    }
                }
                else {
                    self.horizontalActionLeftImage.isHidden = false
                    self.horizontalActionRightImage.isHidden = true
                    self.horizontalActionLeftCnstr.constant = max(-self.maxHorizontalMovement * 2, xMove * 2)
                    self.horizontalActionRightCnstr.constant = -self.controllerView.frame.size.width / 2
                    
                    if self.actionTriggered != .leftAction && xMove < -(self.maxHorizontalMovement / 2) {
                        self.actionTriggered = .leftAction
                        self.vibrate()
                    }
                    else if self.actionTriggered == .leftAction && xMove > -(self.maxHorizontalMovement / 2) {
                        self.actionTriggered = .noAction
                    }
                }
                break
                
            case .vertical:
                self.controllerVertCenterCnstr.constant = max(-yMove, -self.maxVerticalMovement)
                self.controllerView.alpha = max(1-(abs(yMove)/self.maxVerticalMovement), 0)
                if !self.subControllerView.isHidden {
                    self.subControllerView.alpha = max(0.8-(abs(yMove)*0.8/self.maxVerticalMovement), 0)
                }
                
                if self.actionTriggered != .topAction && abs(yMove) > self.maxVerticalMovement/2 {
                    self.actionTriggered = .topAction
                    self.vibrate()
                }
                else if self.actionTriggered == .topAction && abs(yMove) < self.maxVerticalMovement/2{
                    self.actionTriggered = .noAction
                }
                else if abs(yMove) >= self.maxVerticalMovement * 2 {
                    controlDidEndMove()
                }
                break
                
            default:
                break
            }

        }
    }
    
    func controlDidEndMove(){
        self.panGesture!.isEnabled = false
        self.vibrate()
        switch self.actionTriggered{
        case .topAction:
            self.topActionTriggered()
            break
            
        case .leftAction:
            self.leftActionTriggered()
            break
            
        case .rightAction:
            self.rightActionTriggered()
            break
            
        default:
            break
        }
        self.resetController()
    }
    
    func vibrate(){
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func leftActionTriggered(){
        print("LEFT ACTION TRIGGERED")
    }
    
    func rightActionTriggered(){
        print("RIGHT ACTION TRIGGERED")
    }
    
    func topActionTriggered(){
        print("TOP ACTION TRIGGERED")
    }
    
    @IBAction func firstTabBarPressed(_ sender: Any) {
        print("FIRST TAB BAR PRESSED")
    }
    
    @IBAction func secondTabBarPressed(_ sender: Any) {
        print("SECOND TAB BAR PRESSED")
    }
    
    @IBAction func thirdTabBarPressed(_ sender: Any) {
        print("THIRD TAB BAR PRESSED")
    }
    
    @IBAction func fourthTabBarPressed(_ sender: Any) {
        print("FOURTH TAB BAR PRESSED")
    }
    
    @IBAction func firstSubControlPressed(_ sender: Any) {
        print("FIRST SUB CONTROL PRESSED")
    }
    
    @IBAction func secondSubControlPressed(_ sender: Any) {
        print("SECOND SUB CONTROL PRESSED")
    }
    
    @IBAction func thirdSubControlPressed(_ sender: Any) {
        print("THIRD SUB CONTROL PRESSED")
    }
    
    @IBAction func fourthSubControlPressed(_ sender: Any) {
        print("FOURTH SUB CONTROL PRESSED")
    }
}

