//
//  ViewController.m
//  OpenGL-磨皮
//
//  Created by zj-db0631 on 2017/7/4.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "ViewController.h"
#import "MTGLDrawView.h"
#import "MTDrawPhotoView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    MTGLDrawView *view  = [[MTGLDrawView alloc] initWithFrame:self.view.bounds];
    MTDrawPhotoView *view  = [[MTDrawPhotoView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
}




@end
