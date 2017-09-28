minimap = {}

local BASE = (...)
print(BASE)

local string = [[vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	// get color of pixels:
  
  vec4 pixel = Texel(texture,texturePos);
  
	pixel.r = 1;
  pixel.b = 1;
  pixel.g = 1;
 // col.a = col.a * 0.5;
	// return color for current pixel
	return pixel;
}
]]

local string_2 = [[
vec4 resultCol;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	// get color of pixels:
	number alpha = 4*texture2D( texture, texturePos ).a;
	alpha -= texture2D( texture, texturePos + vec2( 0.001, 0.0f ) ).a;
	alpha -= texture2D( texture, texturePos + vec2( -0.001, 0.0f ) ).a;
	alpha -= texture2D( texture, texturePos + vec2( 0.0f, 0.001 ) ).a;
	alpha -= texture2D( texture, texturePos + vec2( 0.0f, -0.001) ).a;

	// calculate resulting color
	resultCol = vec4( 0.4f, 1.0f, 0.1f, alpha );
	// return color for current pixel
	return resultCol;
}
]]

function minimap.getShader()
    local shader = love.graphics.newShader(string_2)
    return shader
end

return minimap