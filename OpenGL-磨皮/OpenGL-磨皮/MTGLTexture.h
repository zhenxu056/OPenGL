//
//  MTGLTexture.h
//  OpenGL-磨皮
//
//  Created by zj-db0631 on 2017/7/6.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTGLTexture : NSObject

/**
 纹理ID
 */
@property (nonatomic, assign, readonly) GLuint textureID;


/**
 只需要获取到纹理ID

 @param image 图片
 @param isDelet 是否需要释放纹理
 @return MTGLTexture对象
 */
- (instancetype)initWithImage:(UIImage *)image
           isDeletBindTexture:(BOOL)isDelet;

/**
 绑定纹理

 @param activeTexture 选择纹理单元
 @param uniform 指明要更改的uniform变量的位置
 @param uniformId 指定的uniform变量中要使用的新值
 */
- (void)bindingTextureWithActiveTexture:(GLenum)activeTexture
                                Uniform:(GLuint)uniform
                              UniformID:(GLuint)uniformId;


/**
 一次传入数据

 @param image 图片
 @param isDelet 是否释放纹理
 @param activeTexture 选择纹理单元
 @param uniform 指明要更改的uniform变量的位置
 @param uniformId 指定的uniform变量中要使用的新值
 @return MTGLTexture对象
 */
- (instancetype)initWithImage:(UIImage *)image
           isDeletBindTexture:(BOOL)isDelet
                ActiveTexture:(GLenum)activeTexture
                      Uniform:(GLuint)uniform
                    UniformID:(GLuint)uniformId;

/**
 绑定纹理数据
 */
- (void)bindingTexture;

/**
 删除纹理数据
 */
- (void)deleteTexture;

@end

#pragma mark - 纹理数据Model
@interface MTGLTextureModel : NSObject

/**
 纹理位置
 */
@property (nonatomic, assign) GLuint positionSlot;

/**
 纹理颜色
 */
@property (nonatomic, assign) GLuint textureCoordsSlot;

/**
 着色器纹理
 */
@property (nonatomic, assign) GLuint textureUniform;


@end

#pragma mark - 获取编译器句柄

@interface MTGLProgramHandleModel : NSObject

/**
 程序句柄
 */
@property (nonatomic, assign, readonly) GLuint programHandle;

/**
 编译着色器
 
 @param shaderVertex vert文件名
 @param shaderFragment  Fragment文件名
 */
- (instancetype)initWtihCompileShaders:(NSString *)shaderVertex ShaderFragment:(NSString *)shaderFragment;

@end
