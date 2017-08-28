//
//  MTGPUImageView_1.m
//  GPUImageTest
//
//  Created by zj-db0631 on 2017/7/10.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTGPUImageView_1.h"

#import "GPUImage.h"
#import "MTChangeRBGFilter.h"

@interface MTGPUImageView_1 ()
{
    GPUImageFilterGroup *_groupFilter;
}
@end

@implementation MTGPUImageView_1

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self setUp];
    [self setUpTwo];
}

- (void)setUpTwo {
    UIImage *image = [UIImage imageNamed:@"123.jpg"];
    //获取数据源
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:NO];
    
//    GPUImageFilter *bufferFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"Fragment"];
    
    MTChangeRBGFilter *bufferFilter = [[MTChangeRBGFilter alloc] initWithFragmentShaderFromFile:@"FragmentTest"];
    bufferFilter.R = 1.0;
    bufferFilter.G = 1.0;
    bufferFilter.B = 1.0;
    
    GPUImageGaussianBlurFilter *gaussianFilter = [[GPUImageGaussianBlurFilter alloc] init];
    gaussianFilter.texelSpacingMultiplier = 0.8;
    gaussianFilter.blurRadiusInPixels = 5.0;
    
    GPUImageView *gView = [[GPUImageView alloc] initWithFrame:self.bounds];
    [self addSubview:gView];
    
    [imagePicture addTarget:bufferFilter];
    [bufferFilter addTarget:gaussianFilter];
    
    [gaussianFilter addTarget:gView];
    
    
//    [imagePicture processImage];
    
    
    [imagePicture processImageUpToFilter:gaussianFilter withCompletionHandler:^(UIImage *processedImage) {
        NSLog(@"%@",processedImage);
    }];
    
//    [gaussianFilter useNextFrameForImageCapture];
//    UIImage *image1 = [gaussianFilter imageFromCurrentFramebuffer];
    
    
//    [imagePicture addTarget:bufferFilter];
//    [imagePicture addTarget:gaussianFilter];
//    
//    
//    GPUImageFilterPipeline *filterPipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:@[bufferFilter, gaussianFilter] input:imagePicture output:gView];
//
//    [imagePicture processImage];
//    [gaussianFilter useNextFrameForImageCapture];
    
    
    
//    UIImage *newImage = [filterPipeline currentFilteredFrame];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:newImage];
//    imageView.frame=self.frame;
//    [self addSubview:imageView];
}

- (void)setUp {
    UIImage *image = [UIImage imageNamed:@"123.jpg"];
    //获取数据源
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:image];
    
    GPUImageFilter *filter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"Fragment"];
    [filter forceProcessingAtSize:CGSizeMake(200, 200)];
    
    
    GPUImageGaussianBlurFilter *gaussianFilter = [[GPUImageGaussianBlurFilter alloc] init];
    gaussianFilter.texelSpacingMultiplier = 0.8;
    gaussianFilter.blurRadiusInPixels = 5.0;
    [gaussianFilter forceProcessingAtSize:image.size];
    
    
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc]init];
    [contrastFilter setContrast:0.3];
    
    
    _groupFilter = [[GPUImageFilterGroup alloc] init];
    [imagePicture addTarget:_groupFilter];
    
    
    [filter addTarget:gaussianFilter];
    [gaussianFilter addTarget:contrastFilter];
    
    [_groupFilter setInitialFilters:@[filter]];
    [_groupFilter setTerminalFilter:contrastFilter];
    
//    [self addGPUImageFilter:filter];
//    [self addGPUImageFilter:gaussianFilter];
//    [self addGPUImageFilter:contrastFilter];
    
    //开始渲染
    [imagePicture processImage];
    [_groupFilter useNextFrameForImageCapture];
    
    //获取渲染后的图片
    UIImage *newImage = [_groupFilter imageFromCurrentFramebuffer];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:newImage];
    imageView.frame=self.frame;
    [self addSubview:imageView];
    
}

- (void)addGPUImageFilter:(GPUImageFilter *)filter{
    
    [_groupFilter addFilter:filter];
    
    GPUImageOutput<GPUImageInput> *newTerminalFilter = filter;
    
    NSInteger count = _groupFilter.filterCount;
    
    if (count == 1)
    {
        _groupFilter.initialFilters = @[newTerminalFilter];
        _groupFilter.terminalFilter = newTerminalFilter;
        
    } else
    {
        GPUImageOutput<GPUImageInput> *terminalFilter    = _groupFilter.terminalFilter;
        NSArray *initialFilters                          = _groupFilter.initialFilters;
        
        [terminalFilter addTarget:newTerminalFilter];
        
        _groupFilter.initialFilters = initialFilters;
        _groupFilter.terminalFilter = newTerminalFilter;
    }
}


@end
