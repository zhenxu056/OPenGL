precision mediump float;

uniform sampler2D Texture;
varying vec2 TextureCoordsOut;

void main(void)
{
    //获取纹理的像素
    vec4 mask = texture2D(Texture, TextureCoordsOut);
    
    gl_FragColor = vec4(mask.rgb, 1.0);
}
