
precision mediump float;

uniform sampler2D Texture;
varying vec2 TextureCoordsOut;

//varying vec2 TextureAlphaOut;

void main(void)
{
    vec4 mask = texture2D(Texture, TextureCoordsOut);
    
//    mask.a = 0.0;
//    if (mask.r == 1.0 && mask.g == 1.0 && mask.b == 1.0) {
//        mask.a =1.0;
//    }
//    gl_FragColor = vec4(mask.rgb, mask.a);
    
//    mask.a = 0.0;
//    if (0.9 <= mask.r && mask.r <= 1.0 ) {
//        mask.a = mask.r;
//    } 
//    if (mask.r < 0.9 ) {
//        discard;
//    }
//     gl_FragColor = vec4(1.0,1.0,1.0 , mask.a);
    
     gl_FragColor = vec4(1.0,1.0,1.0 , mask.r);
    
}
