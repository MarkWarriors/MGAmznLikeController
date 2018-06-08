//
//  MGAmznLikeController.swift
//  MGAmznLikeController
//
//  Created by Marco Guerrieri on 08/06/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import AudioToolbox
import UIKit

@IBDesignable
open class MGAmznLikeController: UIView {
    
    private enum ActionTriggered : Int {
        case noAction
        case topAction
        case leftAction
        case rightAction
    }
    
    private enum ControlMovement : Int {
        case noMovement
        case vertical
        case horizontal
    }
    
    private enum ControlStatus : Int {
        case play
        case pause
    }

    @IBOutlet weak var fullContainerView: UIView!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var horizontalActionView: UIView!
    @IBOutlet weak var subControllerView: UIView!
    @IBOutlet weak var controllerView: UIView!
    
    @IBOutlet weak var controllerBckgImg: UIImageView!
    @IBOutlet weak var controllerCentralImg: UIImageView!
    @IBOutlet weak var horizontalActionLeftImage: UIImageView!
    @IBOutlet weak var horizontalActionRightImage: UIImageView!
    
    @IBOutlet weak var horizontalActionLeftCnstr: NSLayoutConstraint!
    @IBOutlet weak var horizontalActionRightCnstr: NSLayoutConstraint!
    @IBOutlet weak var subcontrollerHeightCnstr: NSLayoutConstraint!
    @IBOutlet weak var controllerVertCenterCnstr: NSLayoutConstraint!
    @IBOutlet weak var controllerHoriCenterCnstr: NSLayoutConstraint!


    private var actionTriggered : ActionTriggered = .noAction
    private var controlMovement : ControlMovement = .noMovement
    private var controlStatus : ControlStatus = .pause
    private var panGesture : UIPanGestureRecognizer?
    private var maxHorizontalMovement : CGFloat = 0
    private let horizontalTriggerPoint : CGFloat = 50
    private let maxVerticalMovement : CGFloat = 150
    private let verticalTriggerPoint : CGFloat = 50
    
