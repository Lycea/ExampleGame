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
function minimap.getShader()
    local shader = love.graphics.newShader(string)
    return shader
end

return minimap