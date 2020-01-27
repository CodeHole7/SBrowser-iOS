//
//  VForceTouchGestureRecognizer.h
//  ForceTouch
//
//  Created by vee on 2017/1/8.
//  Copyright © 2017年 vee. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ForceTouchPossibleBlock)(CGFloat possibleProgress);
typedef void(^ForceTouchFailBlock)(void);

@interface VForceTouchGestureRecognizer : UIGestureRecognizer


/**
 touch force request to recognizer the gesture,default is 20%
 */
@property (nonatomic, assign) float percentMinimalRequest;

/**
 when the touch force is increase but not to the minimal force request,this block will call 
 */
@property (nonatomic,copy) ForceTouchPossibleBlock possibleBlock;


/**
 call when the gesture's state is set to UIGestureRecognizerStateFailed,UIGestureRecognizerStateEnded or UIGestureRecognizerStateCancelled
 */
@property (nonatomic,strong) ForceTouchFailBlock failBlock;

@end
