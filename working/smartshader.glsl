//Ported from Pete's OGL2 shader pack.
//Doesn't seem to work well. Needs either more support from dolphin or for someone else to mess with it.

/*
[configuration]

[OptionBool]
GUIName = Smart Shader
OptionName = SMART
DefaultValue = true
[/configuration]
*/

float2 IntRes = GetResolution();
float2 InvIntRes = GetInvResolution();

float ColourDistance(float3 e1, float3 e2)
{
  	float rmean = (e1.r+e2.r)*0.5;
  	float r = e1.r-e2.r;
  	float g = e1.g-e2.g;
  	float b = e1.b-e2.b;
  	return sqrt((2.0+0.5*rmean)*r*r+4.0*g*g+(3.0-rmean)*b*b);
}

float ColourLength(float3 e1)
{
  	float rmean = e1.r*0.5;
  	float r = e1.r;
  	float g = e1.g;
  	float b = e1.b;
  	return sqrt((2.0+rmean)*r*r+4.0*g*g+(3.0-rmean)*b*b);
}

// compute 4-texel color variance.
float var4(float3 t0, float3 t1, float3 t2, float3 t3)
{  
	float var;
	float f0 = ColourLength(t0);
	float f1 = ColourLength(t1);
	float f2 = ColourLength(t2);
	float f3 = ColourLength(t3);
	var = max(max(f0,f1),max(f2,f3))-min(min(f0,f1),min(f2,f3));
	return var;
}

// compute 3-texel color variance.
float var3(float3 t0, float3 t1, float3 t2)
{  
	float var;
	float f0 = ColourLength(t0);
	float f1 = ColourLength(t1);
	float f2 = ColourLength(t2);
	var = max(max(f0,f1),f2)-min(min(f0,f1),f2);
	return var;
}

// compute 2-texel color variance.
float var2(float3 t0, float3 t1)
{  
	float var;
	var = ColourDistance(t0,t1);
	return var;
}

float3 lrp(float3 A, float3 B, float u)
{  
	return ((B-A)*u+A);
}

void main(void)
{   
	float3 color = Sample().xyz;
	float2 position = GetCoordinates() - InvIntRes * 0.5;
	float2 texelFract = fract(position * IntRes);
 	position = floor(position * IntRes) * InvIntRes + InvIntRes * 0.5;

	//	AB
	//	DC
	float3 A = SampleLocation(position).rgb;		
	float3 B = SampleLocation(position + float2(InvIntRes.x, 0.0)).rgb;
	float3 C = SampleLocation(position + InvIntRes).rgb;
	float3 D = SampleLocation(position + float2(0.0, InvIntRes.y)).rgb;
	color = A;
	float u = texelFract.x;
	float v = texelFract.y;

	float ColThreshold = 0.3;

	if ( u >= 0.5 && v >= 0.5 )
	{
	color = C;
	}
	else 
	if ( u < 0.5 && v >= 0.5 )
	{
	color = D;
	}
	else
	if ( u >= 0.5 && v < 0.5 )
	{
	color = B;
	}

	// 0
	if(var4(A,B,C,D) < ColThreshold)
	{
	color = lrp(lrp(A,B,u),lrp(D,C,u),v);
	}

	// 3
	else 
      if(var3(A,B,D) < ColThreshold && (u + v) < 1.5 )
	{
	color = lrp(lrp(A,B,u),D,v);
	}

	// 4
	else 
      if(var3(A,B,C) < ColThreshold && (v - u) < 0.5 )
	{
	color = lrp(lrp(A,B,u),C,v);
	}

	// 5
	else 
      if(var3(B,C,D) < ColThreshold && (u + v) >= 0.5 )
	{
	color = lrp(B,lrp(D,C,u),v);
	}

	// 6
	else 
      if(var3(A,C,D) < ColThreshold && (v - u) >=-0.5 )
	{
	color = lrp(A,lrp(D,C,u),v);
	}

	// 7
	else 
      if(var2(D,C) < ColThreshold && v >= 0.5 )
	{
	color = lrp(D,C,u);
	}

	// 8
	else 
      if(var2(A,B) < ColThreshold && v < 0.5 )
	{
	color = lrp(A,B,u);
	}

	// 9
	else 
      if(var2(B,C) < ColThreshold && u >= 0.5 )
	{
	color = lrp(B,C,v);
	}

	//10
	else 
      if(var2(A,D) < ColThreshold && u < 0.5 )
	{
	color = lrp(A,D,v);
	}

	//11
	else 
      if(var2(A,C) < ColThreshold && var2(A,C) < var2(B,D) && ( v - u ) >= -0.5 && ( v - u ) < 0.5 )
	{
	color = lrp(A,C,(u+v)*0.5);
	}

	//12
	else 
      if(var2(B,D) < ColThreshold && var2(B,D) < var2(A,C) && ( u + v ) >= 0.5 && ( u + v ) < 1.5 )
	{
	color = lrp(B,D,(v-u+1.0)*0.5);
	}
    
	SetOutput(float4(color,1.0));
}
