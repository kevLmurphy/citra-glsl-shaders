#define BLACK_OUT_BORDER
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture

#define COMPAT_PRECISION mediump

/* COMPATIBILITY
   - GLSL compilers
*/

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;
varying COMPAT_PRECISION vec2 invSize;

vec4 _oPosition1; 
uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

// compatibility #defines
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)


#define BORDERMULT 14.0
#define GBAGAMMA 1.0

void main()
{
	TEX0 = TexCoord;
	gl_Position = MVPMatrix * VertexCoord;
	invSize = 1.0/TextureSize;
}


//precision highp float;
precision mediump float;

#define COMPAT_PRECISION mediump


#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out COMPAT_PRECISION vec4 FragColor;

uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;
varying COMPAT_PRECISION vec2 invSize;

// compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy
#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define OutSize vec4(OutputSize, 1.0 / OutputSize)


#define BORDERMULT 14.0
#define GBAGAMMA 1.0

void main()
{
	COMPAT_PRECISION vec2 texcoordInPixels = TEX0.xy * TextureSize.xy;
	COMPAT_PRECISION vec2 centerCoord = floor(texcoordInPixels.xy)+vec2(0.5,0.5);
	COMPAT_PRECISION vec2 distFromCenter = abs(centerCoord - texcoordInPixels);

	COMPAT_PRECISION float Y = max(distFromCenter.x,(distFromCenter.y));

	Y=Y*Y;
	COMPAT_PRECISION float YY = Y*Y;
	COMPAT_PRECISION float YYY = YY*Y;

	COMPAT_PRECISION float LineWeight = YY - 2.7*YYY;
	LineWeight = 1.0 - BORDERMULT*LineWeight;

	COMPAT_PRECISION vec3 colour = COMPAT_TEXTURE(Texture, invSize*centerCoord).rgb*LineWeight;

//#if defined(GBAGAMMA)
//	//colour.rgb = pow(colour.rgb, vec3(1.35));
//	colour.rgb*=0.6+0.4*(colour.rgb); //fake gamma because the pi is too slow!
//#endif
	if (GBAGAMMA > 0.5)
		colour.rgb*=0.6+0.4*(colour.rgb); //fake gamma because the pi is too slow!
		
	FragColor = vec4(colour.rgb , 1.0);
}
