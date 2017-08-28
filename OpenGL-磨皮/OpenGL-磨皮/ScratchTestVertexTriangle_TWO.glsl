attribute vec4 BGPosition;
attribute vec2 BGTextureCoords;

varying vec2 BGTextureCoordsOut;

void main(void)
{
    
    gl_Position = BGPosition;
    BGTextureCoordsOut = BGTextureCoords;
    
}
