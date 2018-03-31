 local  Checkbox = {}
 
 
 function Checkbox:new (o)
      o = o or {}   -- create object if user does not provide one
      o.name = "Checkbox"
      o.time = 5
      
      --set the box a bit below the actual position ...
      --TODO: make dependant on the font height!
      o.box = {}
      o.box.x = o.x -2
      o.box.y = o.y -2
      o.box.w = 20
      o.box.h = 20
      
      o.txt_pos = o.box.x + 25
      
      setmetatable(o, self)
      self.__index = self
      
      return o
end


local function check(o)
    love.graphics.setColor(o.color["font_color"])
    love.graphics.setLineWidth(5)
    love.graphics.line(o.box.x,o.box.y ,o.box.x + o.box.h, o.box.y + o.box.w)
    love.graphics.line(o.box.x , o.box.y +o.box.h, o.box.x +o.box.w,o.box.y)
    love.graphics.setLineWidth(1)
end

local function uncheck(o)
    
end



function Checkbox.draw(obj)
  
  if obj.visible then
    --draw the "background" ( for the box)
    love.graphics.setColor(obj.color[obj.state.."_color"][1],obj.color[obj.state.."_color"][2],obj.color[obj.state.."_color"][3],obj.color[obj.state.."_color"][4])
    love.graphics.rectangle("fill",obj.box.x,obj.box.y,obj.box.w,obj.box.h)
    
    --draw the "border"
    love.graphics.setColor(obj.color["border_color"])
    love.graphics.rectangle("line",obj.box.x,obj.box.y,obj.box.w,obj.box.h)
    --draw the label
    love.graphics.setColor(obj.color["font_color"])
    love.graphics.print(obj.txt,obj.txt_pos,obj.y)
    
     t = obj.checked and check(obj) or uncheck(obj)
  end
end




function Checkbox.update(obj,clicked,x,y,focused)
   local redraw = false
   local old =obj.state 
   
   local time = love.timer.getDelta()
   
   
   --check if the mouse is in the clickable region
   if (obj.box.x < x) and (obj.box.y< y) and (obj.box.x+obj.box.w > x) and obj.box.y+obj.box.h > y and obj.visible then
      --it is in rectangle so hover or click!!!
      if focused == 0 or focused == obj.id then
        focused = obj.id
        obj.state = clicked  and"clicked" or "hover"
        obj.time = obj.time +time
        
        --check if long enough time has passed since last click 
        if obj.time >0.2 and clicked then 
            t = clicked and obj.ClickEvent(obj.id,obj.name) or "nope"
            obj.checked = not obj.checked
            obj.time = 0
        end
      end
   else
     --if not in the rectangle reset the state
     if focused == obj.id then focused = 0 end 
       obj.state = "default" 
     
   end
   redraw = (old== obj.state) and redraw or true 
   return focused, redraw
end

return Checkbox