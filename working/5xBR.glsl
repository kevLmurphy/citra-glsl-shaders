
/*

   Minorly modified by Nevuk to work on Citra. The license for this file remains GPL. 
	
	
   Hyllian's 5xBR v3.5a Shader
   
   Copyright (C) 2011 Hyllian/Jararaca - sergiogdb@gmail.com
  
   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
   
*/



/*
[configuration]

[OptionBool]
GUIName = 5xBR
OptionName = BR
DefaultValue = true

[/configuration]
*/

const float coef = 2.0;
const float3 rgbw = float3(16.163, 23.351, 8.4772);

const float4 Ao = float4( 1.0, -1.0, -1.0, 1.0 );
const float4 Bo = float4( 1.0,  1.0, -1.0,-1.0 );
const float4 Co = float4( 1.5,  0.5, -0.5, 0.5 );
const float4 Ax = float4( 1.0, -1.0, -1.0, 1.0 );
const float4 Bx = float4( 0.5,  2.0, -0.5,-2.0 );
const float4 Cx = float4( 1.0,  1.0, -0.5, 0.0 );
const float4 Ay = float4( 1.0, -1.0, -1.0, 1.0 );
const float4 By = float4( 2.0,  0.5, -2.0,-0.5 );
const float4 Cy = float4( 2.0,  0.0, -1.0, 0.5 );


float4 df(float4 A, float4 B)
{
    return abs(A-B);
}

float4 weighted_distance(float4 a, float4 b, float4 c, float4 d, float4 e, float4 f, float4 g, float4 h)
{
    return (df(a,b) + df(a,c) + df(d,e) + df(d,f) + 4.0*df(g,h));
}

void main() {
	float4 color = Sample();
    bvec4 edr, edr_left, edr_up, px; // px = pixel, edr = edge detection rule
    bvec4 interp_restriction_lv1, interp_restriction_lv2_left, interp_restriction_lv2_up;
    bvec4 nc; // new_color
    bvec4 fx, fx_left, fx_up; // inequations of straight lines.
    
    float2 fp  = fract(GetCoordinates()*GetResolution());
    float2 TexCoord_0 = GetCoordinates()-fp*GetInvResolution();
    float2 dx = float2(GetInvResolution().x, 0.0);
    float2 dy = float2(0.0, GetInvResolution().y);
    float2 y2 = dy+dy; float2 x2 = dx+dx;

    float3 A  = SampleLocation(TexCoord_0 - dx - dy).xyz;
    float3 B  = SampleLocation(TexCoord_0 - dy).xyz;
    float3 C  = SampleLocation(TexCoord_0 + dx - dy).xyz;
    float3 D  = SampleLocation(TexCoord_0 - dx).xyz;
    float3 E  = SampleLocation(TexCoord_0).xyz;
    float3 F  = SampleLocation(TexCoord_0 + dx).xyz;
    float3 G  = SampleLocation(TexCoord_0  - dx + dy).xyz;
    float3 H  = SampleLocation(TexCoord_0 + dy).xyz;
    float3 I  = SampleLocation(TexCoord_0 + dx + dy).xyz;
    float3 A1 = SampleLocation(TexCoord_0  - dx - y2).xyz;
    float3 C1 = SampleLocation(TexCoord_0  + dx - y2).xyz;
    float3 A0 = SampleLocation(TexCoord_0 - x2 - dy).xyz;
    float3 G0 = SampleLocation(TexCoord_0 - x2 + dy).xyz;
    float3 C4 = SampleLocation(TexCoord_0 + x2 - dy).xyz;
    float3 I4 = SampleLocation(TexCoord_0 + x2 + dy).xyz;
    float3 G5 = SampleLocation(TexCoord_0 - dx + y2).xyz;
    float3 I5 = SampleLocation(TexCoord_0 + dx + y2).xyz;
    float3 B1 = SampleLocation(TexCoord_0 - y2).xyz;
    float3 D0 = SampleLocation(TexCoord_0 - x2).xyz;
    float3 H5 = SampleLocation(TexCoord_0 + y2).xyz;
    float3 F4 = SampleLocation(TexCoord_0 + x2).xyz;

    float4 b  = float4(dot(B ,rgbw), dot(D ,rgbw), dot(H ,rgbw), dot(F ,rgbw));
    float4 c  = float4(dot(C ,rgbw), dot(A ,rgbw), dot(G ,rgbw), dot(I ,rgbw));
    float4 d  = float4(b.y, b.z, b.w, b.x);
    float4 e  = float4(dot(E,rgbw));
    float4 f  = float4(b.w, b.x, b.y, b.z);
    float4 g  = float4(c.z, c.w, c.x, c.y);
    float4 h  = float4(b.z, b.w, b.x, b.y);
    float4 i  = float4(c.w, c.x, c.y, c.z);
    float4 i4 = float4(dot(I4,rgbw), dot(C1,rgbw), dot(A0,rgbw), dot(G5,rgbw));
    float4 i5 = float4(dot(I5,rgbw), dot(C4,rgbw), dot(A1,rgbw), dot(G0,rgbw));
    float4 h5 = float4(dot(H5,rgbw), dot(F4,rgbw), dot(B1,rgbw), dot(D0,rgbw));
    float4 f4 = float4(h5.y, h5.z, h5.w, h5.x);

    // These inequations define the line below which interpolation occurs.
    fx  = greaterThan(Ao*fp.y+Bo*fp.x,Co); 
    fx_left = greaterThan(Ax*fp.y+Bx*fp.x,Cx);
    fx_up   = greaterThan(Ay*fp.y+By*fp.x,Cy);

    interp_restriction_lv1 = bvec4(float4(notEqual(e,f))*float4(notEqual(e,h)));
    interp_restriction_lv2_left = bvec4(float4(notEqual(e,g))*float4(notEqual(d,g)));
    interp_restriction_lv2_up   = bvec4(float4(notEqual(e,c))*float4(notEqual(b,c)));

    edr      = bvec4(float4(lessThan(weighted_distance( e, c, g, i, h5, f4, h, f), weighted_distance( h, d, i5, f, i4, b, e, i)))*float4(interp_restriction_lv1));
    edr_left = bvec4(float4(lessThanEqual(coef*df(f,g),df(h,c)))*float4(interp_restriction_lv2_left)); 
    edr_up   = bvec4(float4(greaterThanEqual(df(f,g),coef*df(h,c)))*float4(interp_restriction_lv2_up));
    
    nc.x = ( edr.x && (fx.x || edr_left.x && fx_left.x || edr_up.x && fx_up.x) );
    nc.y = ( edr.y && (fx.y || edr_left.y && fx_left.y || edr_up.y && fx_up.y) );
    nc.z = ( edr.z && (fx.z || edr_left.z && fx_left.z || edr_up.z && fx_up.z) );
    nc.w = ( edr.w && (fx.w || edr_left.w && fx_left.w || edr_up.w && fx_up.w) );    

    px = lessThanEqual(df(e,f),df(e,h));

    float3 res = nc.x ? px.x ? F : H : nc.y ? px.y ? B : F : nc.z ? px.z ? D : B : nc.w ? px.w ? H : D : E;    
    color.xyz = res;
	
    SetOutput(color);
}