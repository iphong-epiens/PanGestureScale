//
//  ViewController.swift
//  panscale
//
//  Created by Inpyo Hong on 2022/02/23.
//

import UIKit

enum ResizeOption: Int {
    case smaller = 0, bigger, none
}

class ViewController: UIViewController {
    @IBOutlet weak var targetImgView: UIImageView!
    @IBOutlet weak var enlargeImgView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    
    var targetPanGesture = UIPanGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    private var lastSwipeBeginningPoint: CGPoint?
    private var targetImg = UIImage(named: "mandalorian")!
    private var targetImgSize = CGSize(width: 0, height: 0)
    private var targetImgRatio: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        closeBtn.layer.cornerRadius = closeBtn.frame.width/2
        closeBtn.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.origin.y + 5)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragImg))
        enlargeImgView.addGestureRecognizer(panGesture)
        
        enlargeImgView.isUserInteractionEnabled = true
        enlargeImgView.layer.cornerRadius = enlargeImgView.frame.width/2
        enlargeImgView.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.maxY - 5)
        
        targetPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragTargetImg))
        targetImgView.addGestureRecognizer(targetPanGesture)
        
        targetImgView.isUserInteractionEnabled = true
        targetImgView.layer.borderColor = UIColor.gray.cgColor
        targetImgView.layer.borderWidth = 1

        targetImgSize = targetImg.size
        targetImgRatio = max(targetImgSize.width, targetImgSize.height)
        
        print("targetImgRatio", targetImgRatio)
    }
    
    @objc func dragImg(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        
        print("translation",translation)
        
        if sender.state == .began {
            lastSwipeBeginningPoint = sender.location(in: sender.view)
        } else { //if sender.state == .ended {
            guard let beginPoint = lastSwipeBeginningPoint else {
                return
            }
            
            let endPoint = sender.location(in: sender.view)
            // TODO: use the x and y coordinates of endPoint and beginPoint to determine which direction the swipe occurred.
            
            let resizeCondition = isResizeTargetView(beginPoint: beginPoint,
                                                     endPoint: endPoint)
            
            guard resizeCondition != .none else { return }
            
            let distance = CGPointDistance(from: beginPoint, to: endPoint)
            
            let bottomTrailingPoint = CGPoint(x: enlargeImgView.center.x + translation.x, y: enlargeImgView.center.y + translation.y)
            
            let resultRect = resizeTargetView(resizeCondition,
                                              distance: distance,
                                              bottomTrailingPoint: bottomTrailingPoint)
            
            let lastCenterPos = targetImgView.center
            
            UIView.animate(withDuration: 0, delay: 0.1, options: .curveEaseOut) { [weak self] in
                guard let self = self else { return }
                self.targetImgView.frame = resultRect
                self.targetImgView.center = lastCenterPos
                
                self.enlargeImgView.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.maxY - 5)
                self.closeBtn.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.origin.y + 5)
            }
            
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc func dragTargetImg(_ sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        
        UIView.animate(withDuration: 0, delay: 0.1, options: .curveEaseOut) { [weak self] in
            guard let self = self else { return }
            self.targetImgView.center = CGPoint(x: self.targetImgView.center.x + translation.x, y: self.targetImgView.center.y + translation.y)
            
            self.enlargeImgView.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.maxY - 5)
            self.closeBtn.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.origin.y + 5)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func isResizeTargetView(beginPoint: CGPoint, endPoint: CGPoint) -> ResizeOption {
        var resizeOption: ResizeOption = .none
        
        var isLeft = false, isRight = false, isUp = false, isDown = false
        
        if endPoint.x > beginPoint.x {
            isRight = true
        }
        if endPoint.x < beginPoint.x {
            isLeft = true
        }
        
        if endPoint.y > beginPoint.y {
            isDown = true
        }
        
        if endPoint.y < beginPoint.y {
            isUp = true
        }
        
        if isLeft && isUp {
            print("smaller")
            resizeOption = .smaller
        }
        else if isRight && isDown {
            print("bigger")
            resizeOption = .bigger
        }
        
        return resizeOption
    }
    
    func resizeTargetView(_ resizeOption: ResizeOption, distance: CGFloat, bottomTrailingPoint: CGPoint) -> CGRect {
        var resultRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        var resultWidth: CGFloat = 0
        var resultHeight: CGFloat = 0
        
        var resultSize = CGSize(width: 0, height: 0)
        var resultOrigin = CGPoint(x: 0, y: 0)
        
        let lastOuterImgFrame = targetImgView.frame
        
        switch resizeOption {
        case .smaller:
            let changedWidth = lastOuterImgFrame.width - (distance * 2)
        
            let minLength = targetImgSize.width * 0.25
            var targetLength: CGFloat = 0

            if changedWidth > minLength {
                targetLength = changedWidth
            } else {
                print("too small!")
                targetLength = minLength
            }
            
            let scaleFactor = targetLength / targetImgRatio

            resultWidth = targetImgSize.width * scaleFactor
            resultHeight = targetImgSize.height * scaleFactor
            
        case .bigger:
            let changedWidth = lastOuterImgFrame.width + (distance * 2)

            let maxLength = UIScreen.main.bounds.width * 0.75
            var targetLength: CGFloat = 0
            
            if changedWidth > maxLength {
                print("too big!")
                targetLength = maxLength
            } else {
                targetLength = changedWidth
            }
            
            let scaleFactor = targetLength / targetImgRatio

            resultWidth = targetImgSize.width * scaleFactor
            resultHeight = targetImgSize.height * scaleFactor
            
        default:
            break
        }
        
        resultSize = CGSize(width: resultWidth, height: resultHeight)
        
        resultOrigin = CGPoint(x: bottomTrailingPoint.x - resultWidth + 5,
                               y: bottomTrailingPoint.y - resultHeight + 5)
        
        resultRect = CGRect(origin: resultOrigin, size: resultSize)
        
        return resultRect
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let input = CGPointDistanceSquared(from: from, to: to)
        return sqrt(input)
    }
}
