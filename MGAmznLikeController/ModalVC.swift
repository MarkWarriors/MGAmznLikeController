//
//  ModalVC.swift
//  MGAmznLikeController
//
//  Created by Marco Guerrieri on 08/06/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

class ModalVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    public var dogeImages : [UIImage?]?
    
    private enum Stuff : Int {
        case noMovement
        case vertical
        case horizontal
    }
    
    private var controlMovement : Stuff = .noMovement
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(pan(recognizer:))))
        self.imageView.image = dogeImages![0]
        
    }

    @objc private func pan(recognizer: UIPanGestureRecognizer) {
        let yMove = -recognizer.translation(in: self.view).y
        let xMove = recognizer.translation(in: self.view).x
        if recognizer.state == UIGestureRecognizerState.ended {
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
            

            switch self.controlMovement{
            case .horizontal:
                if xMove > 30 {
                    var nextIndex = (self.dogeImages!.index(of: self.imageView.image) ?? -1) + 1
                    if nextIndex == self.dogeImages!.count {
                        nextIndex = 0
                    }
                    self.imageView.image = dogeImages![nextIndex]
                }
                else if xMove < 30{
                    var previousIndex = (self.dogeImages!.index(of: self.imageView.image) ?? 1) - 1
                    if previousIndex == -1 {
                        previousIndex = self.dogeImages!.count - 1
                    }
                    self.imageView.image = dogeImages![previousIndex]
                }
                break
                
            case .vertical:
                if abs(yMove) >= 30 {
                    self.dismiss(animated: true, completion: nil)
                }
                break
                
            default:
                break
            }
            self.controlMovement = .noMovement
        }

        
    }

}
