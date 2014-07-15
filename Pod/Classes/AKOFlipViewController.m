//
//  AKOFlipViewController.m
//  AKOFlipViewController
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//  Copyright (c) 2014 Vasilis Akoinoglou. All rights reserved.
//

#import "AKOFlipViewController.h"

@interface AKOFlipViewController ()
<UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate,
AKOFlipInteractiveTransitionDelegate,
AKOFlipViewControllerDatasource>

@property (nonatomic, strong) UINavigationController *flipNavigationController;
@property (nonatomic, strong) AKOFlipTransitionAnimator *flipTransitionAnimator;
@property (nonatomic, strong) AKOFlipInteractiveTransition *flipInteractiveTransition;
@end

@implementation AKOFlipViewController

- (id<AKOFlipViewControllerDatasource>)datasource
{
    if (!_datasource) return self;
    return _datasource;
}

- (AKOFlipTransitionAnimator *)flipTransitionAnimator
{
    if (!_flipTransitionAnimator) {
        _flipTransitionAnimator = [AKOFlipTransitionAnimator new];
        _flipTransitionAnimator.presenting = YES;
    }
    return _flipTransitionAnimator;
}

- (AKOFlipInteractiveTransition *)flipInteractiveTransition
{
    if (!_flipInteractiveTransition) {
        _flipInteractiveTransition = [AKOFlipInteractiveTransition new];
        _flipInteractiveTransition.presenting = YES;
        _flipInteractiveTransition.delegate = self;
    }
    return _flipInteractiveTransition;
}

- (void)setTransitionDirection:(AKOFlipTransitionDirection)transitionDirection
{
    _transitionDirection = transitionDirection;
    self.flipInteractiveTransition.transitionDirection = transitionDirection;
    self.flipTransitionAnimator.transitionDirection = transitionDirection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIViewController *initialController = [self.datasource flipViewController:self viewControllerAtIndex:0];
    self.flipInteractiveTransition.view = initialController.view;
    self.flipTransitionAnimator.transitionDuration = 0.25f;
    
    self.flipNavigationController = [[UINavigationController alloc] initWithRootViewController:initialController];
    self.flipNavigationController.interactivePopGestureRecognizer.enabled = NO;
    self.flipNavigationController.delegate = self;
    [self.flipNavigationController.navigationBar setHidden:YES];
    
    [self addChildViewController:self.flipNavigationController];
    self.flipNavigationController.view.frame = self.view.frame;

    [self.view addSubview:self.flipNavigationController.view];
    
    [self.flipNavigationController didMoveToParentViewController:self];
}

- (UIViewController *)flipViewController:(AKOFlipViewController *)flipViewController viewControllerAtIndex:(NSUInteger)index
{
    return nil;
}

- (NSUInteger)numberOfControllersInFlipController:(AKOFlipViewController *)flipController
{
    return 0;
}

- (void)presentInteractive
{
    UIViewController *nextController = [self nextViewController];

    if (!nextController) return;
    self.flipInteractiveTransition.view = nextController.view;
    [self.flipNavigationController pushViewController:nextController animated:YES];
}

- (void)dismissInteractive
{
    if (self.flipNavigationController.viewControllers.count < 2) return;
    
    [self.flipNavigationController popViewControllerAnimated:YES];
}

- (void)completePopTransition
{
    UIViewController *lastController = [self.flipNavigationController.viewControllers lastObject];
    self.flipInteractiveTransition.view = lastController.view;
}

- (UIViewController *)nextViewController
{
    NSInteger nextIndex = self.flipNavigationController.viewControllers.count;
    if (nextIndex >= [self.datasource numberOfControllersInFlipController:self]) return nil;
    
    UIViewController *c = [self.datasource flipViewController:self viewControllerAtIndex:nextIndex];
    return c;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    return self.flipInteractiveTransition;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:
(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    self.flipTransitionAnimator.presenting = (operation == UINavigationControllerOperationPush);
    return self.flipTransitionAnimator;
}

@end