    private var closedSubcontrollerHeight : CGFloat = 0
    private var openedSubcontrollerHeight : CGFloat = 80

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let view : UIView? = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)![0] as? UIView
        if view != nil {
            addSubview(view!)
            view?.frame = self.bounds
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    private func xibSetup(){
        self.subControllerView.alpha = 0
        self.controllerView.isUserInteractionEnabled = true
        self.controllerBckgImg.isUserInteractionEnabled = true
        self.openedSubcontrollerHeight = self.subcontrollerHeightCnstr.constant
        self.maxHorizontalMovement = self.controllerView.frame.origin.x / 2.5
        self.panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(pan(recognizer:)))
        self.controllerView.addGestureRecognizer(panGesture!)
        self.controllerBckgImg.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap(recognizer:))))
        self.controllerBckgImg.addGestureRecognizer(UILongPressGestureRecognizer.init(target: self, action: #selector(longPress(recognizer:))))
        self.resetController()
        self.closeSubController(animated: false)
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(
            withOwner: self,
            options: nil).first as? UIView
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        fullContainerView?.prepareForInterfaceBuilder()
        tabBarView?.prepareForInterfaceBuilder()
        horizontalActionView?.prepareForInterfaceBuilder()
        subControllerView?.prepareForInterfaceBuilder()
        controllerView?.prepareForInterfaceBuilder()
        controllerBckgImg?.prepareForInterfaceBuilder()
        controllerCentralImg?.prepareForInterfaceBuilder()
        horizontalActionLeftImage?.prepareForInterfaceBuilder()
        horizontalActionRightImage?.prepareForInterfaceBuilder()
    }


    private func toggleSubcontroller(forceOpen: Bool = false) {
        if self.subcontrollerHeightCnstr.constant == self.closedSubcontrollerHeight || forceOpen {
            // OPEN
            openSubController(animated: true)
        }
        else {
            // CLOSE
            closeSubController(animated: true)
        }
    }

    private func openSubController(animated: Bool){
        self.subControllerView.isHidden = false
        UIView.animate(withDuration: animated ? 0.25 : 0.0,
                       delay: 0,
                       usingSpringWithDamping: 0.35,
                       initialSpringVelocity: 0.35,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.subControllerView.cornerRadius = (self.controllerView.frame.size.height / 2 + self.openedSubcontrollerHeight / 2)
                        self.subcontrollerHeightCnstr.constant = self.openedSubcontrollerHeight
                        self.fullContainerView.layoutSubviews()
                        
        }, completion: { (value: Bool) in
        })
    }

    private func closeSubController(animated: Bool){
        UIView.animate(withDuration: animated ? 0.055 : 0.0, animations: {
            self.subControllerView.cornerRadius = self.controllerView.frame.size.height / 2
            self.subcontrollerHeightCnstr.constant = self.closedSubcontrollerHeight
            self.fullContainerView.layoutSubviews()
        }) { (success) in
            self.subControllerView.isHidden = true
        }
    }

    @objc func tap(recognizer: UIPanGestureRecognizer) {
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


    @objc func longPress(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            self.vibrate()
            toggleSubcontroller()
        }
    }

    func resetController() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 1,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        self.controllerVertCenterCnstr.constant = 0
                        self.controllerHoriCenterCnstr.constant = 0
                        self.fullContainerView.layoutSubviews()
        }, completion: {
            //Code to run after animating
            (value: Bool) in
        })
        self.horizontalActionRightCnstr.constant = -self.controllerView.frame.size.width / 2
        self.horizontalActionLeftCnstr.constant = self.controllerView.frame.size.width / 2
        self.horizontalActionView.alpha = 0
        self.subControllerView.alpha = 0.8
        self.controllerView.alpha = 1
        self.controlMovement = .noMovement
        self.actionTriggered = .noAction
        self.panGesture!.isEnabled = true
    }


    @objc func pan(recognizer: UIPanGestureRecognizer) {
        let yMove = max(0, -recognizer.translation(in: self).y)
        let xMove = recognizer.translation(in: self).x
        if recognizer.state == UIGestureRecognizerState.changed {
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
            
            if self.subcontrollerHeightCnstr.constant > 0 && self.controlMovement == .horizontal {
                self.controlMovement = .noMovement
                return
            }
            
            switch self.controlMovement{
            case .horizontal:
                let controllerMove = xMove / 2.5
                self.controllerHoriCenterCnstr.constant = controllerMove
                self.horizontalActionView.alpha = min(abs(controllerMove/(self.maxHorizontalMovement)), 0.9)
                
                if xMove > 0 {
                    self.horizontalActionLeftImage.isHidden = true
                    self.horizontalActionRightImage.isHidden = false
                    self.horizontalActionRightCnstr.constant = min(self.maxHorizontalMovement*1.5, xMove * 1.2 )
                    self.horizontalActionLeftCnstr.constant = self.controllerView.frame.size.width / 2
                    
                    if self.actionTriggered != .rightAction && xMove > horizontalTriggerPoint {
                        self.actionTriggered = .rightAction
                        self.vibrate()
                    }
                    else if self.actionTriggered == .rightAction && xMove < horizontalTriggerPoint{
                        self.actionTriggered = .noAction
                    }
                }
                else {
                    self.horizontalActionLeftImage.isHidden = false
                    self.horizontalActionRightImage.isHidden = true
                    self.horizontalActionLeftCnstr.constant = max(-self.maxHorizontalMovement*1.5, xMove * 1.2)
                    self.horizontalActionRightCnstr.constant = -self.controllerView.frame.size.width / 2
                    
                    if self.actionTriggered != .leftAction && xMove < -horizontalTriggerPoint {
                        self.actionTriggered = .leftAction
                        self.vibrate()
                    }
                    else if self.actionTriggered == .leftAction && xMove > -horizontalTriggerPoint {
                        self.actionTriggered = .noAction
                    }
                }
                break
                
            case .vertical:
                self.controllerVertCenterCnstr.constant = max(-yMove, -self.maxVerticalMovement)
                self.controllerView.alpha = max(1-(abs(yMove)/self.maxVerticalMovement), 0)
                self.subControllerView.alpha = max(0.9-(abs(yMove)*0.9/self.maxVerticalMovement), 0)
                
                if self.actionTriggered != .topAction && abs(yMove) > verticalTriggerPoint {
                    self.actionTriggered = .topAction
                    self.vibrate()
                }
                else if self.actionTriggered == .topAction && abs(yMove) < verticalTriggerPoint {
                    self.actionTriggered = .noAction
                }
                else if abs(yMove) >= self.maxVerticalMovement * 2 {
                    controlDidEndMove(toggleSubControl: false)
                }
                break
                
            default:
                break
            }
        }
        else if recognizer.state == UIGestureRecognizerState.ended {
            self.controlDidEndMove(toggleSubControl: controlMovement == .vertical && self.actionTriggered == .noAction)
        }
        
    }

    func controlDidEndMove(toggleSubControl: Bool) {
        if toggleSubControl {
            self.toggleSubcontroller(forceOpen: false)
        }
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

    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    func leftActionTriggered() {
        print("LEFT ACTION TRIGGERED")
    }

    func rightActionTriggered() {
        print("RIGHT ACTION TRIGGERED")
    }

    func topActionTriggered() {
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
