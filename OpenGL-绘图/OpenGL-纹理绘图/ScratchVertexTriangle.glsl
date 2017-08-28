attribute vec4 Position;
attribute vec2 TextureCoords;

attribute vec4 BGImagePosition;
attribute vec2 BGImageTextureCoords;

varying vec2 TextureCoordsOut;

varying vec2 BGImageTextureCoordsOut;

void main(void)
{
    
    gl_Position = Position; 
    TextureCoordsOut = TextureCoords;
    
//    gl_Position = BGImagePosition;
    BGImageTextureCoordsOut = BGImageTextureCoords;
}
