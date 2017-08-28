//
//  MTChangeRBGFilter.h
//  GPUImageTest
//
//  Created by zj-db0631 on 2017/7/11.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface MTChangeRBGFilter : GPUImageFilter
{
    GLint testValueR;
    GLint testValueG;
    GLint testValueB;
}

@property (nonatomic, assign) CGFloat R;
@property (nonatomic, assign) CGFloat G;
@property (nonatomic, assign) CGFloat B;

@end
