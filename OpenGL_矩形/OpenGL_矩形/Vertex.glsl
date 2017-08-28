attribute vec4 Position;
attribute vec2 TextureCoords;
varying vec2 TextureCoordsOut;

void main(void)
{
    //用来展现纹理的多边形顶点
    gl_Position = Position;
    //表示使用的纹理的范围的顶点，因为是2D纹理，所以用vec2类型
    TextureCoordsOut = TextureCoords;
}
