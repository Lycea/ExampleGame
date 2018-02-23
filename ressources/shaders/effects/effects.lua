effects = {}

local BASE = (...)
print(BASE)

local string_2 = [[
vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
  number average = (pixel.r+pixel.b+pixel.g)/3.0;
  pixel.r = average;
  pixel.g = average;
  pixel.b = average;
  return pixel;
}
]]

local string_3 = [[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
		{

		number pW = 1/love_ScreenSize.x;//pixel width 
		number pH = 1/love_ScreenSize.y;//pixel height

		vec4 pixel = Texel(texture, texture_coords );//This is the current pixel 

		vec2 coords = vec2(texture_coords.x-pW,texture_coords.y);
		vec4 Lpixel = Texel(texture, coords );//Pixel on the left

		coords = vec2(texture_coords.x+pW,texture_coords.y);
		vec4 Rpixel = Texel(texture, coords );//Pixel on the right

		coords = vec2(texture_coords.x,texture_coords.y-pH);
		vec4 Upixel = Texel(texture, coords );//Pixel on the up

		coords = vec2(texture_coords.x,texture_coords.y+pH);
		vec4 Dpixel = Texel(texture, coords );//Pixel on the down

		pixel.a += 10 * 0.0166667 * (Lpixel.a + Rpixel.a + Dpixel.a * 3 + Upixel.a - 6 * pixel.a);

		pixel.rgb = vec3(1.0,1.0,1.0);


		return pixel;}
]]

function effects.getGreyShader()
    local shader = love.graphics.newShader(string_2)
    return shader
end

function effects.getBlurShader()
    local shader = love.graphics.newShader(string_3)
    return shader
end
return effects