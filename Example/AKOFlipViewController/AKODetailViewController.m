//
//  AKODetailViewController.m
//  AKOFlipViewController
//
//  Created by Vasilis Akoinoglou on 7/13/14.
//  Copyright (c) 2014 Vasilis Akoinoglou. All rights reserved.
//

#import "AKODetailViewController.h"

@interface AKODetailViewController ()

@end

@implementation AKODetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.image) {
        self.mainImage.image = self.image;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
