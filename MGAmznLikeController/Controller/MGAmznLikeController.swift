//
//  MGAmznLikeController.swift
//  MGAmznLikeController
//
//  Created by Marco Guerrieri on 08/06/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import AudioToolbox
import UIKit


@objc public protocol MGALCDelegate {
    @objc optional func didTapController(controllerStatus: MGAmznLikeController.ControllerStatus)
    @objc optional func didTapOnSubControllerAt(index: Int, sender: UIButton?)
    @objc optional func didTapOnTabBarAt(index: Int, sender: UIButton?)
    @objc optional func didPerformSwipeAction(trigger: MGAmznLikeController.ActionTriggered)
    @objc optional func didOpenSubController()
    @objc optional func didCloseSubController()
    @objc optional func willOpenSubController()
    @objc optional func willCloseSubController()
}

@IBDesignable
@objc open class MGAmznLikeController: UIView {
    
    @objc public enum ActionTriggered : Int {
        case noAction = -1
        case topAction = 1
        case leftAction = 2
        case rightAction = 3
    }
    
    private enum ControllerMovement : Int {
        case noMovement
        case vertical
        case horizontal
    }
    
    @objc public enum ControllerStatus : Int {
        case play = 1
        case pause = 0
    }

    @IBOutlet var containerView: UIView!
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

    @IBOutlet weak var firstSubControllerBnt: UIButton!
    @IBOutlet weak var secondSubControllerBnt: UIButton!
    @IBOutlet weak var thirdSubControllerBnt: UIButton!
    @IBOutlet weak var fourthSubControllerBnt: UIButton!
    
    @IBOutlet weak var firstTabBarBnt: UIButton!
    @IBOutlet weak var secondTabBarBnt: UIButton!
    @IBOutlet weak var thirdTabBarBnt: UIButton!
    @IBOutlet weak var fourthTabBarBnt: UIButton!
    

    private var actionTriggered : ActionTriggered = .noAction
    private var controllerMovement : ControllerMovement = .noMovement
    private var controllerStatus : ControllerStatus = .pause
    private var panGesture : UIPanGestureRecognizer?
    private var maxHorizontalMovement : CGFloat = 0
    private let horizontalTriggerPoint : CGFloat = 50
    private let maxVerticalMovement : CGFloat = 150
    private let verticalTriggerPoint : CGFloat = 50
    
    private var closedSubcontrollerHeight : CGFloat = 0
    private var openedSubcontrollerHeight : CGFloat = 80
    
    public private(set) var controllerImageForStatus : [ControllerStatus:UIImage] = [:]
    public private(set) var canVibrate : Bool = true
    public private(set) var vibrationType : UIImpactFeedbackGenerator.FeedbackStyle = .light
    
    public var delegate: MGALCDelegate?

