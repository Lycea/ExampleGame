require "modules.ProceduralDungeon"
require "modules.Normalizer"
--require "imgui" --maybe for tuning the values at some point (?)

--shader library ...
require "ressources.shaders"
local ui = require("modules.SimpleUI.SimpleUI")


local resources = arg[1].."\\ressources\\"
local shaders = "shaders\\"

local lg = love.graphics
-- settings for the to be created dungeon
local newOptions = {
    --changeable settings
    max_width  = 20,              --max room width
    max_height = 10,              --max room height
    mean_thresh = 1.4,           --mean_thresh - bigger than that will be main rooms
    max_rooms = 50,              --max rooms , more means more rooms, more everything :P
    
    --seed options
    useSeed   = true,            --do you want to create a special seed ?
    seed      = 123456789,--1512375225,--02,                --which seed should that be :p
    
    width_circle  =  300 ,  --these both say if a dungeon will be longer or higher 
    height_circle =  100,
    
    percent_paths_added_back = 0,   --percentage of lines addedd back to the optimal way
  }



local screen_width,screen_height
local build_new = true



local edges_final ,rooms,rooms_n,main_rooms
local select_ = 0
local sel_option = 0
local map_min_x = 0
local map_min_y = 0
local map_image = 0

local actual_room = 0

local dungeon = DungeonCreator

local last_key = "enter"

local options = {
    {"new_game","load_game","options","exit"},
    {""}
  }



local map_canvas
local map_tiles


--the player table
local player = {}
player.pos = {}
  
local timer_move = 0
local creator_state = 1
  
--width and height from the map, later set  
local map_width  = 0
local map_height = 0

--function tables
local move   = {}
local finish = {}
local dummy  = {}

--all the loaded tilesets
local tilesets ={}
local npcs = {}
  
local dungeon1 = love.graphics.newCanvas(10,10)
  
