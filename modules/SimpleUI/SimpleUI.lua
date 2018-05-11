local BASE = (...)..'.' 
print(BASE)
local i= BASE:find("SimpleUI.$")
print (i)
BASE=BASE:sub(1,i-1)
print(BASE)

local b   = require(BASE..'Button')
local s   = require(BASE..'Slider')
local cb  = require(BASE..'Checkbox')

local ui = {}

local components ={}

local redraw = true
local main_canvas 

local focused = 0

local g_id = 1

local groups ={ }

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
  
  

  
  
function ui.draw()
  if redraw then
    lg.setCanvas(main_canvas)
    lg.clear(0,0,0,0)
    
    for i = 1 , #components do
      components[i]:draw()
    end
    
    lg.setCanvas()
  end
  lg.draw(main_canvas,0,0)
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




local function check_components()
  local x,y = love.mouse.getX(),love.mouse.getY()
  local clicked = love.mouse.isDown(1)
  local draw 
  for i =1 ,#components do
   focused , draw = components[i]:update(clicked,x,y,focused)
   if redraw == true then  else redraw = draw end
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
    

    
    temp.state = "default"
    temp.visible = true
    
    temp.sli_pos = {}
    temp.sli_pos.x =temp.x+temp.width/2 -10
    temp.sli_pos.y =temp.y+temp.height/2 -10
    temp.sli_pos.h = 20
    temp.sli_pos.w = 20
    
    --love.graphics.rectangle(mode,obj.x+20,y,obj.width - 40,6)
    temp.txt_pos.x = (temp.x + 20) + temp.width -40 +10
    temp.txt_pos.y = temp.sli_pos.y + 7
    
    temp.value  = value or 0
    temp.min    = min   or 0
    temp.max    = max   or 100
    
    temp.color = settings.button
    temp.ClickEvent = components.ClickEvent
    components[id] =s:new(temp)
    
    redraw = true
    g_id=g_id +1
    return id
end


function ui.AddButton(label,x,y,width,height,radius)
  local id = g_id
  local temp = {}
  local w = settings.font:getWidth(label)
  local p = settings.font:getHeight()
  
  temp.id  = id
  temp.txt = label or ""
  temp.x   = x or 0
  temp.y   = y or 0

  width = w > width and w+20 or width
  height = p> height and p*3 or height
  temp.width = width or 50
  temp.height = height or 30
  temp.txt_pos = {}
  
  x =math.floor(x+( width - w)/2)
  y = math.floor(y+( height -p)/2)
  
  temp.txt_pos.x = x--x + 10
  temp.txt_pos.y = y--y + 7
  
  temp.state = "default"
  temp.visible = true
  
  temp.color = settings.button
  temp.ClickEvent = components.ClickEvent
  
  components[id] =b:new(temp)
  
  redraw = true
  
  g_id =g_id +1
  return id
end

function ui.AddCheckbox(label,x,y,value)
  local id = g_id
  local temp = {}
  
  temp.id  = id
  temp.txt = label or ""
  temp.x   = x or 0
  temp.y   = y or 0
  
  temp.state = "default"
  temp.visible = true
  temp.checked = value or false
  
  temp.color = settings.button
  temp.ClickEvent = components.ClickEvent
  
  components[id] =cb:new(temp)
  
  redraw = true
  
  g_id =g_id +1
  return id
    
end


function ui.SetColor(component,color_type,color)
  settings[component][color_type] = color
  redraw = true
end

function ui.SetVisibiliti(id,visible)
  components[id].visible = visible  
  redraw = true
end



function ui.init()
    settings.font = love.graphics.getFont()
    main_canvas = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
    components.ClickEvent = function () end
end

function ui.SetSpecialCallback(id,fn)
  components[id].ClickEvent = fn
end



function ui.GetObject(id)
    return components[id]
end

return ui