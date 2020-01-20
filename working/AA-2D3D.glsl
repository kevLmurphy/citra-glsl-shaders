// Created by guest.r, ported to Dolphin
// Blurry at lower internal resolutions.

/*
[configuration]

[OptionBool]
GUIName = AA
OptionName = AA
DefaultValue = true

[OptionRangeFloat]
GUIName = Blur (1.7)
OptionName = param
MinValue = 1.00
MaxValue = 4.00
StepAmount = 0.10
DefaultValue = 1.70
DependentOption = AA

[/configuration]
*/


//orig: float x = 0.75/2048;
//orig: float y = 0.75/1024;
float x = 0.75*GetInvResolution().x;  //Better to use constants?
float y = 0.75*GetInvResolution().y;
vec2 dg1 = vec2( x,y);  vec2 dg2 = vec2(-x,y);
vec2 sd1 = dg1*0.5/0.75;     vec2 sd2 = dg2*0.5/0.75;
vec2 ddx = vec2(x,0.0); vec2 ddy = vec2(0.0,y);

void main()
{
	float3 color = Sample().xyz;

    float3 c11 = Sample().xyz;
    float3 s00 = SampleLocation(GetCoordinates() - sd1).xyz; 
    float3 s20 = SampleLocation(GetCoordinates() - sd2).xyz; 
    float3 s22 = SampleLocation(GetCoordinates() + sd1).xyz; 
    float3 s02 = SampleLocation(GetCoordinates() + sd2).xyz; 
    float3 c00 = SampleLocation(GetCoordinates() - dg1).xyz; 
    float3 c22 = SampleLocation(GetCoordinates() + dg1).xyz; 
    float3 c20 = SampleLocation(GetCoordinates() - dg2).xyz;
    float3 c02 = SampleLocation(GetCoordinates() + dg2).xyz;
    float3 c10 = SampleLocation(GetCoordinates() - ddy).xyz; 
    float3 c21 = SampleLocation(GetCoordinates() + ddx).xyz; 
    float3 c12 = SampleLocation(GetCoordinates() + ddy).xyz; 
    float3 c01 = SampleLocation(GetCoordinates() - ddx).xyz;     
    float3 dt = float3(1.0,1.0,1.0);

    float m1=dot(abs(s00-s22),dt)+0.001;
    float m2=dot(abs(s02-s20),dt)+0.001;

    c11 =.5*(m2*(s00+s22)+m1*(s02+s20))/(m1+m2);

    float k1 = max(dot(abs(c00-c11),dt),dot(abs(c22-c11),dt))+0.01;k1=1.0/k1;
    float k2 = max(dot(abs(c20-c11),dt),dot(abs(c02-c11),dt))+0.01;k2=1.0/k2;
    float k3 = max(dot(abs(c01-c11),dt),dot(abs(c21-c11),dt))+0.01;k3=1.0/k3;
    float k4 = max(dot(abs(c10-c11),dt),dot(abs(c12-c11),dt))+0.01;k4=1.0/k4;

    c11 = 0.5*(k1*(c00+c22)+k2*(c20+c02)+k3*(c01+c21)+k4*(c10+c12))/(k1+k2+k3+k4);

    float3 mn1 = min(min(c00,c01),c02);
    float3 mn2 = min(min(c10,c11),c12);
    float3 mn3 = min(min(c20,c21),c22);
    float3 mx1 = max(max(c00,c01),c02);
    float3 mx2 = max(max(c10,c11),c12);
    float3 mx3 = max(max(c20,c21),c22);
    mn1 = min(min(mn1,mn2),mn3);
    mx1 = max(max(mx1,mx2),mx3);

    float filterparam =  1.70; //blur param
    float3 dif1 = abs(c11-mn1) + 0.001*dt;
    float3 dif2 = abs(c11-mx1) + 0.001*dt;

    dif1=float3(pow(dif1.x,filterparam),pow(dif1.y,filterparam),pow(dif1.z,filterparam));
    dif2=float3(pow(dif2.x,filterparam),pow(dif2.y,filterparam),pow(dif2.z,filterparam));

    c11.r = (dif1.x*mx1.x + dif2.x*mn1.x)/(dif1.x + dif2.x);
    c11.g = (dif1.y*mx1.y + dif2.y*mn1.y)/(dif1.y + dif2.y);
    c11.b = (dif1.z*mx1.z + dif2.z*mn1.z)/(dif1.z + dif2.z);

    color=c11;
	

	SetOutput(float4(color,1));
}
