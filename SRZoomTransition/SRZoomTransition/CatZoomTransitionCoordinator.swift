//
//  CatZoomTransitionCoordinator.swift
//  SRZoomTransition
//
//  Created by Louis Tur on 11/8/15.
//  Copyright © 2015 Louis Tur. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol CatZoomTransitionCoordinatorDelegate: class {
  func boundsForViewToEnterTransition() -> CGRect
  func boundsForViewToOccupyAfterTransition() -> CGRect
  optional func captureSnapshotForImage() -> UIImageView
  optional func captureSnapShotForView() -> UIView
}

public class CatZoomTransitionCoordinator: NSObject, UIViewControllerAnimatedTransitioning {
  
  public var transitionDuration: NSTimeInterval = 1.00
  public var delegate: CatZoomTransitionCoordinatorDelegate?
  
  public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
    return self.transitionDuration
  }
  
  public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
    
    // anything commented out is related to this function, however not actually being used at this stage.
    // keeping them in place in case i need to refer to old notes
    let containerView = transitionContext.containerView()!
    //let originView: UIView = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!.view
    let destinationView = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!.view
    //let destinaionViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
    
    let boundsForImageFromOrigin: CGRect = (self.delegate?.boundsForViewToEnterTransition())! // this value is slightly inaccurate, dont know why
    //let imageViewFromOrigin: UIImageView = (self.delegate?.captureSnapshotForImage())!
    let viewFromOrigin: UIView = (self.delegate?.captureSnapShotForView!())!
    
    // here's the fucking annoying part. the UIImage has a size, however it's not the scaled size that is being displayed in the UIImageView.
    // In order to get the accurate size of the image (and then be able to calculate its frame, and grow it appropriately), I'll need to calculate
    // the size of the image based on the scaling type (AspectFit) and the size of the heigh of the imageView.
    // see http://stackoverflow.com/questions/389342/how-to-get-the-size-of-a-scaled-uiimage-in-uiimageview
    //let originImageSize: CGSize = (imageViewFromOrigin.image?.size)!
    
    //let fromViewSnapShot: UIView = imageViewFromOrigin.snapshotViewAfterScreenUpdates(false)
    let fromViewSnapShot: UIView = viewFromOrigin.snapshotViewAfterScreenUpdates(false)
    
    let backgroundView: UIView = UIView(frame: containerView.bounds)
    backgroundView.backgroundColor = UIColor.purpleColor()
    backgroundView.alpha = 0.0
    
    containerView.addSubview(backgroundView)
    backgroundView.addSubview(fromViewSnapShot)
    
    fromViewSnapShot.frame = boundsForImageFromOrigin
    let startingFrame: CGRect = boundsForImageFromOrigin
    
    // This is attempting to get the final frame location for the transitional view
    // unfortunately, the frame sizes right now are a little off for the ending frame
    // the start frame seems very accurate and should not be adapted
    let endingFrame: CGRect = (self.delegate?.boundsForViewToOccupyAfterTransition())!
    print("Ending Frame: \(endingFrame)")
    
    UIView.animateKeyframesWithDuration(self.transitionDuration, delay: 0.0, options:.CalculationModeLinear, animations: { () -> Void in
      
      UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
        fromViewSnapShot.frame = startingFrame // almost correct
        backgroundView.alpha = 0.5
      })
      
      UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
        fromViewSnapShot.frame = endingFrame // very incorrect due to inaccurate image size
        backgroundView.alpha = 1.0
      })
      
      }) { finished -> Void in
        backgroundView.addSubview(destinationView)
        fromViewSnapShot.removeFromSuperview()
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        
    }
    
  }
  
  public func animationEnded(transitionCompleted: Bool) {
    
  }
}