--load a tileset/tileatlas
function load_tileset(file,width,height)
  
    --not sure if line is needed could be done as temp
    --tilesets_img[count+1]= gr.newImage(file
    
    local image = love.graphics.newImage(file)
  
    -- get hight / width of the tile atlas // image
    local img_h = image:getHeight()
    local img_w = image:getWidth()

    -- calc rows /lines
    local rows = img_h / height
    local cols = img_w / width
   
    local count = 1
    
    local quadset = {}
    
    local x_ = 0
    local y_ = 0
    
    
    --set also the image to the set ~
    quadset["image"] = image
    
    for i = 1, rows do
       for j = 1 , cols do
        quadset[count] = love.graphics.newQuad(x_,  y_, width, height, img_w, img_h)
        count = count + 1
        x_ = x_+height
      end
      x_ = 0
      y_ = y_ + height
    end
    
    return quadset
end
  
  
  
  
  
function spawn_enemy()
  while #npcs<5 do
    local room =love.math.random(#rooms_n)
    local x = math.random(rooms_n[room].x+1,rooms_n[room].x+rooms_n[room].width-1)
    local y = math.random(rooms_n[room].y+1,rooms_n[room].y+rooms_n[room].height-1)
    npcs[#npcs+1]={x=x,y=y}
    print("Enemy "..#npcs.." spawned: "..x.." "..y)
  end
  return {x,y}
end
  

  
function love.load()
  --set the debugger and other cmd arguments
  for i ,argu in ipairs(arg) do
      print (argu)
      if argu == "-debug" then
        require("mobdebug").start()   
      end
  end
  
  love.graphics.rectangle("fill",0,0,0,0)
  love.graphics.rectangle("line",0,0,40,10)
  love.graphics.present()
  
  --dungeon options
  DungeonCreator.setOptions(newOptions)
  DungeonCreator.newDungeon()
  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  map_canvas = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
  map_canvas:setFilter("nearest", "nearest",1)
  player.pos.x = 0
  player.pos.y = 0
  
  love.graphics.rectangle("fill",0,0,20,10)
  love.graphics.rectangle("line",0,0,40,10)
  love.graphics.present()

  
  --load resources
  shdr_minimap = minimap.getShader()
  shdr_effects = effects.getGreyShader()
  shdr_blur    = effects.getBlurShader()
  
  tilesets[#tilesets+1] = load_tileset("ressources/tilesets/BlueDungeon.png",32,32)
  tilesets[#tilesets+1] = load_tileset("ressources/tilesets/CharsTiles.png",32,32)

  -- load the ui
  ui.init()
  main_menue = {
    ui.AddButton(options[1][1],screen_width/2 -45,100,90,40,0),
    ui.AddButton(options[1][2],screen_width/2 -45,150,90,40,0),
    ui.AddButton(options[1][3],screen_width/2 -45,200,90,40,0),
    ui.AddButton(options[1][4],screen_width/2 -45,250,90,40,0),
    
  }
  ui.AddSlider("test",screen_width/2 -200,300,400,60)
  ui.AddClickHandle(button_cb)
end


function button_cb(id,name)
  print("Button "..id.." was clicked...")
end



function dummy.Update(dt)

end

function dummy.GetState()
 return "waiting"  
end

function dummy.SetData()
  
end

local debug = true


local function check_pos (x,y)
  --print(x.." "..y)
   if map_image == 0 then
    return false
  end

  return normalizer.CheckPoint(x,y)
  
 
  
--  local r, g,b  = map_image:getPixel(x,y) 
--  print("checked position: "..x.." "..y)
--  print(r.. " "..g.." "..b.." ")
--  if r + g+b == 0 then
--    return false
--  else
--    return true
--  end
  
end

function move.left ()
  if check_pos(norm_x-1,norm_y) == true then
    player.pos.x = player.pos.x -1
  end
end

function move.right ()
  
  if check_pos(norm_x+1,norm_y)== true  then
    player.pos.x = player.pos.x +1
  end
end

function move.up ()
  if check_pos(norm_x,norm_y-1) then
    player.pos.y = player.pos.y -1  
  end
end

function move.down()
  if check_pos(norm_x,norm_y +1) then
    player.pos.y = player.pos.y +1
  end
end




-- returns the finished dungeon and sets state to normalizer or whatever is needed next
finish[1]=function (module_)
    edges_final,rooms,rooms_n,main_rooms= module_.GetDungeon()
    creator_state = 2
    dungeon =   normalizer
    dungeon.SetData(edges_final,rooms_n,main_rooms)
    local start_pos = false
    
    while start_pos == false do
      
       local room =love.math.random(#rooms)
        if rooms[room].isMain then
          player.pos.x = rooms[room].CenterX
          player.pos.y = rooms[room].CenterY
          actual_room = rooms[room].id
          print("actual_room = "..actual_room)
          start_pos = true
        end
        
    end
    
end
canv = love.graphics.newCanvas(screen_width,screen_height)
finish[2]=function (module_)
    map_min_x, map_min_y= module_.GetData()
    map_height,map_width = module_.GetMaxSizes()
    
    map_min_x = map_min_x*-1
    map_min_y = map_min_y*-1
    creator_state = 3
    
    
    module_.SetTileset(tilesets[1])
    dungeon1= module_.SetTiles()
    dungeon = dummy
    map()
    
    map_image = map_canvas:newImageData()
    
    local start = love.timer.getTime()
    for i = 1 , 21000 do
      map_image:getPixel(1,1)
    end
    local stop = love.timer.getTime()
    print(stop-start)
    spawn_enemy()
end



--update function for the creation of a new dungeon
function update_creator(dt)
   if dungeon.GetState() == "finished"then
    finish[creator_state](dungeon)
  else
     dungeon.Update(dt)
  end
end



function check_keys (dt)
      if love.keyboard.isDown(last_key) and timer_move+dt > 0.04 then
        move[last_key]()
      --print(dt.. "time")
      timer_move = 0
    else
      timer_move = timer_move +dt
    end
end


function love.update(dt)
 -- imgui.NewFrame()
  
  update_creator(dt)
  
  check_keys(dt)
  
  ui.update()
end

function draw_player_pos()
  love.graphics.setColor(255,255,255)
  --love.graphics.scale(5,5)
 love.graphics.rectangle("fill",player.pos.x,player.pos.y,2,2)
 love.graphics.setColor(0xFF,0xFF,0xFF)
end

function draw_player()
  love.graphics.setColor(0xFF,0,0,170)
  love.graphics.rectangle("fill",screen_width/2 + offs_x*32,screen_height/2+offs_y*32,32,32)
  love.graphics.setColor(0xFF,0xFF,0xFF)
  love.graphics.draw(tilesets[2].image,tilesets[2][1],screen_width/2,screen_height/2)
  
end

function draw_menue()
   local m_x,m_y = love.mouse.getPosition()

  love.graphics.setFont(love.graphics.newFont(35))
  love.graphics.print("Title",screen_width/2 - screen_width/4,50)
  
  love.graphics.setFont(love.graphics.newFont(20))
  love.graphics.rectangle("line",screen_width/2 - screen_width/4 - 10,20,screen_width/2,100)

  
  for i,k  in ipairs(options[1]) do
    love.graphics.print(k,screen_width/2 - screen_width/4,100 + 50*i)
  end
  
  love.graphics.rectangle("line",screen_width/2 - screen_width/4 -10, 145+select_*50,screen_width/4,35)
  
  love.graphics.setColor(0,255,255,150)
  love.graphics.rectangle("fill",screen_width/2 - screen_width/4 -10, 145+select_*50,screen_width/4,35)
  
  love.graphics.setColor(255,0,0,255)
  love.graphics.print(m_x.."/"..m_y,m_x,m_y -10)
end


function map()
  love.graphics.setCanvas(map_canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
 -- love.graphics.translate(map_min_x*-1,map_min_y*-1)
  
  love.graphics.setColor(0,255,0,255)
  love.graphics.setLineWidth(3)
  
    for i,edge in ipairs(edges_final) do
      if edge.isL == true then
        love.graphics.line(edge.p1.x,edge.p1.y,edge.p3.x,edge.p3.y,edge.p2.x,edge.p2.y)
      else
        love.graphics.line(edge.p1.x,edge.p1.y,edge.p2.x,edge.p2.y)
      end
    end
  

  
  love.graphics.setLineWidth(1)
  for i in ipairs(rooms) do
     if rooms[i].isMain == true then
       love.graphics.setColor(255,255,255,255)
       
       
       love.graphics.setColor(255,0,0,200)
       
       love.graphics.rectangle("fill",rooms[i].x,rooms[i].y,rooms[i].width,rooms[i].height)
    
       love.graphics.setColor(255,0,0,255)
       --love.graphics.rectangle("line",rooms[i].x,rooms[i].y,rooms[i].width,rooms[i].height)
       
       love.graphics.setColor(255,255,255,255)
       --love.graphics.print(rooms[i].id,rooms[i].CenterX,rooms[i].CenterY)
     else
       

      love.graphics.setColor(255,255,255,200)
    end
   end
  
   for i in ipairs(rooms_n) do    
         love.graphics.setColor(0,200,200,200)
         
         love.graphics.rectangle("fill",rooms_n[i].x,rooms_n[i].y,rooms_n[i].width,rooms_n[i].height)
      
         love.graphics.setColor(0,200,200,255)
         love.graphics.rectangle("line",rooms_n[i].x,rooms_n[i].y,rooms_n[i].width,rooms_n[i].height)
   end
   
--   love.graphics.origin()
   love.graphics.setCanvas()
end
 norm_x = 0
 norm_y = 0


local function draw_map()
    love.graphics.scale(1,1)
   -- print(-norm_x*32 +screen_width/2 +32)
    love.graphics.translate(-norm_x*32 +screen_width/2 +32,-norm_y*32+(screen_height/2)+32)
      love.graphics.draw(dungeon1,0,0)
    love.graphics.origin()
end


local function draw_minimap()
   --draw the minimap "background"
  love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill",0,0,map_width/2+5,map_height/2+5) 
  love.graphics.setColor(255,255,255,255)
  
  --draw the minimap (scaled from the big map and added a shader)
  love.graphics.scale(0.5,0.5)
  love.graphics.translate( map_min_x or 0, map_min_y or 0)
    love.graphics.setShader(shdr_minimap)
      love.graphics.draw(map_canvas,0,0)
    love.graphics.setShader()
    draw_player_pos()
    love.graphics.setColor(255,0,0,255)
    
    for i=1, #npcs do
      love.graphics.rectangle("fill",npcs[i].x,npcs[i].y,10,10)
    end
  love.graphics.origin()  
end


function love.draw()
  --initialise stuff
  scale_x = 1
  scale_y = 1
  
  --normalized values for all!!!
  -- map to player
  norm_x =( player.pos.x + map_min_x ) * scale_x
  norm_y =( player.pos.y + map_min_y ) * scale_y

  --draw the state of the dungeon
  DungeonCreator.Draw()
  
  --reset colors and stuff before drawing a canvas... else it will take that color as kind of a bitmask for the channels
   love.graphics.setBlendMode("alpha")
   love.graphics.setColor(255, 255, 255, 255)
    
    --draw the real map
   draw_map()
   draw_player()

    for i = 1, #npcs do
      local pos_x = (npcs[i].x -player.pos.x)*32 + screen_width/2
      local pos_y = (npcs[i].y -player.pos.y)*32 + screen_height/2
     --, print(pos_x-screen_width/2 .." "..pos_y-screen_height/2)
      love.graphics.rectangle("fill",pos_x,pos_y,32,32)
    end
    love.graphics.origin()
  
 -- draw_menue()
  
  draw_minimap()
 
 love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle("fill",screen_width/2-55,17,400,20)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(DungeonCreator.GetState(),screen_width/2,20)
  love.graphics.print(love.timer.getFPS(),100,0)  
  love.graphics.print(norm_x.." "..norm_y,screen_width/2-55,20)
--  love.graphics.rectangle("fill",,32,32)

--lg.setBlendMode("subtract","premultiplied")
ui.draw()
--lg.setBlendMode("alpha","alphamultiply")
end

offs_x = 0
offs_y = 0

function love.keypressed(key,code)
  if key == "left" or key == "right" or key == "up" or key == "down" then
    last_key = key
  --  imgui.KeyPressed(key,code)
  end
  if key == "a" then
    offs_x = offs_x -1
  end
  if key == "s"then
    offs_y = offs_y +1
  end
  if key =="d" then
     offs_x = offs_x +1
  end
  if key == "w" then
    offs_y = offs_y -1
  end
  if key == "q" then
    maj,min,pat,code = love.getVersion()
   if  maj == 0 and min >= 10 and pat >= 2 then
     print("reset supported")
   else
     print("reset not supported")
    
   end
   
  end
  
  
end

function love.mousepressed(x,y,but,touch)
 -- imgui.MousePressed(x,y,but)
 if map_image == 0 then
   return
  end
 print(normalizer.CheckSum(norm_x+offs_x,norm_y+offs_y))
end

function love.mousemoved(x,y,dx,dy,tou)
 -- imgui.MouseMoved(x,y,dx,dy)
end

function love.mousereleased(x,y,but)
  --  imgui.MouseReleased(x,y,but)
end



local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end




function love.errhand(msg)
  local fi = io.open("errors.txt","a")
  fi:write(love.math.getRandomSeed().."\n")
  io.close(fi)
  
  
  
  	msg = tostring(msg)
 
	error_printer(msg, 2)
 
	if not love.window or not love.graphics or not love.event then
		return
	end
 
	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end
 
	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end
	love.graphics.reset()
	local font = love.graphics.setNewFont(math.floor(love.window.toPixels(14)))
 
	love.graphics.setBackgroundColor(89, 157, 220)
	love.graphics.setColor(255, 255, 255, 255)
 
	local trace = debug.traceback()
 
	love.graphics.clear(love.graphics.getBackgroundColor())
	love.graphics.origin()
 
	local err = {}
 
	table.insert(err, "Error\n")
	table.insert(err, msg.."\n\n")
 
	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end
 
	local p = table.concat(err, "\n")
 
	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")
 
	local function draw()
		local pos = love.window.toPixels(70)
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end
 
	while true do
		love.event.pump()
 
		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return
				end
			end
		end
 
		draw()
 
		if love.timer then
			love.timer.sleep(0.1)
		end
	end
end


