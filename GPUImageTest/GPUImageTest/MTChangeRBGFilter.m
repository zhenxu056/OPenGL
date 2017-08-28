//
//  MTChangeRBGFilter.m
//  GPUImageTest
//
//  Created by zj-db0631 on 2017/7/11.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTChangeRBGFilter.h"

@implementation MTChangeRBGFilter

- (instancetype)initWithFragmentShaderFromFile:(NSString *)fragmentShaderFilename {
    if (self == [super initWithFragmentShaderFromFile:fragmentShaderFilename]) {
        testValueR = [filterProgram uniformIndex:@"testValueR"];
        testValueG = [filterProgram uniformIndex:@"testValueG"];
        testValueB = [filterProgram uniformIndex:@"testValueB"];
        
    }
    return self;
}

- (void)setR:(CGFloat)R {
    [self setFloat:R forUniform:testValueR program:filterProgram];
}

- (void)setG:(CGFloat)G {
    [self setFloat:G forUniform:testValueG program:filterProgram];
}

- (void)setB:(CGFloat)B {
    [self setFloat:B forUniform:testValueB program:filterProgram];
}
@end
