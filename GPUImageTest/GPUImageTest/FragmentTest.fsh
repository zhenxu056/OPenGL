precision mediump float;

varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

uniform mediump float testValueR;
uniform mediump float testValueG;
uniform mediump float testValueB;

void main()
{
    vec4 mask = texture2D(inputImageTexture, textureCoordinate);
    //    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    if (mask.r == 0.0) {
        mask.r = testValueR;
        mask.g = testValueG;
        mask.b = testValueB;
    }
    gl_FragColor = vec4(mask.rgb, mask.a);
}
