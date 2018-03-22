
local ui = {}

local components ={}
  components.buttons ={}
  components.slider  ={}

local redraw = true
local main_canvas 

local focused = 0

local g_id = 1
--groups[].visible ...
local groups ={
  }
local lu_types = {"buttons","slider"}

local lg = love.graphics
  local settings =
  {
    --      border col             background       label/font                 hover   clicked
    button={
            border_color={255,255,255,255},
            default_color={0,0,0,0,255},
            font_color={255,255,255,255},
            hover_color={50,50,50,250},
            clicked_color={0,50,0,255},
            font = nil
            }
  }
  
  
  local function lerp_(x,y,t) local num = x+t*(y-x)return num end
  
  
  local function percent_(x,y,z) return (x -z)/(x - y) end
  
  
local function clamp(min, max, val)
    return math.max(min, math.min(val, max));
end
  
  
  
local function draw_button(tmp)
    if tmp.visible then
        --draw the "background"
        love.graphics.setColor(settings.button[tmp.state.."_color"][1],settings.button[tmp.state.."_color"][2],settings.button[tmp.state.."_color"][3],settings.button[tmp.state.."_color"][4])
        love.graphics.rectangle("fill",tmp.x,tmp.y,tmp.width,tmp.height)
        --draw the "border"
        love.graphics.setColor(settings.button["border_color"])
        love.graphics.rectangle("line",tmp.x,tmp.y,tmp.width,tmp.height)
        --draw the label
        love.graphics.setColor(settings.button["font_color"])
        love.graphics.print(tmp.txt,tmp.txt_pos.x,tmp.txt_pos.y)
      end
  end
  
  
local function draw_slider(tmp)
    if tmp.visible then
        --draw the label (value)
        love.graphics.setColor(settings.button["font_color"])
        love.graphics.print(tmp.value,tmp.txt_pos.x,tmp.txt_pos.y)
        
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
  
  
function ui.draw()
  if redraw then
    lg.setCanvas(main_canvas)
    lg.clear(0,0,0,0)
    
    for i =1 ,#components.buttons do
       local tmp = components.buttons[i]
       draw_button(tmp)
    end
    
    for i,v in pairs(components["slider"]) do
       local tmp = components["slider"][i]
       draw_slider(tmp)
    end
    
    
    lg.setCanvas()
  end
  love.graphics.draw(main_canvas,0,0)
end


function ui.AddGroup(tab_ids,name)
  groups[name] = {}
  groups[name].ids =tab_ids
end


function ui.SetGroupVisible(name,visible)
  --iterate over ids
  for k,v in pairs(groups[name].ids) do
    ui.SetVisibiliti(v,visible)
  end
  
end

local function check_buttons(clicked,x,y)
  for i = 1,#components["buttons"] do
   local tmp_b = components["buttons"][i]
   local old =tmp_b.state 
   if (tmp_b.x < x) and (tmp_b.y< y) and (tmp_b.x+tmp_b.width > x) and tmp_b.y+tmp_b.height > y and tmp_b.visible then
      --it is in rectangle so hover or click!!!
      if focused == 0 or focused == tmp_b.id then
        focused = tmp_b.id
        components["buttons"][i].state = clicked  and"clicked" or "hover"
        t = clicked and components.ClickEvent(i,"test") or "nope"
      end
   else
     if focused == tmp_b.id then focused = 0 end
       components.buttons[i].state = "default" 
     end
     redraw = (old== components.buttons[i].state) and redraw or true 
   end
end


local function check_slider(clicked,x,y)
   for i,v in pairs(components["slider"]) do
           local tmp_b = components["slider"][i] -- get the item
           local old =tmp_b.state 
           if  (tmp_b.sli_pos.x < x) and (tmp_b.sli_pos.y< y) and (tmp_b.sli_pos.x+tmp_b.sli_pos.w > x) and tmp_b.sli_pos.y+tmp_b.sli_pos.h > y and tmp_b.visible then
            --it is in rectangle so hover or click!!!
              
              if focused == 0 or focused == tmp_b.id then
                focused = tmp_b.id
                components["slider"][i].state = clicked and"clicked" or "hover"
                components["slider"][i].sli_pos.x =  clamp(tmp_b.x +10,tmp_b.x+tmp_b.width-20,clicked and x-tmp_b.sli_pos.w/2 or tmp_b.sli_pos.x) 
                
                local per =      ((tmp_b.x + 10) -tmp_b.sli_pos.x)/((tmp_b.x + 10) - (tmp_b.x+tmp_b.width-20))
                components["slider"][i].value = lerp_(tmp_b.min,tmp_b.max,per)
              end
           elseif  components["slider"][i].state == "clicked"  and clicked then
            -- it was dragged !! sooooo change x
            
              components["slider"][i].sli_pos.x =  clamp(tmp_b.x + 10,tmp_b.x+tmp_b.width-20,x-tmp_b.sli_pos.w/2)
              
              local per =      ((tmp_b.x + 10) -tmp_b.sli_pos.x)/((tmp_b.x + 10) - (tmp_b.x+tmp_b.width-20))
              components["slider"][i].value = lerp_(tmp_b.min,tmp_b.max,per)
           
           else
             if focused == tmp_b.id then focused = 0 end
               components["slider"][i].state = "default" 
             end
           --print(components[name][i].value)
           components["slider"][i].value  = math.floor(components["slider"][i].value )
           redraw = (old== components["slider"][i].state) and redraw or true 
          end
end


local function check_components()
  local x,y = love.mouse.getX(),love.mouse.getY()
  local clicked = love.mouse.isDown(1)
  for k,name in pairs(lu_types) do
    if name == "buttons" then
       check_buttons(clicked,x,y)
    elseif name == "slider" then
        check_slider(clicked,x,y)
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
    local id = g_id--#components.buttons +#components.slider  +1
    local temp = {}
    
    temp.id  = id
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
    
    temp.value  = value or 0
    temp.min    = min   or 0
    temp.max    = max   or 100
    components.slider[id] =temp
    
    redraw = true
    g_id=g_id +1
    return id
end


function ui.AddButton(label,x,y,width,height,radius)
  local id = g_id--#components.buttons +#components.slider +1
  local temp = {}
  
  temp.id  = id
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
  
  g_id =g_id +1
  return id
end


function ui.SetColor(component,color_type,color)
  settings[component][color_type] = color
  redraw = true
end

function ui.SetVisibiliti(id,visible)
  for k,tab_comp in pairs(components) do
    if type(tab_comp) == "function" then
      break
    end
    for i,v in pairs(tab_comp) do
         if v.id == id  then
           v.visible = visible 
           redraw = true
           return
         end
         
    end
  end
    
      --components["buttons"][id].visible = visible 
   -- redraw = true
end



function ui.init()
    settings.font = love.graphics.getFont()
    main_canvas = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
end

return ui