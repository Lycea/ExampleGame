--load all neeeded libraries
local er = require "modules.ErrorHandler.error"
require "modules.ProceduralDungeon"
require "modules.Normalizer"
local temp = require "modules.Debugster"
d = temp.debugster
ui = require("modules.SimpleUI.SimpleUI")


npcs_ = require("modules.npcs.enemies")

--shader library ...
require "ressources.shaders"


local resources = arg[1].."\\ressources\\"
local shaders = "shaders\\"

local gr = love.graphics

--TODO: for later create a module with settings for different levels :P
-- settings for the to be created dungeon ( first levels)
local newOptions = {
    --changeable settings
    max_width  = 20,              --max room width
    max_height = 10,              --max room height
    mean_thresh = 0.1,           --mean_thresh - bigger than that will be main rooms
    max_rooms = 10,              --max rooms , more means more rooms, more everything :P
    
    --seed options
    useSeed   = false,            --do you want to create a special seed ?
    seed      = 1522581818, --123456789,--1512375225,--02,   some seeds!
    
    width_circle  =  300 ,  --these both say if a dungeon will be longer or higher 
    height_circle =  100,
    
    percent_paths_added_back = 0,   --percentage of lines addedd back to the optimal way
  }



local screen_width,screen_height
local build_new = true



--local edges_final ,rooms,rooms_n,main_rooms
local select_ = 0
local sel_option = 0

local actual_room = 0
local goal_room   = 0

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

--function tables
local move   = {}
local finish = {}
local dummy  = {}

--all the loaded tilesets
local tilesets ={}
local npcs = {}




local MAX_DUNGEONS = 2
local actual_created_d = 1

local active_dungeon = 0

local dungeons = {}
  
local function dist(p1,p2) return ((p2.x-p1.x)^2+(p2.y-p1.y)^2)^0.5 end
--load a tileset/tileatlas
local function load_tileset(file,width,height)
  
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
  
  
  
  
  
