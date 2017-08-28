
precision mediump float;

uniform sampler2D BGTexture;
varying vec2 BGTextureCoordsOut;

//varying vec2 TextureAlphaOut;

void main(void)
{
    vec4 mask = texture2D(BGTexture, BGTextureCoordsOut);
    gl_FragColor = vec4(mask.rgb , mask.a);
//    gl_FragColor = vec4(0.5,0.5,0.5, 1.0);
}
