//
//  MTShaderManager.h
//  OpenGL-纹理绘图
//
//  Created by zj-db0631 on 2017/6/22.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface MTShaderManager : NSObject

+ (GLuint)compileShaders:(NSString *)shaderVertex shaderFragment:(NSString *)shaderFragment;

+ (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType;

@end
