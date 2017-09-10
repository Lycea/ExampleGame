vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	// get color of pixels:
  
  vec4 pixel = Texel(texture,texturePos);
  
	pixel.r = pixel.r * 1;
  pixel.b = pixel.b * 0;
  pixel.g = pixel.g * 0;
 // col.a = col.a * 0.5;
	// return color for current pixel
	return pixel;
}
