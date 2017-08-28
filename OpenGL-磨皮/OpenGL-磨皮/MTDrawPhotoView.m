//
//  MTDrawPhotoView.m
//  OpenGL-磨皮
//
//  Created by zj-db0631 on 2017/7/6.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTDrawPhotoView.h"
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>
#import "MTOpenGLManner.h"
#import "GLTexture.h"
#import "MTGLTexture.h"

#define Middle_CGPoint(start, end) CGPointMake(start.x + (end.x - start.x) / 2, start.y + (end.y - start.y) / 2)

typedef void (^containFunc)();

@interface MTDrawPhotoView () {
    EAGLContext *_context;//上下文
    CAEAGLLayer *_glLayer;
    
    GLuint _frameBuffer;
    GLuint _colorBufferRender;//缓冲器的渲染颜色
    
    MTGLProgramHandleModel *_BGProgramHandleModel;
    MTGLProgramHandleModel *_programHandleModel;
    
    MTGLTexture *_bgTexture;
    MTGLTexture *_paintTexture;
    MTGLTexture *_drawTexture;
    
    MTGLTextureModel *_bgTextureModel;
    MTGLTextureModel *_paintTextureModel;
    MTGLTextureModel *_drawTextureModel;
    
}

@property (nonatomic, assign) NSInteger saveCount;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic) NSMutableArray *tmpTouchPoints; // 计算贝塞尔曲线的时候使用.

@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIImage *paintImage;
@property (nonatomic, strong) UIImage *drawImage;
@end

@implementation MTDrawPhotoView

- (void)layoutSubviews {
    [super layoutSubviews];
    _tmpTouchPoints = [[NSMutableArray alloc] init];
    self.bgImage = [UIImage imageNamed:@"2.jpg"];
    self.drawImage = [UIImage imageNamed:@"1.jpg"];
    self.paintImage = [UIImage imageNamed:@"magic_radial"];
    
    _bgTextureModel = [[MTGLTextureModel alloc] init];
    _paintTextureModel = [[MTGLTextureModel alloc] init];
    _drawTextureModel = [[MTGLTextureModel alloc] init];
    
    [self setUp];
    
}

#pragma mark - 初始化OpenGL
- (void)setUp {
    __weak typeof(self) weakself = self;
    [self setContext:^{
        //编译背景shader
        [weakself compilingBGShader];
        
    }];
    
    _bgTexture = [[MTGLTexture alloc] initWithImage:self.bgImage
                                 isDeletBindTexture:NO
                                      ActiveTexture:GL_TEXTURE0
                                            Uniform:_bgTextureModel.textureUniform
                                          UniformID:0];
    
    //设置背景
    [self setBackGroundImage];
    
}


#pragma mark - 绘制纹理
#pragma mark - 设置背景
- (void)setBackGroundImage {
    
    [_bgTexture bindingTexture];
    
    //需要绘制的另一张图片的纹理，保持全图现实
    const GLfloat texCoords1[] = {
        0.0, 0.0,
        1, 0.0f,
        0.0f, 1,
        1, 1
    };
    glVertexAttribPointer(_bgTextureModel.textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords1);
    glEnableVertexAttribArray(_bgTextureModel.textureCoordsSlot);
    
    //需要显示的纹理图片的矩形坐标
    GLfloat vertices3[] = {
        -1.0, -1.0,
        1.0, -1.0,
        -1.0, 1.0,
        1.0, 1.0
    };
    glEnableVertexAttribArray(_bgTextureModel.positionSlot);
    glVertexAttribPointer(_bgTextureModel.positionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertices3);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    [self compilingDrawShader];
    
    _drawTexture = [[MTGLTexture alloc] initWithImage:self.drawImage
                                   isDeletBindTexture:NO
                                        ActiveTexture:GL_TEXTURE1
                                              Uniform:_drawTextureModel.textureUniform
                                            UniformID:1];
    
    _paintTexture = [[MTGLTexture alloc] initWithImage:self.paintImage
                                    isDeletBindTexture:NO
                                         ActiveTexture:GL_TEXTURE2
                                               Uniform:_paintTextureModel.textureUniform
                                             UniformID:2];
}

