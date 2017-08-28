//
//  ViewController.m
//  OpenGL-纹理绘图
//
//  Created by zj-db0631 on 2017/6/23.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"
#import "GLCircularView.h"
#import "GLTouchDrawingView.h"
#import "GLScratchPhotoView.h"
#import "GLScratchPhoto_TwoView.h"
#import "MTGLDrawView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    GLView *view  = [[GLView alloc] initWithFrame:self.view.bounds];

//    GLCircularView *view  = [[GLCircularView alloc] initWithFrame:self.view.bounds];
    
//    GLTouchDrawingView *view  = [[GLTouchDrawingView alloc] initWithFrame:self.view.bounds];
    
//    GLScratchPhotoView *view  = [[GLScratchPhotoView alloc] initWithFrame:self.view.bounds];
    
//    GLScratchPhoto_TwoView *view  = [[GLScratchPhoto_TwoView alloc] initWithFrame:self.view.bounds];
    
    MTGLDrawView *view  = [[MTGLDrawView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:view];
}




@end
