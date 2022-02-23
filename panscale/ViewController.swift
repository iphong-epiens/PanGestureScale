//
//  ViewController.swift
//  panscale
//
//  Created by Inpyo Hong on 2022/02/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var targetImgView: UIImageView!
    @IBOutlet weak var enlargeImgView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    
    var targetPanGesture = UIPanGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    private var lastSwipeBeginningPoint: CGPoint?
    private var testImg = UIImage(named: "mj")!
    private var orgImgViewSize = CGSize(width: 0, height: 0)
    private var imageRatio: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        targetImgView.isUserInteractionEnabled = true
        targetImgView.layer.borderColor = UIColor.gray.cgColor
        targetImgView.layer.borderWidth = 1
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(dragImg))
        targetPanGesture = UIPanGestureRecognizer(target: self, action: #selector(dragTargetImg))

        targetImgView.addGestureRecognizer(targetPanGesture)

        enlargeImgView.addGestureRecognizer(panGesture)
        enlargeImgView.isUserInteractionEnabled = true
        enlargeImgView.layer.cornerRadius = enlargeImgView.frame.width/2
        enlargeImgView.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.maxY - 5)
        
        orgImgViewSize = targetImgView.frame.size
        imageRatio = targetImgView.frame.width/targetImgView.frame.height
        
        print("imageRatio",imageRatio)
        
        closeBtn.layer.cornerRadius = closeBtn.frame.width/2
        closeBtn.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.origin.y + 5)
    }
    
    @objc func dragImg(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        
        print("translation",translation)
        
        if sender.state == .began {
            lastSwipeBeginningPoint = sender.location(in: sender.view)
        } else if sender.state == .ended {
            guard let beginPoint = lastSwipeBeginningPoint else {
                return
            }
            
            let endPoint = sender.location(in: sender.view)
            // TODO: use the x and y coordinates of endPoint and beginPoint to determine which direction the swipe occurred.
            
            print("beginPoint", beginPoint, "endPoint", endPoint)
            
            let distance = CGPointDistance(from: beginPoint, to: endPoint)
            print("distance", distance)
            
            let lastOuterImgFrame = targetImgView.frame
            
            let resultRightBottomPoint = CGPoint(x: enlargeImgView.center.x + translation.x, y: enlargeImgView.center.y + translation.y)
            
            var isLeft = false, isRight = false, isUp = false, isDown = false
            var resultRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            
            var resultWidth: CGFloat = 0
            var resultHeight: CGFloat = 0
            
            var resultSize = CGSize(width: 0, height: 0)
            var resultOrigin = CGPoint(x: 0, y: 0)
            
            if endPoint.x > beginPoint.x {
                print("turn right")
                isRight = true
            }
            if endPoint.x < beginPoint.x {
                print("turn left")
                isLeft = true
            }
            
            if endPoint.y > beginPoint.y {
                print("turn down")
                isDown = true
            }
            
            if endPoint.y < beginPoint.y {
                print("turn up")
                isUp = true
            }
            
            if isLeft && isUp {
                print("smaller")
                
                let changedWidth = lastOuterImgFrame.width - (distance * 2)
                
                if changedWidth > orgImgViewSize.width/4 {
                    resultWidth = lastOuterImgFrame.width - (distance * 2)
                    resultHeight = lastOuterImgFrame.height - (distance * 2)
                } else {
                    print("too small!")
                    resultWidth = orgImgViewSize.width/4
                    resultHeight = orgImgViewSize.height/4
                }
            }
            
            if isRight && isDown {
                print("bigger")
                
                let changedWidth = lastOuterImgFrame.width + (distance * 2)
                
                if changedWidth > UIScreen.main.bounds.width * 0.75 {
                    print("too big!")
                    resultWidth = UIScreen.main.bounds.width * 0.75
                    resultHeight = resultWidth * imageRatio
                } else {
                    resultWidth = lastOuterImgFrame.width + (distance * 2)
                    resultHeight = lastOuterImgFrame.height + (distance * 2)
                }
            }
            
            resultSize = CGSize(width: resultWidth, height: resultHeight)

            resultOrigin = CGPoint(x: resultRightBottomPoint.x - resultWidth + 5,
                                   y: resultRightBottomPoint.y - resultHeight + 5)
            
            resultRect = CGRect(origin: resultOrigin, size: resultSize)
            
            print("resultWidth", resultWidth, "resultHeight", resultHeight)
            
            let lastCenterPos = targetImgView.center
            
            targetImgView.frame = resultRect
            targetImgView.center = lastCenterPos
            
            enlargeImgView.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.maxY - 5)
            closeBtn.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.origin.y + 5)

            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    @objc func dragTargetImg(_ sender:UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        
        targetImgView.center = CGPoint(x: targetImgView.center.x + translation.x, y: targetImgView.center.y + translation.y)
        
        enlargeImgView.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.maxY - 5)
        closeBtn.center = CGPoint(x: targetImgView.frame.maxX - 5, y: targetImgView.frame.origin.y + 5)

        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let input = CGPointDistanceSquared(from: from, to: to)
        return sqrt(input)
    }
}
