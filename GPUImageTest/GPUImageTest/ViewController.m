//
//  ViewController.m
//  GPUImageTest
//
//  Created by zj-db0631 on 2017/7/7.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "ViewController.h"

#import "MTGPUImageView.h"
#import "MTGPUImageView_1.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    MTGPUImageView *view = [[MTGPUImageView alloc] initWithFrame:self.view.bounds];
    
    MTGPUImageView_1 *view = [[MTGPUImageView_1 alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:view];
}



@end
