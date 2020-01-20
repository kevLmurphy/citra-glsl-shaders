/*
  Bump mapping shader with AA coded by guest.r, ported to dolphin by One More Try.
Needs to be Optimized.  

	Slightly modified by Nevuk to port to Citra. This options portion no longer does anything, but is left to tell of min/max/defaults for the various 
	options. 
*/

/*
[configuration]

[OptionBool]
GUIName = Bump Mapping
OptionName = BumpMap
DefaultValue = true

[OptionRangeFloat]
GUIName = Glow (1.25)
OptionName = glow
MinValue = 0
MaxValue = 1.5
StepAmount = 0.02
DefaultValue = 1.25
DependentOption = BumpMap

[OptionRangeFloat]
GUIName = Shade (0.75)
OptionName = shde
MinValue = 0
MaxValue = 1
StepAmount = 0.01
DefaultValue = 0.75
DependentOption = BumpMap

[OptionRangeFloat]
GUIName = Bump: lower is stronger (1.33)
OptionName = bump
MinValue = 0
MaxValue = 1.7
StepAmount = 0.02
DefaultValue = 1.33
DependentOption = BumpMap

[OptionRangeFloat]
GUIName = Range (1.00)
OptionName = range
MinValue = 0
MaxValue = 2
StepAmount = 0.02
DefaultValue = 1.00
DependentOption = BumpMap

[/configuration]
*/

float glow  = 1.25;  // max brightness on borders
float shde  = 0.75;  // max darkening
float bump  = 1.33;  // effect strenght - lower values bring more effect
float range = 1.00;  // effect width

float3 TextureSample(float2 location){
   const float x = 1.0/1024.0; //Adapt to internal resolution
   const float y = 1.0/1024.0;
   const float4 yx = float4(x,y,-x,-y)*0.5;

    float3 c11 = SampleLocation(location).xyz;
    float3 s00 = SampleLocation(location + yx.zw).xyz;
    float3 s20 = SampleLocation(location + yx.xw).xyz;
    float3 s22 = SampleLocation(location + yx.xy).xyz;
    float3 s02 = SampleLocation(location + yx.zy).xyz;
    float3 c00 = SampleLocation(location + float2(-x, -y)).xyz;
    float3 c22 = SampleLocation(location + float2(x, y)).xyz;
    float3 c20 = SampleLocation(location + float2(x, -y)).xyz;
    float3 c02 = SampleLocation(location + float2(-x, y)).xyz;
    float3 c10 = SampleLocation(location + float2(0, -y)).xyz;
    float3 c21 = SampleLocation(location + float2(x, 0)).xyz;
    float3 c12 = SampleLocation(location + float2(-x, y)).xyz;
    float3 c01 = SampleLocation(location + float2(-x, 0)).xyz;   
    float3 dt = float3(1.0,1.0,1.0);

    float d1=dot(abs(c00-c22),dt)+0.001;
    float d2=dot(abs(c20-c02),dt)+0.001;
    float hl=dot(abs(c01-c21),dt)+0.001;
    float vl=dot(abs(c10-c12),dt)+0.001;
    float m1=dot(abs(s00-s22),dt)+0.001;
    float m2=dot(abs(s02-s20),dt)+0.001;

    float3 t1=(hl*(c10+c12)+vl*(c01+c21)+(hl+vl)*c11)/(3.0*(hl+vl));
    float3 t2=(d1*(c20+c02)+d2*(c00+c22)+(d1+d2)*c11)/(3.0*(d1+d2));
   
    return 0.25*(t1+t2+(m2*(s00+s22)+m1*(s02+s20))/(m1+m2));
}


void main()
{
float4 color = Sample();
	
  //  PS_OUTPUT output;
 // float2 pos = input.t;   ???
	float2 pos = GetCoordinates();
    float x = range/2048.0; //Adapt to internal resolution
    float y = range/2048.0;
    float2 dg1 = float2( x, y); float2 dg2 = float2(-x, y);
    float2 ddx = float2(x,0.0); float2 ddy = float2(0.0,y);

    float3 c11 = TextureSample(pos.xy).xyz;
    float3 c00 = TextureSample(pos.xy - dg1).xyz;
    float3 c22 = TextureSample(pos.xy + dg1).xyz;
    float3 c10 = TextureSample(pos.xy - ddy).xyz;
    float3 c21 = TextureSample(pos.xy + ddx).xyz;
    float3 c12 = TextureSample(pos.xy + ddy).xyz;
    float3 c01 = TextureSample(pos.xy - ddx).xyz;   
    float3 d11 = c11;

    c11 = (-c00+c22-c01+c21-c10+c12+bump*d11)/bump;
    c11 = min(c11,glow*d11);
    c11 = max(c11,shde*d11);

    color.a = 1.0;
    color.xyz = c11;
	SetOutput(color);
}