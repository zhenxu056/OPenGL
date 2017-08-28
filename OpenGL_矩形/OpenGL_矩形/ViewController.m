//
//  ViewController.m
//  OpenGL_矩形
//
//  Created by zj-db0631 on 2017/6/20.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h" 
#import "MTGLKView.h"
@interface ViewController ()
 
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GLView *view = [[GLView alloc] initWithFrame:self.view.bounds];
//    MTGLKView *view = [[MTGLKView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:view];
    
        
    
}






@end
