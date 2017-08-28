attribute vec4 Position;
attribute vec2 TextureCoords;
//attribute vec4 alpha;

varying vec2 TextureCoordsOut;
//varying vec2 TextureAlphaOut;

void main(void)
{
    gl_Position = Position;
    TextureCoordsOut = TextureCoords;
//    TextureAlphaOut = alpha;
}