#pragma mark -- 绘制图片
- (void)renderUsingIndexVBO:(CGPoint)point {
    
    [_drawTexture bindingTexture];
    [_paintTexture bindingTexture];
    
    //绘制图形的大小
    CGFloat w1 = 50;
    CGFloat w = w1/self.frame.size.width;
    CGFloat h = w1/self.frame.size.height;
    
    CGPoint p1 = CGPointMake(point.x - (w/2), point.y - (h/2));
    CGPoint p2 = CGPointMake(point.x + (w/2), point.y - (h/2));
    CGPoint p3 = CGPointMake(point.x - (w/2), point.y + (h/2));
    CGPoint p4 = CGPointMake(point.x + (w/2), point.y + (h/2));
    //根据坐标换算出纹理的坐标。公式：2 * x(纹理) - 1 = x(坐标)。Y坐标一样
    CGPoint u1 = CGPointMake((p1.x+1)/2, (p1.y+1)/2);
    CGPoint u2 = CGPointMake((p2.x+1)/2, (p2.y+1)/2);
    CGPoint u3 = CGPointMake((p3.x+1)/2, (p3.y+1)/2);
    CGPoint u4 = CGPointMake((p4.x+1)/2, (p4.y+1)/2);
    
    //需要绘制的图片的纹理纹理，根据坐标换算，取出在当前点需要绘制的图片的位置大小
    const GLfloat texCoords[] = {
        u1.x, u1.y,
        u2.x, u2.y,
        u3.x, u3.y,
        u4.x, u4.y
        
    };
    glVertexAttribPointer(_drawTextureModel.textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
    glEnableVertexAttribArray(_drawTextureModel.textureCoordsSlot);
    
    //需要绘制的另一张图片的纹理，保持全图现实
    const GLfloat texCoords1[] = {
        0.0, 0.0,
        1, 0.0f,
        0.0f, 1,
        1, 1
    };
    glVertexAttribPointer(_paintTextureModel.textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords1);
    glEnableVertexAttribArray(_paintTextureModel.textureCoordsSlot);
    
    //需要显示的纹理图片的矩形坐标
    GLfloat vertices3[] = {
        p1.x, p1.y,
        p2.x, p2.y,
        p3.x, p3.y,
        p4.x, p4.y};
    
    glEnableVertexAttribArray(_paintTextureModel.positionSlot);
    glVertexAttribPointer(_paintTextureModel.positionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertices3);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}

#pragma mark - 传入纹理数据等
- (void)afferentTextureData {  //传入绘图纹理图片的坐标
    _paintTextureModel.textureUniform = glGetUniformLocation(_programHandleModel.programHandle, "Texture");
    _paintTextureModel.positionSlot = glGetAttribLocation(_programHandleModel.programHandle, "Position");
    _paintTextureModel.textureCoordsSlot = glGetAttribLocation(_programHandleModel.programHandle, "TextureCoords");
    
    _drawTextureModel.textureUniform = glGetUniformLocation(_programHandleModel.programHandle, "BGImageTexture");
    _drawTextureModel.positionSlot = glGetAttribLocation(_programHandleModel.programHandle, "BGImagePosition");
    _drawTextureModel.textureCoordsSlot = glGetAttribLocation(_programHandleModel.programHandle, "BGImageTextureCoords");
}

- (void)afferentBGTextureData {
    _bgTextureModel.textureUniform = glGetUniformLocation(_BGProgramHandleModel.programHandle, "BGTexture");
    _bgTextureModel.positionSlot = glGetAttribLocation(_BGProgramHandleModel.programHandle, "BGPosition");
    _bgTextureModel.textureCoordsSlot = glGetAttribLocation(_BGProgramHandleModel.programHandle, "BGTextureCoords");
}

#pragma mark - 手势触摸
#pragma mark -- 刚开始触摸
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch=[touches anyObject];
    CGPoint current=[touch locationInView:self];
    
    _startPoint = current;
}
#pragma mark -- 触摸移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self];
    
    [_tmpTouchPoints addObject:[NSValue valueWithCGPoint:currentPoint]];
    
    [self addCGPointsViaBezeier:_startPoint to:currentPoint];
    
    _startPoint = currentPoint;
    
}
#pragma mark -- 触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    _startPoint = CGPointZero;
    [_tmpTouchPoints removeAllObjects];
}

