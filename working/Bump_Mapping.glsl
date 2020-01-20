/*
  Bump mapping shader coded by guest.r, ported to dolphin by One More Try.
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

void main()
{
float4 color = Sample();
    float x = (range)/2048.0;  //make 2048 variable based on internal res?
    float y = (range)/2048.0;

    float4 c11 = color;
    float4 c00 = SampleLocation(GetCoordinates() + float2(-x, -y));
    float4 c22 = SampleLocation(GetCoordinates() + float2(x, y));
    float4 c10 = SampleLocation(GetCoordinates() + float2(0, -y));
    float4 c21 = SampleLocation(GetCoordinates() + float2(x, 0));
    float4 c12 = SampleLocation(GetCoordinates() + float2(0, y));
    float4 c01 = SampleLocation(GetCoordinates() + float2(-x, 0));   
    float4 d11 = c11;

    c11 = (-c00+c22-c01+c21-c10+c12+bump*d11)/bump;
    c11 = min(c11,glow*d11);
    c11 = max(c11,shde*d11);
	color = float4(c11.r,c11.g,c11.b,1.0);
    SetOutput(color);
}