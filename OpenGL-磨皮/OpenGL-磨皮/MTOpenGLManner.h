//
//  MTOpenGLManner.h
//  OpenGL-磨皮
//
//  Created by zj-db0631 on 2017/7/4.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTOpenGLManner : NSObject

#pragma mark - 绑定纹理
/**
 绑定纹理
 
 @param image 纹理图片信息
 @param texture 纹理ID
 @param glenum 纹理单元
 @param textureSlot 纹理位置
 */
+ (void)didDrawImageViaOpenGLES:(UIImage *)image
                        Texture:(GLuint)texture
                  ActiveTexture:(GLenum)glenum
                    TextureSlot:(GLuint)textureSlot;

#pragma mark - 删除纹理ID
/**
 删除纹理ID
 
 @param texture 纹理ID
 */
+ (void)deleateTexture:(GLuint)texture;

#pragma mark - shader编译

/**
 编译着色器
 
 @param shaderVertex vert文件名
 @param shaderFragment  Fragment文件名
 */
+ (GLuint)compileShaders:(NSString *)shaderVertex
          shaderFragment:(NSString *)shaderFragment;

#pragma mark - 编译文件
/**
 编译文件
 
 @param shaderName Shader的名字
 @param shaderType 文件的类型
 @return 返回编译后的数据
 */
+ (GLuint)compileShader:(NSString*)shaderName
               withType:(GLenum)shaderType;

#pragma mark -- 图片转化会纹理数据信息
/**
 图片转化会纹理数据信息
 
 @param image 加载image, 使用CoreGraphics将位图以RGBA格式存放. 将UIImage图像数据转化成OpenGL ES接受的数据.然后在GPU中将图像纹理传递给GL_TEXTURE_2D。
 @param isDelet 是否需要删除绑定的纹理数据
 @return 返回的是纹理对象，该纹理对象暂时未跟GL_TEXTURE_2D绑定（要调用bind）。即GL_TEXTURE_2D中的图像数据都可从纹理对象中取出。
 */

+ (GLuint)setupTexture:(UIImage *)image isDeletBindTexture:(BOOL)isDelet ;

+ (void)texture:(GLuint)texture activeTexture:(GLenum)activeTexture TextureID:(GLuint)ID uniform:(GLuint)uniform;

+ (void)bindingsEnableVertexAttribArray:(GLuint)positionSolt  VertexAttribPointerVertices:(GLfloat[])Vertices;
@end
