;//Fullscreen Smoothing + Scanlines Filter by ShinRa358 (Edited from nightvision2scanlines)


void main()
{
  //variables
    // Horizontal Scanlines
  //float vPos = uv0.y*resolution.y / 2; // <--- # to the left of the ';' for scanline thickness [Higher# = THICKER / Lower# = THINNER] ***DON'T GO BELOW 2*** | ***9999 = SCANLINES OFF***
 //float line_intensity = (((vPos - floor(vPos)) * 9) - 4) / 50; // <--- # to the left of the ';' for scanline darkness [Higher# = LIGHTER / Lower# = DARKER] ***DON'T GO BELOW 25***

  float4 c0 = Sample();
  float vPos = GetCoordinates().y*GetResolution().y / 2;
  float line_intensity = (((vPos - floor(vPos)) * 9) - 4) / 50;
  c0.rgb += line_intensity;
  SetOutput(c0);
}