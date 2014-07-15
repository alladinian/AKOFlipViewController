//
//  AKOFlipInteractiveTransition.m
//  Pods
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//
//

#import "AKOFlipInteractiveTransition.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef NS_ENUM(NSUInteger, AKOPanGestureRecognizerDirection) {
    AKOPanGestureRecognizerDirectionVertical,
    AKOPanGestureRecognizerDirectionHorizontal
};


@interface AKOPanGestureRecognizer : UIPanGestureRecognizer
{
    BOOL _drag;
    int _moveX;
    int _moveY;
}
@property (nonatomic, assign) AKOPanGestureRecognizerDirection direction;
@end
@implementation AKOPanGestureRecognizer

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!_drag) {
        if (fabs(_moveX) > fabs(_moveY)) {
            if (_direction == AKOPanGestureRecognizerDirectionVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        } else if (fabs(_moveY) > fabs(_moveX)) {
            if (_direction == AKOPanGestureRecognizerDirectionHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end


@interface AKOFlipInteractiveTransition ()
@property (nonatomic, assign) CGFloat percentage;
@end

@implementation AKOFlipInteractiveTransition

- (void)setView:(UIView *)view
{
    _view = view;
    for (UIPanGestureRecognizer *r in view.gestureRecognizers) {
        if ([r isKindOfClass:[AKOPanGestureRecognizer class]]) {
            [view removeGestureRecognizer:r];
        }
    }
    AKOPanGestureRecognizer *gesture = [[AKOPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    gesture.direction = (AKOPanGestureRecognizerDirection)self.transitionDirection;
    [self.view addGestureRecognizer:gesture];
}

- (void)setTransitionDirection:(AKOFlipTransitionDirection)transitionDirection
{
    _transitionDirection = transitionDirection;
    for (AKOPanGestureRecognizer *r in self.view.gestureRecognizers) {
        if ([r isKindOfClass:[AKOPanGestureRecognizer class]]) {
            r.direction = (AKOPanGestureRecognizerDirection)self.transitionDirection;
        }
    }
}

- (void)handlePan:(AKOPanGestureRecognizer *)gesture
{
    
    BOOL isVertical = (self.transitionDirection == AKOFlipTransitionDirectionVertical);
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"Gesture began...");
            
            self.percentage = 0.0f;
            
            CGPoint nowPoint = [gesture locationInView:self.view];
            CGFloat boundary = CGRectGetMidY(self.view.frame);
            CGPoint velocity = [gesture velocityInView:self.view];
            
            BOOL isBackwards = isVertical ? (velocity.y > 0) : (velocity.x > 0);
            
            if (isBackwards) {
                NSLog(@"Downwards/Left...");
            } else {
                NSLog(@"Upwards/Right...");
            }
            
            
            NSLog(@"Point: %@ | Boundary: %@", NSStringFromCGPoint(nowPoint), @(boundary));
            self.presenting = !isBackwards;
            
            if (self.isPresenting) {
                [self.delegate presentInteractive];
            } else {
                [self.delegate dismissInteractive];
            }
            
            NSLog(@"MODE: %@", self.presenting ? @"PUSH" : @"POP");
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGRect viewRect = self.view.bounds;
            CGPoint translation = [gesture translationInView:self.view];
            _percentage = isVertical ? (translation.y / viewRect.size.height) : (translation.x / viewRect.size.width);
            _percentage = fabsf(_percentage);
            _percentage = MIN(1.0, MAX(0.0, _percentage));
            [self updateInteractiveTransition:_percentage];
            
            NSLog(@"Gesture changed...");
            //NSLog(@"Translation: %@ | Percent: %@", NSStringFromCGPoint(translation), @(percent));
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"Gesture Cancelled...");
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"Gesture Ended...");
            
            const CGFloat threshold = 0.3f;
            BOOL passedThreshold = _percentage > threshold;
            
            if (passedThreshold) {
                if (self.isPresenting) {
                    [self finishInteractiveTransition];
                } else {
                    [self finishInteractiveTransition];
                    [self.delegate completePopTransition];
                }
            } else {
                [self cancelInteractiveTransition];
            }

            break;
        }
        default:
            break;
    }
}

@end
