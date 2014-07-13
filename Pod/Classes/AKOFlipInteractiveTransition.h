//
//  AKOFlipInteractiveTransition.h
//  Pods
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//
//

#import <UIKit/UIKit.h>

@protocol AKOFlipInteractiveTransitionDelegate <NSObject>
- (void)presentInteractive;
- (void)dismissInteractive;
- (void)completePopTransition;
@end

@interface AKOFlipInteractiveTransition : UIPercentDrivenInteractiveTransition
@property (nonatomic, weak) id <AKOFlipInteractiveTransitionDelegate> delegate;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@end