#pragma mark - 绘制算法
- (void)addCGPointsViaBezeier:(CGPoint)start
                           to:(CGPoint)end {
    CGPoint p1, p2, p3;
    if (_tmpTouchPoints.count > 2) {
        p1 = Middle_CGPoint([_tmpTouchPoints[_tmpTouchPoints.count - 3] CGPointValue], start);
        p2 = start;
        p3 = Middle_CGPoint(start, end);
    } else {
        p1 = start;
        p3 = Middle_CGPoint(start, end);
        p2 = Middle_CGPoint(start, p3);
    }
    
    
    for (CGFloat t=0; t<1; t+=0.1) {
        CGFloat x = (1 - t) * (1 - t) * p1.x + 2 * t * (1 - t) * p2.x + t * t * p3.x;
        CGFloat y = (1 - t) * (1 - t) * p1.y + 2 * t * (1 - t) * p2.y + t * t * p3.y;
        
        CGSize screenSize = self.bounds.size;
        CGFloat last_X = x / (screenSize.width/2);
        CGFloat last_Y = y / (screenSize.height/2);
        CGPoint p = CGPointMake(-(1-last_X), 1-last_Y);
        [self renderUsingIndexVBO:p];
    }
}

#pragma mark - CAEAGLLayer
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


- (void)setContext:(containFunc)func {
    //先判断是否存在
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_context];//设置当前上下文
    }
    NSAssert(_context && [EAGLContext setCurrentContext:_context], @"_context初始化创建失败");
    
    //创建OpenGL环境
    _glLayer = (CAEAGLLayer *)self.layer;
    _glLayer.frame = self.frame;
    //设置不透明,CALayer 默认是透明的，透明性能不好,最好设置为不透明.
    _glLayer.opaque = YES;
    // 设置绘图属性drawableProperties
    // kEAGLColorFormatRGBA8 ： red、green、blue、alpha共8位
    _glLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                    kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8  };
    
    func();
    
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
    [_context renderbufferStorage:GL_RENDERBUFFER
                     fromDrawable:(id<EAGLDrawable>)_glLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              _colorBufferRender);
    
    //清除颜色设为白色
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    //表示实际完成了把整个窗口清除为黑色的任务
    glClear(GL_COLOR_BUFFER_BIT);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    //开启纹理混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //设置需要显示的窗口大小
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
}

- (void)compilingBGShader {
    NSString *shaderVertex1 = @"ScratchTestVertexTriangle_TWO";
    NSString *shaderFragment1 = @"ScratchTestFragmentTriangle_TWO";
    _BGProgramHandleModel = [[MTGLProgramHandleModel alloc] initWtihCompileShaders:shaderVertex1
                                                                    ShaderFragment:shaderFragment1];
    [self afferentBGTextureData];
}

- (void)compilingDrawShader {
    NSString *shaderVertex1 = @"ScratchVertexTriangle";
    NSString *shaderFragment1 = @"ScratchFragmentTriangle";
    _programHandleModel = [[MTGLProgramHandleModel alloc] initWtihCompileShaders:shaderVertex1
                                                                  ShaderFragment:shaderFragment1];
    [self afferentTextureData];
} 

@end
