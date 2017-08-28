//
//  MTGLTexture.m
//  OpenGL-磨皮
//
//  Created by zj-db0631 on 2017/7/6.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTGLTexture.h"

#import <OpenGLES/ES2/glext.h>

@interface MTGLTexture () {
    GLuint _textureID;
    
    GLenum _activeTexture;
    GLuint _uniform;
    GLuint _uniformId;
}

@end

@implementation MTGLTexture
- (instancetype)initWithImage:(UIImage *)image isDeletBindTexture:(BOOL)isDelet ActiveTexture:(GLenum)activeTexture Uniform:(GLuint)uniform UniformID:(GLuint)uniformId {
    self = [self initWithImage:image isDeletBindTexture:isDelet];
    
    _activeTexture = activeTexture;
    _uniform = uniform;
    _uniformId = uniformId;
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image isDeletBindTexture:(BOOL)isDelet {
    if (self = [super init]) {
        CGImageRef cgImageRef = [image CGImage];
        GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
        GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
        CGRect rect = CGRectMake(0, 0, width, height);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        void *imageData = malloc(width * height * 4);
        CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGContextTranslateCTM(context, 0, height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGColorSpaceRelease(colorSpace);
        CGContextClearRect(context, rect);
        CGContextDrawImage(context, rect, cgImageRef);
        
        
        
        glEnable(GL_TEXTURE_2D);
        
        /**
         *  GL_TEXTURE_2D表示操作2D纹理
         *  创建纹理对象，
         *  绑定纹理对象，
         */
        
        glGenTextures(1, &_textureID);
        glBindTexture(GL_TEXTURE_2D, _textureID);
        
        
        /**
         *  纹理过滤函数
         *  图象从纹理图象空间映射到帧缓冲图象空间(映射需要重新构造纹理图像,这样就会造成应用到多边形上的图像失真),
         *  这时就可用glTexParmeteri()函数来确定如何把纹理象素映射成像素.
         *  如何把图像从纹理图像空间映射到帧缓冲图像空间（即如何把纹理像素映射成像素）
         */
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE); // S方向上的贴图模式
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE); // T方向上的贴图模式
        // 线性过滤：使用距离当前渲染像素中心最近的4个纹理像素加权平均值
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        /**
         *  将图像数据传递给到GL_TEXTURE_2D中, 因其于textureID纹理对象已经绑定，所以即传递给了textureID纹理对象中。
         *  glTexImage2d会将图像数据从CPU内存通过PCIE上传到GPU内存。
         *  不使用PBO时它是一个阻塞CPU的函数，数据量大会卡。
         */
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        // 结束后要做清理
        if (isDelet) {
            glBindTexture(GL_TEXTURE_2D, 0); //解绑
        }
        CGContextRelease(context);
        free(imageData);

    }
    return self;
}

- (void)bindingTextureWithActiveTexture:(GLenum)activeTexture Uniform:(GLuint)uniform UniformID:(GLuint)uniformId {
    glActiveTexture(activeTexture);
    glBindTexture(GL_TEXTURE_2D, _textureID); // 绑定，即可从_textureID中取出图像数据。
    glUniform1i(uniform, uniformId); // 与纹理单元的序号对应。
}

- (void)bindingTexture {
    glActiveTexture(_activeTexture);
    glBindTexture(GL_TEXTURE_2D, _textureID); // 绑定，即可从_textureID中取出图像数据。
    glUniform1i(_uniform, _uniformId); // 与纹理单元的序号对应。
}

- (void)deleteTexture {
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &_textureID);
}

@end

@implementation MTGLTextureModel


@end

@interface MTGLProgramHandleModel ()
{
    GLuint _programHandle;
}
@end

@implementation MTGLProgramHandleModel

- (instancetype)initWtihCompileShaders:(NSString *)shaderVertex ShaderFragment:(NSString *)shaderFragment {
    if (self = [super init]) {
        _programHandle = [self compileShaders:shaderVertex shaderFragment:shaderFragment];
    }
    return self;
}
 
- (GLuint)programHandle {
    return _programHandle;
}

/**
 编译着色器
 
 @param shaderVertex vert文件名
 @param shaderFragment  Fragment文件名
 */
- (GLuint)compileShaders:(NSString *)shaderVertex shaderFragment:(NSString *)shaderFragment {
    // 1 vertex和fragment两个shader都要编译
    GLuint vertexShader = [self compileShader:shaderVertex withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:shaderFragment withType:GL_FRAGMENT_SHADER];
    
    // 2 连接vertex和fragment shader成一个完整的program
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    // link program
    glLinkProgram(programHandle);
    
    // 3 check link status
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    else {
        glUseProgram(programHandle); //激活着色器，成功便使用，避免由于未使用导致的的bug
    }
    
    //3、释放不需要的shader
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return programHandle;
}

/**
 编译文件
 
 @param shaderName Shader的名字
 @param shaderType 文件的类型
 @return 返回编译后的数据
 */
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    // 1 查找shader文件
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2 创建一个代表shader的OpenGL对象, 指定vertex或fragment shader
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3 获取shader的source
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4 编译shader
    glCompileShader(shaderHandle);
    
    // 5 查询shader对象的信息
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

@end
