//
//  MTGPUImageView.m
//  GPUImage-滤镜
//
//  Created by zj-db0631 on 2017/7/7.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTGPUImageView.h"

#import "GPUImage.h"

@interface MTGPUImageView ()

@end

@implementation MTGPUImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setUp];
}

- (void)testSetUp {
    GPUImageTwoInputFilter *twoInput = [[GPUImageTwoInputFilter alloc] initWithFragmentShaderFromFile:@"Fragment"];
}

- (void)setUp {
    UIImage *image = [UIImage imageNamed:@"123.jpg"];
    
    GPUImageGaussianBlurFilter *disFilter = [[GPUImageGaussianBlurFilter alloc] init];
    disFilter.texelSpacingMultiplier = 0.8;
    disFilter.blurRadiusInPixels = 5.0;
    
    //设置要渲染的区域
    [disFilter forceProcessingAtSize:image.size];
    [disFilter useNextFrameForImageCapture];
    
    //获取数据源
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:image];
    
    //添加上滤镜
    [stillImageSource addTarget:disFilter];
    
    //开始渲染
    [stillImageSource processImage];
    
    //获取渲染后的图片
    UIImage *newImage = [disFilter imageFromCurrentFramebuffer];
    
    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"Fragment"];
    
    UIImage *currentFilteredVideoFrame = [filter imageByFilteringImage:newImage]; 
    
    //加载出来
    UIImageView *imageView = [[UIImageView alloc] initWithImage:currentFilteredVideoFrame];
    
    imageView.frame=self.frame;
    [self addSubview:imageView];
    
}


@end
