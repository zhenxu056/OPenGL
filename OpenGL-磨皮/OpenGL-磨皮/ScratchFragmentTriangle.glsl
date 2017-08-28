
precision mediump float;

uniform sampler2D Texture;

uniform sampler2D BGImageTexture;

varying vec2 TextureCoordsOut;

varying vec2 BGImageTextureCoordsOut;

void main(void)
{
    vec4 bgImageMask = texture2D(BGImageTexture, BGImageTextureCoordsOut);
    
    vec4 mask = texture2D(Texture, TextureCoordsOut);
    
    
//        gl_FragColor = vec4(1.0,1.0,1.0, 1.0);
    
    gl_FragColor = vec4(bgImageMask.rgb,  mask.r);
    
}
