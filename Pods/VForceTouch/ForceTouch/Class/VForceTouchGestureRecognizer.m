//
//  VForceTouchGestureRecognizer.m
//  ForceTouch
//
//  Created by vee on 2017/1/8.
//  Copyright © 2017年 vee. All rights reserved.
//

#import "VForceTouchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

static const float DefaultMinimalPercentRequest = 0.2;
static const float MinimalIdentifiablePercent = 0.08;

@implementation VForceTouchGestureRecognizer

- (instancetype)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        _percentMinimalRequest = DefaultMinimalPercentRequest;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // only one touch required
    if (!(touches.count == 1)) {
        self.state = UIGestureRecognizerStateFailed;
    } else {
        self.state = UIGestureRecognizerStatePossible;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    if (self.state == UIGestureRecognizerStateBegan
        || self.state == UIGestureRecognizerStateChanged) {
        self.state = UIGestureRecognizerStateChanged;
    } else {
        if (!CGPointEqualToPoint([touch previousLocationInView:touch.view], [touch locationInView:touch.view])) {
            // when touch moved,state change to failed
            self.state = UIGestureRecognizerStateFailed;
            if (_failBlock) {
                _failBlock();
            }
        } else if (touch.force > touch.maximumPossibleForce * _percentMinimalRequest) {
            // when touch force is big enough, state change to began
            self.state = UIGestureRecognizerStateBegan;
        } else if (_possibleBlock && touch.force > touch.maximumPossibleForce * MinimalIdentifiablePercent){
            _possibleBlock(touch.force / (touch.maximumPossibleForce * _percentMinimalRequest));
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStatePossible && _failBlock) {
        _failBlock();
    }
    self.state = UIGestureRecognizerStateCancelled;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStatePossible && _failBlock) {
        _failBlock();
    }
    self.state = UIGestureRecognizerStateEnded;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    if ([preventedGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.state == UIGestureRecognizerStateBegan
            || self.state == UIGestureRecognizerStateChanged) {
            return YES;
        }
        return NO;
    }
    return [super canPreventGestureRecognizer:preventedGestureRecognizer];
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    if ([preventingGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    return [super canBePreventedByGestureRecognizer:preventingGestureRecognizer];
}

@end
