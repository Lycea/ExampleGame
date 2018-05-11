 local Slider = {}
 
   local function lerp_(x,y,t) local num = x+t*(y-x)return num end
  
  
  local function percent_(x,y,z) return (x -z)/(x - y) end
  
  
local function clamp(min, max, val)
    return math.max(min, math.min(val, max));
end
  
 
 function Slider:new (o)
      o = o or {}   -- create object if user does not provide one
      o.name = "Slider"
      o.precision = 1
      --Todo: please also set the right position here ...
      setmetatable(o, self)
      self.__index = self
      
      local per = percent_(o.min,o.max,o.value)
      print(per)
      o.sli_pos.x = math.ceil( lerp_(o.x +10,o.x+o.width-20,per))
      
      return o
end


function Slider.setPrecision(obj,precision)
    if precision <0 then
        precision =0
    end
    
    obj.precision = precision
end


function Slider.draw(obj)

  if obj.visible then
        --draw the label (value)
        love.graphics.setColor(obj.color["font_color"])
        love.graphics.print(obj.value,obj.txt_pos.x,obj.txt_pos.y)
        
        --start drawing the stuff in it ....
        --draw the "line" whcih the slider is moving on
        
        love.graphics.setColor(0,0,0,255)
        love.graphics.rectangle("fill",obj.x+20,obj.y+ obj.height/2 -3,obj.width - 40,6)
        love.graphics.setColor(obj.color["border_color"])
        love.graphics.rectangle("line",obj.x+20,obj.y+ obj.height/2 -3,obj.width - 40,6)
        
        --draw the "background"
        love.graphics.setColor(obj.color[obj.state.."_color"])
        love.graphics.rectangle("fill",obj.sli_pos.x,obj.sli_pos.y,obj.sli_pos.w,obj.sli_pos.h)
        --draw the "border"
        love.graphics.setColor(obj.color["border_color"])
        love.graphics.rectangle("line",obj.sli_pos.x,obj.sli_pos.y,obj.sli_pos.w,obj.sli_pos.h)
      end
end




function Slider.update(obj,clicked,x,y,focused)
  local redraw = false
  local old =obj.state 
  
  local min = obj.x +10
  local max = obj.x+obj.width-20
   
   if  (obj.sli_pos.x < x) and (obj.sli_pos.y< y) and (obj.sli_pos.x+obj.sli_pos.w > x) and obj.sli_pos.y+obj.sli_pos.h > y and obj.visible then
    --it is in rectangle so hover or click!!!
      
      if focused == 0 or focused == obj.id then
        focused = obj.id
        obj.state = clicked and"clicked" or "hover"
        obj.sli_pos.x =  clamp(min,max,clicked and x-obj.sli_pos.w/2 or obj.sli_pos.x) 
        
        local per =      ((min) -obj.sli_pos.x)/((min) - (max))
        obj.value = lerp_(obj.min,obj.max,per)
      end
   elseif  obj.state == "clicked"  and clicked then
    -- it was dragged !! sooooo change x
    
      obj.sli_pos.x =  clamp(min,max,x-obj.sli_pos.w/2)
      
      local per =      ((min) -obj.sli_pos.x)/((min) - (max))
      obj.value = lerp_(obj.min,obj.max,per)
   
   else
     if focused == obj.id then focused = 0 end
       obj.state = "default" 
     end
   --print(components[name][i].value)
        obj.value = math.floor(obj.value*math.pow(10,obj.precision))/math.pow(10,obj.precision)
   --obj.value  = math.floor(obj.value )
   redraw = (old== obj.state) and redraw or true 

  return focused, redraw
end

return Slider