local function spawn_enemy()
  while #npcs<20 do
    local room =love.math.random(#dungeons[active_dungeon].rooms_n)
    local x = math.random(dungeons[active_dungeon].rooms_n[room].x+2,dungeons[active_dungeon].rooms_n[room].x+dungeons[active_dungeon].rooms_n[room].width)
    local y = math.random(dungeons[active_dungeon].rooms_n[room].y+2,dungeons[active_dungeon].rooms_n[room].y+dungeons[active_dungeon].rooms_n[room].height)
    npcs[#npcs+1]={x=x,y=y}
    print("Enemy "..#npcs.." spawned: "..x.." "..y)
  end
  return {x,y}
end
  

  
function love.load()
--os.execute("mkdir " .. "profile")
  --set the debugger and other cmd arguments
  for i ,argu in ipairs(arg) do
      --print (argu)
      if argu == "-debug" then
        require("mobdebug").start()   
      end
  end
  ui.init()
  ui.AddClickHandle(button_cb)
  
  d.init()
  
  npcs_.init()
  
  
  --d.profile.hookall("Lua")
  --d.profile.start()
  
  
  --loading bar
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
  shdr_light   = effects.getLightShader()
  
  --send the default shader values
  shdr_light:send("min",0)
  shdr_light:send("max",1)
  
  --load the tilesets ...
  tilesets[#tilesets+1] = load_tileset("ressources/tilesets/BlueDungeon.png",32,32)
  tilesets[#tilesets+1] = load_tileset("ressources/tilesets/CharsTiles.png",32,32)
  tilesets[#tilesets+1] = load_tileset("ressources/tilesets/Enemies.png",32,32)

  -- create the ui
  
  main_menue = {
    --ui.AddButton(options[1][1],screen_width/2 -45,100,90,40,0),
    --ui.AddButton(options[1][2],screen_width/2 -45,150,90,40,0),
    --ui.AddButton(options[1][3],screen_width/2 -45,200,90,40,0),
    --ui.AddButton(options[1][4],screen_width/2 -45,250,90,40,0),
    
    --           det, pos x           ,pos y, w  ,h ,min,max
    ui.AddSlider("0",0,300,200,30,0,1),
    ui.AddSlider("0.3",0,500,200,30,0,1),
    
    --ui.AddCheckbox("test",screen_width/2 -200,600,false)
  }

  ui.AddGroup(main_menue,"menue")
  ui.SetGroupVisible("menue",false)
    
  --get the two sliders ...
  sli_min = ui.GetObject(main_menue[1])
  sli_max = ui.GetObject(main_menue[2])
  
  
end


local function button_cb(id,name)
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


local function check_pos (x,y,look_)
  --print(x.." "..y)

  return normalizer.CheckPoint(x,y,look_)
end

function move.left ()
  if dungeons[active_dungeon]  == nil then return end
  if check_pos(norm_x-1,norm_y,dungeons[active_dungeon].lookup) == true then
    player.pos.x = player.pos.x -1
  end
end

function move.right ()
  if dungeons[active_dungeon]  == nil then return end
  if check_pos(norm_x+1,norm_y,dungeons[active_dungeon].lookup)== true  then
    player.pos.x = player.pos.x +1
  end
end

function move.up ()
  if dungeons[active_dungeon]  == nil then return end
  if check_pos(norm_x,norm_y-1,dungeons[active_dungeon].lookup) then
    player.pos.y = player.pos.y -1  
  end
end

function move.down()
    if dungeons[active_dungeon]  == nil then return end
  if check_pos(norm_x,norm_y +1,dungeons[active_dungeon].lookup) then
    player.pos.y = player.pos.y +1
  end
end




-- returns the finished dungeon and sets state to normalizer or whatever is needed next
finish[1]=function (module_)
    dungeons[actual_created_d] = {}
    
    local edges_final,rooms,rooms_n,main_rooms = module_.GetDungeon()
    creator_state = 2
    dungeon =   normalizer
    dungeon.reset()
    
    dungeon.SetData(edges_final,rooms_n,main_rooms)
    local start_pos = false
    local start = nil
    local start_room =0
    local pos = {}
    
    
    while start_pos == false do
      
       local room =love.math.random(#rooms)
        if rooms[room].isMain then
          pos.x = rooms[room].CenterX
          pos.y = rooms[room].CenterY
          start_room  = rooms[room].id
          print("actual_room = "..actual_room)
          start_pos = true
          start = rooms[room]
        end
        
    end
    local goal_ = {}
    local goal_pos = {}
    
    local max_dist = {}
    max_dist.id = 0
    max_dist.dist = 0
    
    
    --TODO: Is that the best possibility or should it be another way to set the goal ?
    --get the main room that is the farthest away and set it as the end room of the level
    for i=1,#rooms do 
        if rooms[i].isMain then
            print("room "..i)
            local d=dist(rooms[i],start)
            if d >max_dist.dist then
                max_dist.id = rooms[i].id
                max_dist.dist = d
                print("new: "..max_dist.id.." distance: "..max_dist.dist)
            end
        end
    end
    
    goal_ = rooms[max_dist.id]
  
    
    goal_pos.x = love.math.random(goal_.x+1,goal_.x +goal_.width-1)
    goal_pos.y = love.math.random(goal_.y+1,goal_.y +goal_.height-1)
    
    
    
    print("End room "..max_dist.id.." distance: "..max_dist.dist)
    
    dungeons[actual_created_d].edges_final = edges_final
    dungeons[actual_created_d].rooms       = rooms
    dungeons[actual_created_d].rooms_n     = rooms_n
    dungeons[actual_created_d].main_rooms  = main_rooms
    
    dungeons[actual_created_d].start    = pos
    dungeons[actual_created_d].start.id = start_room
    
    dungeons[actual_created_d].goal    = goal_pos
    dungeons[actual_created_d].goal.id = goal_.id
end


canv = love.graphics.newCanvas(screen_width,screen_height)
finish[2]=function (module_)
    --get data about the map
    local map_min_x, map_min_y,lookup,room_look= module_.GetData()
    local map_height,map_width = module_.GetMaxSizes()
    
    
    map_min_x = map_min_x*-1
    map_min_y = map_min_y*-1
    
    
    dungeons[actual_created_d].map_min_x    = map_min_x
    dungeons[actual_created_d].map_min_y    = map_min_y
    dungeons[actual_created_d].lookup       = lookup
    dungeons[actual_created_d].room_lookup  = room_look
    
    dungeons[actual_created_d].map_height = map_height
    dungeons[actual_created_d].map_width  = map_width
   
    
    --set the wanted dungeon tileset... and create the map
    module_.SetTileset(tilesets[1])
    dungeons[actual_created_d].map= module_.SetTiles()
    
    dungeon.reset()
    --check if the buffer is big enough right now
    if #dungeons == MAX_DUNGEONS then
        dungeon = dummy
        
        --adjust creator state
        creator_state = 3
    else
        creator_state = 1
        newOptions.seed = newOptions.seed +1
        newOptions.useSeed = false
        DungeonCreator.setOptions(newOptions)
        DungeonCreator.newDungeon()
        
        
        dungeon = DungeonCreator
    end
    
    dungeons[actual_created_d].minimap_canv =map()
    dungeons[actual_created_d].minimap_img = dungeons[actual_created_d].minimap_canv:newImageData()
    
    if active_dungeon == 0 then
        active_dungeon = 1
        player.pos.x =dungeons[actual_created_d].start.x
        player.pos.y =dungeons[actual_created_d].start.y
    end
    
    --TODO: spawning should be handled in the update 
    spawn_enemy()
    
    actual_created_d = actual_created_d+1
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



deb_frame = 1
report = nil



local function switch_levels()
    print("hii")
    --remove dungeon and let it calculate a new one !!
    
    table.remove(dungeons,1)
    dungeon = DungeonCreator
    
    creator_state = 1
    newOptions.seed = newOptions.seed +1
    newOptions.useSeed = false
    DungeonCreator.setOptions(newOptions)
    DungeonCreator.newDungeon()
    normalizer.reset()
    
    player.pos.x =dungeons[active_dungeon].start.x
    player.pos.y =dungeons[active_dungeon].start.y
    
    actual_created_d = 2
    
    
    npcs = {}
    spawn_enemy()
end

local function check_player_pos()
    if active_dungeon == 0 then return end
    if player.pos.x == dungeons[active_dungeon].goal.x and player.pos.y == dungeons[active_dungeon].goal.y then
        switch_levels()
    end

end


function love.update(dt)
  
  update_creator(dt)
  check_keys(dt)
  
  check_player_pos()

  ui.update()
  
  deb_frame = deb_frame +1
  
  --write out profiler data all 100 frames
  if deb_frame %100 == 0  and false then
    --report = profile.report("time",1000)
    --profile.reset()
    local n = 1
    local fi =io.open(".\\profile\\"..os.time()..".csv","w")
    
    if fi == nil then
        
    else
        fi:write('Position;Function name;Number of calls;Time;Source;Min_exec;Max_exec\n')
        for func, called, elapsed, source,min,max in d.profile.query("time", 1000) do
          local t = {n, func, called,  string.gsub(tostring(elapsed),"%p",","), source,string.gsub(tostring(min),"%p",","),string.gsub(tostring(max),"%p",",") }
          fi:write(table.concat(t, ";")..";".."\n")
          --print(table.concat(t, ";")..";")
          n = n + 1
        end
        fi:close()
    end
    
  end
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



--generate the minimap canvas once
function map()
  local temp_map = love.graphics.newCanvas(screen_width,screen_height)
  love.graphics.setCanvas(temp_map)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
 -- love.graphics.translate(map_min_x*-1,map_min_y*-1)
  
  love.graphics.setColor(0,255,0,255)
  love.graphics.setLineWidth(3)
  
    for i,edge in ipairs(dungeons[actual_created_d].edges_final) do
      if edge.isL == true then
        love.graphics.line(edge.p1.x,edge.p1.y,edge.p3.x,edge.p3.y,edge.p2.x,edge.p2.y)
      else
        love.graphics.line(edge.p1.x,edge.p1.y,edge.p2.x,edge.p2.y)
      end
    end
  

  
  love.graphics.setLineWidth(1)
  for i in ipairs(dungeons[actual_created_d].rooms) do
     if dungeons[actual_created_d].rooms[i].isMain == true then
       love.graphics.setColor(255,255,255,255)
       
       
       love.graphics.setColor(255,0,0,200)
       
       love.graphics.rectangle("fill",dungeons[actual_created_d].rooms[i].x,dungeons[actual_created_d].rooms[i].y,dungeons[actual_created_d].rooms[i].width,dungeons[actual_created_d].rooms[i].height)
    
       love.graphics.setColor(255,0,0,255)
       --love.graphics.rectangle("line",rooms[i].x,rooms[i].y,rooms[i].width,rooms[i].height)
       
       love.graphics.setColor(255,255,255,255)
       --love.graphics.print(rooms[i].id,rooms[i].CenterX,rooms[i].CenterY)
     else
       

      love.graphics.setColor(255,255,255,200)
    end
   end
  
   for i in ipairs(dungeons[actual_created_d].rooms_n) do    
         love.graphics.setColor(0,200,200,200)
         
         love.graphics.rectangle("fill",dungeons[actual_created_d].rooms_n[i].x,dungeons[actual_created_d].rooms_n[i].y,dungeons[actual_created_d].rooms_n[i].width,dungeons[actual_created_d].rooms_n[i].height)
      
         love.graphics.setColor(0,200,200,255)
         love.graphics.rectangle("line",dungeons[actual_created_d].rooms_n[i].x,dungeons[actual_created_d].rooms_n[i].y,dungeons[actual_created_d].rooms_n[i].width,dungeons[actual_created_d].rooms_n[i].height)
   end
   
--   love.graphics.origin()
   love.graphics.setCanvas()
   return temp_map
end
 norm_x = 0
 norm_y = 0

sh_x = 0
local old_room = 0
local function draw_map()
    love.graphics.scale(1,1)
   -- print(-norm_x*32 +screen_width/2 +32)
    love.graphics.translate(-norm_x*32 +screen_width/2 +32,-norm_y*32+(screen_height/2)+32)
      love.graphics.draw(dungeons[active_dungeon].map,0,0)
    love.graphics.origin()
end


local function draw_minimap()
   --draw the minimap "background"
  love.graphics.setColor(0,0,0,255)
    love.graphics.rectangle("fill",0,0,dungeons[active_dungeon].map_width/2+5,dungeons[active_dungeon].map_height/2+5) 
  love.graphics.setColor(255,255,255,255)
  
  --draw the minimap (scaled from the big map and added a shader)
  love.graphics.scale(0.5,0.5)
  love.graphics.translate( dungeons[active_dungeon].map_min_x or 0, dungeons[active_dungeon].map_min_y or 0)
    love.graphics.setShader(shdr_minimap)
      love.graphics.draw(dungeons[active_dungeon].minimap_canv,0,0)
    love.graphics.setShader()
    
    --draw the actual room
    --create a transparent canvas
    --fill that with the actual rectangle of the room
    -- change only if changed
    
    draw_player_pos()
    love.graphics.setColor(255,0,0,255)
    
    
    for i=1, #npcs do
      love.graphics.rectangle("fill",npcs[i].x,npcs[i].y,3,3)
    end
    
    love.graphics.setColor(255,0,255,255)
    love.graphics.rectangle("fill",dungeons[active_dungeon].goal.x,dungeons[active_dungeon].goal.y,5,5)
    
  love.graphics.origin()  
end

sli_max_old =1

sli_min_old =0
function love.draw()
  --initialise stuff
  scale_x = 1
  scale_y = 1
  
  --normalized values for all!!!
  -- map to player
  if active_dungeon ~= 0 then
      norm_x =( player.pos.x + dungeons[active_dungeon].map_min_x ) * scale_x
      norm_y =( player.pos.y + dungeons[active_dungeon].map_min_y ) * scale_y
  end

  --draw the state of the dungeon
  --DungeonCreator.Draw()
  
  --reset colors and stuff before drawing a canvas... else it will take that color as kind of a bitmask for the channels
   love.graphics.setBlendMode("alpha")
   love.graphics.setColor(255, 255, 255, 255)
    
    
    if sli_max_old ~= sli_max.value then
        shdr_light:send("max",sli_max.value)
        sli_max_old = sli_max.value
    end
    
    if sli_min_old ~= sli_min.value then
        shdr_light:send("min",sli_min.value)
        sli_min_old = sli_min.value
    end
    
    
    --draw the real map
    love.graphics.setShader(shdr_light)
    if active_dungeon ~= 0 then
        draw_map()
    end
    
   
   

    for i = 1, #npcs do
      local pos_x = (npcs[i].x -player.pos.x)*32 + screen_width/2
      local pos_y = (npcs[i].y -player.pos.y)*32 + screen_height/2
     --, print(pos_x-screen_width/2 .." "..pos_y-screen_height/2)
      --love.graphics.rectangle("fill",pos_x,pos_y,32,32)
        love.graphics.draw(tilesets[3].image,tilesets[3][16],pos_x,pos_y)
    end
    
    
    if active_dungeon ~= 0 then
        local pos_x = (dungeons[active_dungeon].goal.x -player.pos.x)*32 + screen_width/2
        local pos_y = (dungeons[active_dungeon].goal.y -player.pos.y)*32 + screen_height/2
        
        love.graphics.rectangle("fill",pos_x,pos_y,32,32)
    end
    
    
    love.graphics.setShader()
    love.graphics.origin()
    
    draw_player()
  if active_dungeon ~= 0 then
    draw_minimap()
  end
 
 love.graphics.setColor(0, 0, 0, 255)
  love.graphics.rectangle("fill",screen_width/2-55,17,400,20)
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.print(DungeonCreator.GetState(),screen_width/2,20)
  love.graphics.print(love.timer.getFPS(),100,0)  
  love.graphics.print(norm_x.." "..norm_y,screen_width/2-55,20)
  
  
  if active_dungeon == 0 then
      
  else
    if dungeons[active_dungeon].room_lookup then
    love.graphics.print(dungeons[active_dungeon].room_lookup[norm_y][norm_x],screen_width/2+56,20)
    love.graphics.print(dungeons[active_dungeon].goal.x.. " "..dungeons[active_dungeon].goal.y ,screen_width/2+100,20)
    end
   end



ui.draw()
end

offs_x = 0
offs_y = 0

function love.keypressed(key,code)
  if key == "left" or key == "right" or key == "up" or key == "down" then
    last_key = key
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
  if key == "1"then
    --TODO: later trigger the menu on its own not in the debug menue ...
     ui.SetGroupVisible("menue",d.show())
  end
  
  if key == "w" then
    offs_y = offs_y -1
  end
  if key == "q" then
      maj,min,pat,code = love.getVersion()
      if  maj == 0 and min >= 10 and pat >= 2 then
       print("reset supported")
       love.event.quit("restart")
      else
       print("reset not supported")
      end
  end
end

function love.mousepressed(x,y,but,touch)
 
 if active_dungeon == 0 then
   return
  end
 print(normalizer.CheckSum( norm_x+offs_x,norm_y+offs_y,dungeons[active_dungeon].lookup))
end

function love.mousemoved(x,y,dx,dy,tou)
 
end

function love.mousereleased(x,y,but)
 
end








function love.errhand(msg)
  er.onError(msg)
end


