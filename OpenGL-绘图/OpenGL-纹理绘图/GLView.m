//
//  GLView.m
//  OpenGL-纹理绘图
//
//  Created by zj-db0631 on 2017/6/23.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "GLView.h"

#import "ShaderOperations.h"  

@interface GLView ()
{
    EAGLContext *_myContext;
    CAEAGLLayer *_EALayer;
    GLuint _colorBufferRender;//缓冲器的渲染颜色
    GLuint _frameBuffer;
    GLuint _glProgram;
    GLuint _positionSlot;
    GLuint _textureSlot;
    GLuint _textureCoordsSlot;
    GLuint _texture;
}

@property (nonatomic) GLuint positionSlot; // Position参数
@property (nonatomic) GLuint colorSlot; // uniform类型的SourceColor参数
@property (nonatomic) GLuint aColorSlot; // Attribute类型的ASourceColor参数
@property (nonatomic) GLint projectionSlot;
@property (nonatomic) GLint modelViewSlot;
@property (nonatomic, readonly, assign) CGSize size;

@end

@implementation GLView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setUp];
    
}

- (void)setUp
{
    if (!_myContext) {
        _myContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_myContext];
    }
    NSAssert(_myContext && [EAGLContext setCurrentContext:_myContext], @"初始化GL环境失败");
    
    _EALayer = (CAEAGLLayer *)self.layer;
    _EALayer.frame = self.frame;
    _EALayer.opaque = YES;
    
    
    // 先要编译vertex和fragment两个shader
    NSString *shaderVertex = @"VertexTriangle";
    NSString *shaderFragment = @"FragmentTriangle";
    [self compileShaders:shaderVertex shaderFragment:shaderFragment];
    
    //设置缓存器
    //在设置缓存之前，最好先清理一次，避免重复设置
    if (_frameBuffer) {
        glDeleteBuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_colorBufferRender) {
        glDeleteBuffers(1, &_colorBufferRender);
        _colorBufferRender = 0;
    }
    
   
    //初始化layer后，需要初始化下renderBuffer和frameBuffer(渲染缓冲器和帧数缓冲器)
    glGenRenderbuffers(1, &_colorBufferRender);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBufferRender);
    [_myContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)_EALayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              _colorBufferRender);
    
    glClearColor(0.8f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    [_myContext presentRenderbuffer:GL_RENDERBUFFER];
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height); ;
    
    //开启纹理混合
    glEnable(GL_BLEND);
//    glBlendFunc(GL_ONE, GL_ZERO);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 

    
    [self didDrawImageViaOpenGLES:[UIImage imageNamed:@"magic_radial"]];
    
}

#pragma mark - didDrawImageViaOpenGLES
- (void)didDrawImageViaOpenGLES:(UIImage *)image {
    
    
    // 将image绑定到GL_TEXTURE_2D上，即传递到GPU中
    _texture = [self setupTexture:image];
    // 此时，纹理数据就可看做已经在纹理对象_textureID中了，使用时从中取出即可
    
    // 第一行和第三行不是严格必须的，默认使用GL_TEXTURE0作为当前激活的纹理单元
    glActiveTexture(GL_TEXTURE5); // 指定纹理单元GL_TEXTURE5
    glBindTexture(GL_TEXTURE_2D, _texture); // 绑定，即可从_textureID中取出图像数据。
    glUniform1i(_textureSlot, 5); // 与纹理单元的序号对应
    
    
    
    // 渲染需要的数据要从GL_TEXTURE_2D中得到。
    // GL_TEXTURE_2D与_textureID已经绑定
    
    [self renderUsingIndexVBO];
    
    
    
    
    
    glBindTexture(GL_TEXTURE_2D, 0);
    [_myContext presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)renderUsingIndexVBO {
    CGFloat w1 = 300;
    CGFloat x1 = w1/self.frame.size.width;
    CGFloat y1 = w1/self.frame.size.height;
    
    const GLfloat texCoords[] = {
        0.0, 0.0,
        1, 0.0f,
        0.0f, 1,
        1, 1
    };
    
    glVertexAttribPointer(_textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
//    glVertexAttribPointer(_color, 4, GL_FLOAT, NO, 0, g_color_buffer_data);
    glEnableVertexAttribArray(_textureCoordsSlot);
    
//    //正方形
//    NSLog(@"x = %f  y = %f", x1, y1);
//    GLfloat vertices1[] = {
//        0.0f, 0.0f,
//        x1, 0.0f,
//        0.0f, y1,
//        x1, y1};
//    
//    glEnableVertexAttribArray(_positionSlot);
//    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertices1);
//    
//    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    //中间的正方形
    CGFloat centerX2 = x1/2;
    CGFloat centerY2 = y1/2;
    GLfloat vertices2[] = {
        -centerX2, -centerY2,
        centerX2, -centerY2,
        -centerX2, centerY2,
        centerX2, centerY2};
    
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertices2);
    
    
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    
}

#pragma mark - setupTexture

/**
 *  加载image, 使用CoreGraphics将位图以RGBA格式存放. 将UIImage图像数据转化成OpenGL ES接受的数据.
 *  然后在GPU中将图像纹理传递给GL_TEXTURE_2D。
 *  @return 返回的是纹理对象，该纹理对象暂时未跟GL_TEXTURE_2D绑定（要调用bind）。
 *  即GL_TEXTURE_2D中的图像数据都可从纹理对象中取出。
 */
- (GLuint)setupTexture:(UIImage *)image {
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
    
    GLuint textureID;
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
    
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
    glBindTexture(GL_TEXTURE_2D, 0); //解绑
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

#pragma mark - shader related

/**
 编译着色器
 
 @param shaderVertex vert文件名
 @param shaderFragment  Fragment文件名
 */
- (void)compileShaders:(NSString *)shaderVertex shaderFragment:(NSString *)shaderFragment {
    // 1 vertex和fragment两个shader都要编译
    GLuint vertexShader = [ShaderOperations compileShader:shaderVertex withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [ShaderOperations compileShader:shaderFragment withType:GL_FRAGMENT_SHADER];
    
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
    
    // 4 让OpenGL执行program
    glUseProgram(programHandle);
    
    // 5 获取指向vertex shader传入变量的指针, 然后就通过该指针来使用
    // 即将_positionSlot 与 shader中的Position参数绑定起来
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    
    // 即将_colorSlot 与 shader中的SourceColor参数绑定起来
    // 采用的是Attribute类型
    _aColorSlot = glGetAttribLocation(programHandle, "ASourceColor");
    // 采用的是uniform类型
    _colorSlot = glGetUniformLocation(programHandle, "SourceColor");
    
    _modelViewSlot = glGetUniformLocation(programHandle, "ModelView");
    _projectionSlot = glGetUniformLocation(programHandle, "Projection");
    
    _textureSlot = glGetUniformLocation(programHandle, "Texture");
    _textureCoordsSlot = glGetAttribLocation(programHandle, "TextureCoords");
    // 在使用的地方, 调用glEnableVertexAttribArray以启用这些数据
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

@end
