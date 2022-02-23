//
//  ViewController.swift
//  panscale
//
//  Created by Inpyo Hong on 2022/02/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var outerImgView: UIImageView!
    @IBOutlet weak var innerImgView: UIImageView!
    var panGesture  = UIPanGestureRecognizer()
    private var lastSwipeBeginningPoint: CGPoint?
    private var lastDistance: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.dragImg(_:)))
        innerImgView.isUserInteractionEnabled = true
        innerImgView.addGestureRecognizer(panGesture)
        
        innerImgView.center = CGPoint(x: outerImgView.frame.maxX - 5, y: outerImgView.frame.maxY - 5)
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
            
            let lastOuterImgFrame = outerImgView.frame
            
            let resultRightBottomPoint = CGPoint(x: innerImgView.center.x + translation.x, y: innerImgView.center.y + translation.y)
                        
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
                
                resultWidth = lastOuterImgFrame.width - (distance * 2)
                resultHeight = lastOuterImgFrame.height - (distance * 2)
                
                resultSize = CGSize(width: resultWidth, height: resultHeight)
            }
            
            if isRight && isDown {
                print("bigger")
                
                resultWidth = lastOuterImgFrame.width + (distance * 2)
                resultHeight = lastOuterImgFrame.height + (distance * 2)
                
                resultSize = CGSize(width: resultWidth, height: resultHeight)
            }
            
            if resultWidth < 30 {
                print("too small!")
                return
            }
            
            if resultWidth > UIScreen.main.bounds.width - 40 {
                print("too big!")
                return
            }
            
            resultOrigin = CGPoint(x: resultRightBottomPoint.x - resultWidth + 5, y: resultRightBottomPoint.y - resultHeight + 5)
            resultRect = CGRect(origin: resultOrigin, size: resultSize)
            
            print("resultWidth", resultWidth, "resultHeight", resultHeight)
            
            let lastCenter = outerImgView.center
            
            outerImgView.frame = resultRect
            outerImgView.center = lastCenter
            
            innerImgView.center = CGPoint(x: outerImgView.frame.maxX - 5, y: outerImgView.frame.maxY - 5)
            
            sender.setTranslation(CGPoint.zero, in: self.view)

            //            outerImgView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            //
            //            outerImgView.center = CGPoint(x: outerImgView.center.x + translation.x, y: outerImgView.center.y + translation.y)
        }
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        let input = CGPointDistanceSquared(from: from, to: to)
        return sqrt(input)
    }
}

