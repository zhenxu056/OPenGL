
precision mediump float;

uniform sampler2D Texture;
varying vec2 TextureCoordsOut;

//varying vec2 TextureAlphaOut;

void main(void)
{
    vec4 mask = texture2D(Texture, TextureCoordsOut);
    gl_FragColor = vec4(mask.rgb, 1.0);
    
}