    // MARK: LAYOUT INITIALIZATION
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        let customViewNib = loadFromNib()
        customViewNib.frame = bounds
        customViewNib.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        addSubview(customViewNib)
    }
    
    func loadFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
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
        self.subControllerView.mgalcCornerRadius = self.controllerView.frame.size.height / 2
        self.subcontrollerHeightCnstr.constant = self.closedSubcontrollerHeight
        self.controllerCentralImg.image = self.controllerImageForStatus[self.controllerStatus] ?? nil
    }
    

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
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

    
    // MARK: CALLABLE FUNCTIONS
    public func changeVibration(active: Bool, type: UIImpactFeedbackGenerator.FeedbackStyle? = nil){
        self.canVibrate = active
        self.vibrationType = type ?? .light
    }
    
    public func setControllerImage(_ image: UIImage?, forStatus status: ControllerStatus) {
        self.controllerImageForStatus[status] = image
        self.controllerCentralImg.image = self.controllerImageForStatus[self.controllerStatus] ?? nil
    }
    
    public func setControllerBackgroundImage(_ image: UIImage?) {
        self.controllerBckgImg.image = image
    }
    
    // MARK: PRIVATE METHODS (ALMOST)
    private func toggleSubcontroller(forceOpen: Bool = false) {
        if self.subcontrollerHeightCnstr.constant == self.closedSubcontrollerHeight || forceOpen {
            // OPEN
            self.delegate?.willOpenSubController?()
            openSubController(animated: true)
        }
        else {
            // CLOSE
            self.delegate?.willCloseSubController?()
            closeSubController(animated: true)
        }
    }

    private func openSubController(animated: Bool){
        self.subControllerView.isHidden = false
        UIView.animate(withDuration: animated ? 0.25 : 0.0,
                       delay: 0,
                       usingSpringWithDamping: 0.35,
                       initialSpringVelocity: 0.35,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
                        self.subControllerView.mgalcCornerRadius = (self.controllerView.frame.size.height / 2 + self.openedSubcontrollerHeight / 2)
                        self.subcontrollerHeightCnstr.constant = self.openedSubcontrollerHeight
                        self.fullContainerView.layoutSubviews()
                        
        }, completion: { (value: Bool) in
            self.delegate?.didOpenSubController?()
        })
    }

    private func closeSubController(animated: Bool){
        UIView.animate(withDuration: animated ? 0.055 : 0.0, animations: {
            self.subControllerView.mgalcCornerRadius = self.controllerView.frame.size.height / 2
            self.subcontrollerHeightCnstr.constant = self.closedSubcontrollerHeight
            self.fullContainerView.layoutSubviews()
        }) { (success) in
            self.subControllerView.isHidden = true
            self.delegate?.didCloseSubController?()
        }
    }

    @objc private func tap(recognizer: UIPanGestureRecognizer) {
        if controllerStatus == .pause {
            controllerStatus = .play
            controllerCentralImg.image = UIImage.init(named: "play_icon.png")
        }
        else {
            controllerStatus = .pause
            controllerCentralImg.image = UIImage.init(named: "pause_icon.png")
        }
        self.delegate?.didTapController?(controllerStatus: controllerStatus)
    }


    @objc private func longPress(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            self.vibrate()
            toggleSubcontroller()
        }
    }

    @objc public func resetController(animated: Bool = true) {
        UIView.animate(withDuration: animated ? 0.3 : 0,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 1,
                       options: UIView.AnimationOptions.curveEaseIn,
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
        self.controllerMovement = .noMovement
        self.actionTriggered = .noAction
        self.panGesture!.isEnabled = true
    }


    @objc private func pan(recognizer: UIPanGestureRecognizer) {
        let yMove = max(0, -recognizer.translation(in: self).y)
        let xMove = recognizer.translation(in: self).x
        if recognizer.state == UIGestureRecognizer.State.changed {
            if self.controllerMovement == .noMovement {
                if abs(yMove) > abs(xMove) {
                    self.controllerMovement = .vertical
                }
                else if abs(yMove) < abs(xMove) {
                    self.controllerMovement = .horizontal
                }
                else {
                    return
                }
            }
            
            if self.subcontrollerHeightCnstr.constant > 0 && self.controllerMovement == .horizontal {
                self.controllerMovement = .noMovement
                return
            }
            
            switch self.controllerMovement{
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
                    self.controllerDidEndMove()
                }
                break
                
            default:
                break
            }
        }
        else if recognizer.state == UIGestureRecognizer.State.ended {
            if controllerMovement == .vertical && self.actionTriggered == .noAction{
                self.toggleSubcontroller()
            }
            else if self.subcontrollerHeightCnstr.constant == self.openedSubcontrollerHeight {
                self.closeSubController(animated: true)
            }
            self.controllerDidEndMove()
        }
        
    }

    private func controllerDidEndMove() {
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

    private func vibrate() {
        if canVibrate {
            let generator = UIImpactFeedbackGenerator(style: vibrationType)
            generator.impactOccurred()
        }
    }

    private func leftActionTriggered() {
        self.delegate?.didPerformSwipeAction?(trigger: .leftAction)
    }

    private func rightActionTriggered() {
        self.delegate?.didPerformSwipeAction?(trigger: .rightAction)
    }

    private func topActionTriggered() {
        self.delegate?.didPerformSwipeAction?(trigger: .topAction)
    }

    @IBAction func firstTabBarPressed(_ sender: Any) {
        self.delegate?.didTapOnTabBarAt?(index: 0, sender: sender as? UIButton)
    }

    @IBAction func secondTabBarPressed(_ sender: Any) {
        self.delegate?.didTapOnTabBarAt?(index: 1, sender: sender as? UIButton)
    }

    @IBAction func thirdTabBarPressed(_ sender: Any) {
        self.delegate?.didTapOnTabBarAt?(index: 2, sender: sender as? UIButton)
    }

    @IBAction func fourthTabBarPressed(_ sender: Any) {
        self.delegate?.didTapOnTabBarAt?(index: 3, sender: sender as? UIButton)
    }

    @IBAction func firstSubControlPressed(_ sender: Any) {
        self.delegate?.didTapOnSubControllerAt?(index: 0, sender: sender as? UIButton)
    }

    @IBAction func secondSubControlPressed(_ sender: Any) {
        self.delegate?.didTapOnSubControllerAt?(index: 1, sender: sender as? UIButton)
    }

    @IBAction func thirdSubControlPressed(_ sender: Any) {
        self.delegate?.didTapOnSubControllerAt?(index: 2, sender: sender as? UIButton)
    }

    @IBAction func fourthSubControlPressed(_ sender: Any) {
        self.delegate?.didTapOnSubControllerAt?(index: 3, sender: sender as? UIButton)
    }
    
}


fileprivate extension UIView {
    
    @IBInspectable var mgalcCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var mgalcRoundView: Bool {
        get {
            return self.mgalcRoundView
        }
        set {
            layer.cornerRadius = self.frame.height/2
            layer.masksToBounds = true
        }
    }
    
}
