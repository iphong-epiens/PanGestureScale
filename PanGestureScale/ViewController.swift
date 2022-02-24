//
//  ViewController.swift
//  PanGestureScale
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
    var targetPinchGesture = UIPinchGestureRecognizer()
    var targetTapGesture = UITapGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    private var lastSwipeBeginningPoint: CGPoint?
    private var targetImgSize = CGSize(width: 0, height: 0)
    private var targetImgRatio: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        targetPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragTargetImg))
        targetPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchTargetImg))
        targetTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapTargetImg))
        targetImgView.gestureRecognizers = [targetTapGesture, targetPanGesture, targetPinchGesture]
        targetTapGesture.require(toFail: targetTapGesture)
        
        let targetImg = UIImage(named: "poster")!

        targetImgView.image = targetImg
        targetImgSize = targetImg.size
        targetImgRatio = max(targetImgSize.width, targetImgSize.height)
        
        let maxLength = UIScreen.main.bounds.width * 0.5
        let scaleFactor = maxLength / targetImgRatio
        let targetImgFrame = CGSize(width: targetImgSize.width * scaleFactor,
                                    height: targetImgSize.height * scaleFactor)

        targetImgView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: targetImgFrame)
        targetImgView.center = self.view.center
        
        targetImgView.isUserInteractionEnabled = true
        targetImgView.isMultipleTouchEnabled = true
        targetImgView.layer.borderColor = UIColor.darkGray.cgColor
        targetImgView.layer.borderWidth = 1
                
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragImg))
        enlargeImgView.addGestureRecognizer(panGesture)
        
        enlargeImgView.isUserInteractionEnabled = true
        enlargeImgView.layer.cornerRadius = enlargeImgView.frame.width/2
        enlargeImgView.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.maxY - 5)
        
        closeBtn.addTarget(self, action: #selector(tapCloseBtn), for: .touchUpInside)
        closeBtn.layer.cornerRadius = closeBtn.frame.width/2
        closeBtn.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.origin.y + 5)
    }

    @objc func tapCloseBtn(_ sender: AnyObject){
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            self.enlargeImgView.removeFromSuperview()
            self.closeBtn.removeFromSuperview()
            self.targetImgView.removeFromSuperview()
        }
    }
  
    @objc func dragImg(_ sender:UIPanGestureRecognizer) {
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
            
            let resizeValue = CGPointDistance(from: beginPoint, to: endPoint)
            
            let bottomTrailingPoint = CGPoint(x: enlargeImgView.center.x + translation.x,
                                              y: enlargeImgView.center.y + translation.y)
            
            let resultRect = getTargetViewRect(resizeCondition,
                                              resizeValue: resizeValue,
                                              bottomTrailingPoint: bottomTrailingPoint)
            
            let lastCenterPos = targetImgView.center
            
            UIView.animate(withDuration: 0.1) { [weak self] in
                guard let self = self else { return }
                self.targetImgView.frame = resultRect
                self.targetImgView.center = lastCenterPos
                
                self.enlargeImgView.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.maxY - 5)
                self.closeBtn.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.origin.y + 5)
            }
            
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc func tapTargetImg(_ sender: UITapGestureRecognizer) {
        print(#function)
    }
    
    @objc func dragTargetImg(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        
        UIView.animate(withDuration: 0.1) { [weak self] in
            guard let self = self else { return }
            self.targetImgView.center = CGPoint(x: self.targetImgView.center.x + translation.x, y: self.targetImgView.center.y + translation.y)
            
            self.enlargeImgView.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.maxY - 5)
            self.closeBtn.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.origin.y + 5)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    @objc func pinchTargetImg(_ sender: UIPinchGestureRecognizer) {
        guard let gestureView = sender.view else {
          return
        }

        gestureView.transform = gestureView.transform.scaledBy(
          x: sender.scale,
          y: sender.scale
        )
        sender.scale = 1
        
        self.enlargeImgView.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.maxY - 5)
        self.closeBtn.center = CGPoint(x: self.targetImgView.frame.maxX - 5, y: self.targetImgView.frame.origin.y + 5)
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
    
    func getTargetViewRect(_ resizeOption: ResizeOption, resizeValue: CGFloat, bottomTrailingPoint: CGPoint) -> CGRect {
        var resultRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        var resultWidth: CGFloat = 0
        var resultHeight: CGFloat = 0
        var resultOrigin = CGPoint(x: 0, y: 0)
        var resultSize = CGSize(width: 0, height: 0)

        var scaleFactor: CGFloat = 0
        var targetLength: CGFloat = 0
        var changedWidth: CGFloat = 0
        let lastOuterImgFrame = targetImgView.frame
        
        switch resizeOption {
        case .smaller:
            changedWidth = lastOuterImgFrame.width - (resizeValue * 2)
            let minLength = targetImgSize.width * 0.25

            if changedWidth > minLength {
                targetLength = changedWidth
            } else {
                print("too small!")
                targetLength = minLength
            }
                        
        case .bigger:
            changedWidth = lastOuterImgFrame.width + (resizeValue * 2)
            let maxLength = UIScreen.main.bounds.width * 0.75
            
            if changedWidth > maxLength {
                print("too big!")
                targetLength = maxLength
            } else {
                targetLength = changedWidth
            }
            
        default:
            break
        }

        scaleFactor = targetLength / targetImgRatio

        resultWidth = targetImgSize.width * scaleFactor
        resultHeight = targetImgSize.height * scaleFactor
        
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

extension ViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }
}
