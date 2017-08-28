//
//  MTGLDrawView.m
//  OpenGL-纹理绘图
//
//  Created by zj-db0631 on 2017/7/3.
//  Copyright © 2017年 zj-db0631. All rights reserved.
//

#import "MTGLDrawView.h"

#import <OpenGLES/ES2/glext.h>

#define Middle_CGPoint(start, end) CGPointMake(start.x + (end.x - start.x) / 2, start.y + (end.y - start.y) / 2)

@interface MTGLDrawView () {
    EAGLContext *_context;//上下文
    CAEAGLLayer *_glLayer;
    
    GLuint _frameBuffer;
    GLuint _colorBufferRender;//缓冲器的渲染颜色
    
    GLuint _positionSlot;
    GLuint _textureSlot;
    GLuint _textureCoordsSlot;
    GLuint _texture; 
    
    GLuint _BGImagetexture;
    GLuint _BGImagetextureCoordsSlot;
    GLuint _BGImagepositionSlot;
    
    GLuint _programHandle;
}

@property (nonatomic, assign) NSInteger saveCount;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic) NSMutableArray *tmpTouchPoints; // 计算贝塞尔曲线的时候使用.

@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) UIImage *drawImage;

@end

@implementation MTGLDrawView

- (void)layoutSubviews {
    [super layoutSubviews];
    _tmpTouchPoints = [[NSMutableArray alloc] init];
    self.bgImage = [UIImage imageNamed:@"12345.jpg"];
    self.drawImage = [UIImage imageNamed:@"magic_radial"];
    [self setUp];
}

#pragma mark - 初始化OpenGL
- (void)setUp {
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
    
    //先要编译vertex和fragment两个shader。所有的预编译最好在前面就做好编译
    NSString *shaderVertex = @"ScratchVertexTriangle";
    NSString *shaderFragment = @"ScratchFragmentTriangle";
    [self compileShaders:shaderVertex shaderFragment:shaderFragment];
    //设置纹理的一些数据
    [self afferentTextureData];
    
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
    
    //设置需要显示的窗口大小
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    //开启纹理混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //先输入需要展示的图片数据保存
    [self didDrawImageViaOpenGLES:self.bgImage];
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

#pragma mark - 绘制纹理
#pragma mark -- 绘制算法
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

#pragma mark -- 绘制图片
- (void)renderUsingIndexVBO:(CGPoint)point {
    [self drawBgImage:self.drawImage];
    
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
    glVertexAttribPointer(_BGImagetextureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords);
    glEnableVertexAttribArray(_BGImagetextureCoordsSlot);
    
    //需要绘制的另一张图片的纹理，保持全图现实
    const GLfloat texCoords1[] = {
        0.0, 0.0,
        1, 0.0f,
        0.0f, 1,
        1, 1
    };
    glVertexAttribPointer(_textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, 0, texCoords1);
    glEnableVertexAttribArray(_textureCoordsSlot);
    
    //需要显示的纹理图片的矩形坐标
    GLfloat vertices3[] = {
        p1.x, p1.y,
        p2.x, p2.y,
        p3.x, p3.y,
        p4.x, p4.y};
    
    glEnableVertexAttribArray(_positionSlot);
    glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, vertices3);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &_BGImagetexture);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}

#pragma mark - 传入纹理数据等
- (void)afferentTextureData {
    //传入绘图纹理图片的坐标
    _textureSlot = glGetUniformLocation(_programHandle, "Texture");
    _BGImagetexture = glGetUniformLocation(_programHandle, "BGImageTexture");
    
    //传入绘图纹理图片的坐标
    _positionSlot = glGetAttribLocation(_programHandle, "Position");
    //传入背景纹理图片的坐标
    _BGImagepositionSlot = glGetAttribLocation(_programHandle, "BGImagePosition");
    
    //传入绘图纹理图片的颜色
    _textureCoordsSlot = glGetAttribLocation(_programHandle, "TextureCoords");
    //传入背景纹理图片的颜色
    _BGImagetextureCoordsSlot = glGetAttribLocation(_programHandle, "BGImageTextureCoords");
}

#pragma mark - 创建纹理图片数据
#pragma mark -- 纹理图片转化
- (void)didDrawImageViaOpenGLES:(UIImage *)image {
    // 将image绑定到GL_TEXTURE_2D上，即传递到GPU中
    _texture = [self setupTexture:image isDeletBindTexture:NO];
    NSLog(@"纹理标号：%d", (int)_texture);
    // 此时，纹理数据就可看做已经在纹理对象_textureID中了，使用时从中取出即可
    glActiveTexture(GL_TEXTURE5); // 指定纹理单元GL_TEXTURE5
    glBindTexture(GL_TEXTURE_2D, _texture); // 绑定，即可从_textureID中取出图像数据。
    glUniform1i(_textureSlot, 5); // 与纹理单元的序号对应。
}

#pragma mark -- 先保存背景的纹理数据
//此数据需要永久保留，因而不需要把纹理数据释放
- (void)drawBgImage:(UIImage *)image {
    _BGImagetexture = [self setupTexture:image isDeletBindTexture:NO];
    NSLog(@"绘图---纹理标号：%d", (int)_BGImagetexture);
    // 此时，纹理数据就可看做已经在纹理对象_textureID中了，使用时从中取出即可
    glActiveTexture(GL_TEXTURE5); // 指定纹理单元GL_TEXTURE5
    glBindTexture(GL_TEXTURE_2D, _BGImagetexture); // 绑定，即可从_textureID中取出图像数据。
    glUniform1i(_BGImagetexture, 5); // 与纹理单元的序号对应。
}

#pragma mark -- 图片转化会纹理数据信息
/**
 图片转化会纹理数据信息

 @param image 加载image, 使用CoreGraphics将位图以RGBA格式存放. 将UIImage图像数据转化成OpenGL ES接受的数据.然后在GPU中将图像纹理传递给GL_TEXTURE_2D。
 @param isDelet 是否需要删除绑定的纹理数据
 @return 返回的是纹理对象，该纹理对象暂时未跟GL_TEXTURE_2D绑定（要调用bind）。即GL_TEXTURE_2D中的图像数据都可从纹理对象中取出。
 */

- (GLuint)setupTexture:(UIImage *)image isDeletBindTexture:(BOOL)isDelet {
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
    if (isDelet) {
        glBindTexture(GL_TEXTURE_2D, 0); //解绑
    }
    CGContextRelease(context);
    free(imageData);
    
    return textureID;
}

#pragma mark - shader编译

/**
 编译着色器
 
 @param shaderVertex vert文件名
 @param shaderFragment  Fragment文件名
 */
- (void)compileShaders:(NSString *)shaderVertex shaderFragment:(NSString *)shaderFragment {
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
    
    _programHandle = programHandle;
    // 4 让OpenGL执行program
    glUseProgram(_programHandle);
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

#pragma mark - CAEAGLLayer
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - 退出程序做一次删除
- (void)dealloc {
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &_texture);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glDeleteTextures(1, &_BGImagetexture);
    
    glDeleteBuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    
    glDeleteBuffers(1, &_colorBufferRender);
    _colorBufferRender = 0;
    
    [EAGLContext setCurrentContext:nil];
    _context = nil;
}

@end
