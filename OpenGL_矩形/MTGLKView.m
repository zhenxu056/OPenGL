//
//  MTGLKView.m
//  OpenGL_矩形
//
//  Created by zj-db0631 on 2017/6/20.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTGLKView.h"

#import "ShaderOperations.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface MTGLKView ()
{
    EAGLContext *_context;//获取上下文
    CAEAGLLayer *_EALayer;
    GLuint _colorBufferRender;//缓冲器的渲染颜色
    GLuint _frameBuffer;
}
 
@property (nonatomic) GLuint positionSlot; // Position参数
@property (nonatomic) GLuint colorSlot; // uniform类型的SourceColor参数
@property (nonatomic) GLuint aColorSlot; // Attribute类型的ASourceColor参数
@property (nonatomic) GLint modelViewSlot;
@property (nonatomic) GLint projectionSlot;
@property (nonatomic) GLint textureSlot;
@property (nonatomic) GLint textureCoordsSlot;

@end


@implementation MTGLKView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setUp];
    
}

- (void)setUp
{
    //开启一个上下文，当你的程序设置了一个新的上下文时候，会先释放先前的一个上下文，并且刷新的下文
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_context];
    }
    NSAssert(_context && [EAGLContext setCurrentContext:_context], @"初始化GL环境失败");
    
    //开启上下文后，我们需要对layer层进行一个处理，设置一些熟悉，使其支持OpenGL
    _EALayer = (CAEAGLLayer *)self.layer;
    _EALayer.frame = self.frame;
    _EALayer.opaque = YES;//  CALayer默认是透明的，而透明的层对性能负荷很大。所以将其关闭。
    
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
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)_EALayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              _colorBufferRender);
    
//    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
//    glClear(GL_COLOR_BUFFER_BIT);
//    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    
    // 先要编译vertex和fragment两个shader
    NSString *shaderVertex = @"VertexTriangle";
    NSString *shaderFragment = @"FragmentTriangle";
    [self compileShaders:shaderVertex shaderFragment:shaderFragment];
    
    GLKView *_glkView = [[GLKView alloc] initWithFrame:CGRectMake(10, 100, self.frame.size.width - 20, 200) context:_context];
    [_glkView bindDrawable];
    [self addSubview:_glkView];
    
    GLfloat vertices[] = {
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        0.0f, -1.0f, 0.0f};
    
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    
    GLfloat vertices2[] = {
        -1.0f, 0.0f, 0.0f,
        1.0f, 0.0f, 0.0f,
        0.0f, 1.0f, 0.0f};
    
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices2);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    
    [_glkView display];
    
    
}

#pragma mark - shader related

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
