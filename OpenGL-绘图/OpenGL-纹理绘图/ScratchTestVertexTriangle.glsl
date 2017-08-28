attribute vec4 Position;
attribute vec2 TextureCoords;

varying vec2 TextureCoordsOut;

void main(void)
{
    
    gl_Position = Position;
//    vec2 p = gl_PointCoord * 2.0 - vec2(1.0);
    TextureCoordsOut = TextureCoords;
    
}
