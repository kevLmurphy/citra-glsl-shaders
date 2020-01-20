
/*	

[OptionRangeInteger]
GUIName = ScanlineType
OptionName = A_SCANLINE_TYPE
MinValue = 0
MaxValue = 2
StepAmount = 1
DefaultValue = 0
DependentOption = K_SCAN_LINES

[OptionRangeFloat]
GUIName = ScanlineIntensity
OptionName = B_SCANLINE_INTENSITY
MinValue = 0.15
MaxValue = 0.30
StepAmount = 0.01
DefaultValue = 0.18
DependentOption = K_SCAN_LINES

[OptionRangeFloat]
GUIName = ScanlineThickness
OptionName = B_SCANLINE_THICKNESS
MinValue = 0.20
MaxValue = 0.80
StepAmount = 0.01
DefaultValue = 0.50
DependentOption = K_SCAN_LINES

[OptionRangeFloat]
GUIName = ScanlineBrightness
OptionName = B_SCANLINE_BRIGHTNESS
MinValue = 0.50
MaxValue = 2.00
StepAmount = 0.01
DefaultValue = 1.00
DependentOption = K_SCAN_LINES

[OptionRangeFloat]
GUIName = ScanlineSpacing
OptionName = B_SCANLINE_SPACING
MinValue = 0.10
MaxValue = 0.99
StepAmount = 0.01
DefaultValue = 0.25
DependentOption = K_SCAN_LINES
*/


#define lumCoeff float3(0.2126729, 0.7151522, 0.0721750)
float AvgLuminance(float3 color)
{
	return sqrt(dot(color * color, lumCoeff));
}
float4 ScanlinesPass(float4 color)
{

	int A_SCANLINE_TYPE=1;
	float B_SCANLINE_SPACING=0.99;
	float B_SCANLINE_THICKNESS=0.20;
	float B_SCANLINE_BRIGHTNESS=0.50;
	
	float B_SCANLINE_INTENSITY=0.15;
	float4 intensity;
	float2 fragcoord = float2(0.0,0.0);
	if ((A_SCANLINE_TYPE) == 0) { //X coord scanlines
		if (frac(fragcoord.y * (B_SCANLINE_SPACING)) > (B_SCANLINE_THICKNESS))
		{
			intensity = float4(0.0, 0.0, 0.0, 0.0);
		}
		else
		{
			intensity = smoothstep(0.2, (B_SCANLINE_BRIGHTNESS), color) +
				normalize(float4(color.xyz, AvgLuminance(color.xyz)));
		}
	}

	else if ((A_SCANLINE_TYPE) == 1) { //Y coord scanlines
		if (frac(fragcoord.x * (B_SCANLINE_SPACING)) > (B_SCANLINE_THICKNESS))
		{
			intensity = float4(0.0, 0.0, 0.0, 0.0);
		}
		else
		{
			intensity = smoothstep(0.2, (B_SCANLINE_BRIGHTNESS), color) +
				normalize(float4(color.xyz, AvgLuminance(color.xyz)));
		}
	}

	else if ((A_SCANLINE_TYPE) == 2) { //XY coord scanlines
		if (frac(fragcoord.x * (B_SCANLINE_SPACING)) > (B_SCANLINE_THICKNESS) &&
			frac(fragcoord.y * (B_SCANLINE_SPACING)) > (B_SCANLINE_THICKNESS))
		{
			intensity = float4(0.0, 0.0, 0.0, 0.0);
		}
		else
		{
			intensity = smoothstep(0.2, (B_SCANLINE_BRIGHTNESS), color) +
				normalize(float4(color.xyz, AvgLuminance(color.xyz)));
		}
	}

	float level = (4.0 - GetCoordinates().x) * (B_SCANLINE_INTENSITY);

	color = intensity * (0.5 - level) + color * 1.1;

	return clamp(color,0.0,1.0);
}
//float saturate(){
//return clamp(dot(normalMap, lightVector), 0.0, 1.0); 
//}
void main()
{
    float4 color = Sample();

    color = ScanlinesPass(color); 
    SetOutput(color);
}