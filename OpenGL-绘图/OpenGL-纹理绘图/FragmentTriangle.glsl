
precision mediump float;

uniform sampler2D Texture;
varying vec2 TextureCoordsOut;

//varying vec2 TextureAlphaOut;

void main(void)
{
    vec4 mask = texture2D(Texture, TextureCoordsOut);
//    gl_FragColor = vec4(mask.rgb, 1.0);
    
    
//    gl_FragColor = vec4(mask.rgb, 0.0);
    
    mask.a = 0.0;
    if (mask.r == 1.0 && mask.g == 1.0 && mask.b == 1.0) {
        mask.a =1.0;
    }
     gl_FragColor = vec4(mask.rgb, mask.a);
    
//    vec4 texColor = texture (texture1, TexCoords);
//    if (texColor.a < 0.1)
//        discard;
//    color = texColor;
//    
//    gl_FragColor = vec4(mask.rgb, TextureAlphaOut);
}
