
local ui = {}

local components ={}
  components.buttons ={}
  components.slider  ={}

local redraw = true
local main_canvas 
--groups[].visible ...
local groups ={
  }
local lu_types = {"buttons","slider"}



local lg = love.graphics
  local settings =
  {
    --      border col             background       label/font                 hover   clicked
    button={
            border_color={255,255,255},
            default_color={0,0,0,0},
            font_color={255,255,255},
            hover_color={50,50,50,150},
            clicked_color={0,50,0},
            font = nil
            }
  }
  
function ui.draw()
  if redraw then
  lg.setCanvas(main_canvas)
  lg.clear(0,0,0,0)
    for i =1 ,#components.buttons do
       local tmp = components.buttons[i]
       if tmp.visible then
        --draw the "background"
        love.graphics.setColor(settings.button[tmp.state.."_color"])
        love.graphics.rectangle("fill",tmp.x,tmp.y,tmp.width,tmp.height)
        --draw the "border"
        love.graphics.setColor(settings.button["border_color"])
        love.graphics.rectangle("line",tmp.x,tmp.y,tmp.width,tmp.height)
        --draw the label
        love.graphics.setColor(settings.button["font_color"])
        love.graphics.print(tmp.txt,tmp.txt_pos.x,tmp.txt_pos.y)
      end
    end
    for i,v in pairs(components["slider"]) do
      local tmp = components["slider"][i]
       if tmp.visible then
        --draw the label (value)
        love.graphics.setColor(settings.button["font_color"])
        love.graphics.print(tmp.txt,tmp.txt_pos.x,tmp.txt_pos.y)
        
        --start drawing the stuff in it ....
        --draw the "line" whcih the slider is moving on
        
        love.graphics.setColor(0,0,0,255)
        love.graphics.rectangle("fill",tmp.x+20,tmp.y+ tmp.height/2 -3,tmp.width - 40,6)
        love.graphics.setColor(settings.button["border_color"])
        love.graphics.rectangle("line",tmp.x+20,tmp.y+ tmp.height/2 -3,tmp.width - 40,6)
        
        --draw the "background"
        love.graphics.setColor(settings.button[tmp.state.."_color"])
        love.graphics.rectangle("fill",tmp.sli_pos.x,tmp.sli_pos.y,tmp.sli_pos.w,tmp.sli_pos.h)
        --draw the "border"
        love.graphics.setColor(settings.button["border_color"])
        love.graphics.rectangle("line",tmp.sli_pos.x,tmp.sli_pos.y,tmp.sli_pos.w,tmp.sli_pos.h)
      end
    end
    
      
    lg.setCanvas()
  end
love.graphics.draw(main_canvas,0,0)
end


function add_group(tab_ids,name)
  groups[#groups+1] = {}
  groups[#groups].ids =tab_ids
end


function setGroupVisibile(group,visible)
  
end

function check_components()
  local x,y = love.mouse.getX(),love.mouse.getY()
  local clicked = love.mouse.isDown(1)
  for k,name in pairs(lu_types) do
    if name == "buttons" then
       for i = 1,#components[name] do
           local tmp_b = components[name][i]
           local old =tmp_b.state 
           if  (tmp_b.x < x) and (tmp_b.y< y) and (tmp_b.x+tmp_b.width > x) and tmp_b.y+tmp_b.height > y and tmp_b.visible then
            --it is in rectangle so hover or click!!!
              
              components[name][i].state = clicked and"clicked" or "hover"
              t = clicked and components.ClickEvent(i,"test") or "nope"
           else
            components.buttons[i].state = "default" 
           end
           redraw = (old== components.buttons[i].state) and redraw or true 
       end
       
    elseif name == "slider" then
      for i,v in pairs(components[name]) do
           local tmp_b = components[name][i] -- get the item
           local old =tmp_b.state 
           if  (tmp_b.sli_pos.x < x) and (tmp_b.sli_pos.y< y) and (tmp_b.sli_pos.x+tmp_b.sli_pos.w > x) and tmp_b.sli_pos.y+tmp_b.sli_pos.h > y and tmp_b.visible then
            --it is in rectangle so hover or click!!!
              
              components[name][i].state = clicked and"clicked" or "hover"
              components[name][i].sli_pos.x =  clicked and x-tmp_b.sli_pos.w/2 or tmp_b.sli_pos.x
              
              t = clicked and components.ClickEvent(i,"test") or "nope"
           elseif  components[name][i].state == "clicked"  and clicked then
            -- it was dragged !! sooooo change x
            components[name][i].sli_pos.x = x-tmp_b.sli_pos.w/2
           else
            components[name][i].state = "default" 
           end
           redraw = (old== components[name][i].state) and redraw or true 
       end
    end
  end
  
end


function ui.AddClickHandle(callback)
  components.ClickEvent = callback
end

function ui.update()
  check_components()
end


function ui.AddSlider(value,x,y,width,height,min,max)
    local id = #components.buttons +#components.slider  +1
    local temp = {}
    
    temp.txt = label or ""
    temp.x   = x or 0
    temp.y   = y or 0
    temp.width = width or 50
    temp.height = height or 30
    temp.txt_pos = {}
    
    temp.txt_pos.x = x +50
    temp.txt_pos.y = y + 7
    
    temp.state = "default"
    temp.visible = true
    
    temp.sli_pos = {}
    temp.sli_pos.x =temp.x+temp.width/2 -10
    temp.sli_pos.y =temp.y+temp.height/2 -10
    temp.sli_pos.h = 20
    temp.sli_pos.w = 20
    
    components.slider[id] =temp
    
    redraw = true
    return id
end


function ui.AddButton(label,x,y,width,height,radius)
  local id = #components.buttons +#components.slider +1
  local temp = {}
  
  temp.txt = label or ""
  temp.x   = x or 0
  temp.y   = y or 0
  temp.width = width or 50
  temp.height = height or 30
  temp.txt_pos = {}
  
  temp.txt_pos.x = x + 10
  temp.txt_pos.y = y + 7
  
  temp.state = "default"
  temp.visible = true
  
  components.buttons[id] =temp
  
  redraw = true
  return id
end


function ui.SetColor(component,color_type,color)
  settings[component][color_type] = color
  redraw = true
end

function ui.SetVisibiliti(id,visible)
    components["buttons"][id].visible = visible 
    redraw = true
end



function ui.init()
    settings.font = love.graphics.getFont()
    main_canvas = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
end

return ui