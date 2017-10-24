require "modules.ProceduralDungeon"
require "modules.Normalizer"
--require "imgui"

--shader library ...
require "ressources.shaders"

local resources = arg[1].."\\ressources\\"
local shaders = "shaders\\"


-- settings for the to be created dungeon
local newOptions = {
    --changeable settings
    max_width  = 10,              --max room width
    max_height = 10,              --max room height
    mean_thresh = 1.4,           --mean_thresh - bigger than that will be main rooms
    max_rooms = 70,              --max rooms , more means more rooms, more everything :P
    
    --seed options
    useSeed   = true,            --do you want to create a special seed ?
    seed      = 02,                --which seed should that be :p
    
    width_circle  =  200 ,  --these both say if a dungeon will be longer or higher 
    height_circle =  100,
    
    percent_paths_added_back = 20,   --percentage of lines addedd back 
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

  
local player = {}
player.pos = {}
  
local timer_move = 0
local creator_state = 1
  
  
  --create a table from a image
  
  
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
  
  
  
  
  
  
  
  local tilesets ={}
  
  
function love.load()
  for i ,argu in ipairs(arg) do
      print (argu)
      if argu == "-debug" then
         require("mobdebug").start()   
      end
  end
  
  love.graphics.rectangle("fill",0,0,0,0)
  love.graphics.rectangle("line",0,0,40,10)
  love.graphics.present()
  
  
  

  
  --local args = arg
  
  
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
  tilesets[#tilesets+1] = load_tileset("ressources/tilesets/BlueDungeon.png",32,32)
  tilesets[#tilesets+1] = load_tileset("ressources/tilesets/CharsTiles.png",32,32)

end




local move   = {}
local finish = {}
local dummy  = {}
function dummy.Update(dt)
  
end

function dummy.GetState()
 return " "  
end

function dummy.SetData()
  
end




local function check_pos (x,y)
  print(x.." "..y)
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
  
  if check_pos(norm_x+1,norm_y)== true then
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



local dungeon1 = love.graphics.newCanvas(10,10)

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

finish[2]=function (module_)
    map_min_x, map_min_y= module_.GetData()
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
      print(dt.. "time")
      timer_move = 0
    else
      timer_move = timer_move +dt
    end
end


function love.update(dt)
 -- imgui.NewFrame()
  
  update_creator(dt)
  
  check_keys(dt)

end

function draw_player_pos()
  love.graphics.setColor(0,0,255)
 love.graphics.points(player.pos.x,player.pos.y)
 love.graphics.setColor(0xFF,0xFF,0xFF)
 
 
  -- for i = 1, #tilesets[1]-1 do
 --   love.graphics.draw(tilesets[1].image, tilesets[1][i], 32*(i-1),0)
 -- end
 
 
end

function draw_player()
  love.graphics.setColor(0,0,255)
  love.graphics.rectangle("fill",screen_width/2,screen_height/2,5,5)
  love.graphics.points(screen_width/2, screen_height/2)
  
  --love.graphics.draw(tilesets[2].image,tilesets[2][1],player.pos.x,player.pos.y)
  love.graphics.draw(tilesets[2].image,tilesets[2][1],screen_width/2,screen_height/2)
  
  love.graphics.setColor(0xFF,0xFF,0xFF)

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




function love.draw()

  DungeonCreator.Draw()
  
  love.graphics.print(DungeonCreator.GetState(),0,20)
  
  love.graphics.print(love.timer.getFPS(),100,0)
  

  
  love.graphics.setColor(255,0,0,255)
  

  
  --reset colors and stuff before drawing a canvas... else it will look kinda strange
   love.graphics.setBlendMode("alpha")
   love.graphics.setColor(255, 255, 255, 255)
    
  love.graphics.translate(-norm_x*32 +screen_width/2 +32,-norm_y*32+(screen_height/2)+32)
  --print(norm_x,norm_x)
  --love.graphics.scale( 0.2,0.2)
   love.graphics.draw(dungeon1,0,0)
  love.graphics.origin()
  
  --draw the minimap
  love.graphics.scale(0.5,0.5)
  love.graphics.translate( map_min_x or 0, map_min_y or 0)
  --love.graphics.setShader(shdr_minimap)
    love.graphics.draw(map_canvas,0,0)
   -- love.graphics.setShader()
    draw_player_pos()
  love.graphics.origin()
  
  --draw the real map
  scale_x = 1
  scale_y = 1
  
   love.graphics.setShader(shdr_minimap)
    love.graphics.draw(map_canvas,0,0)
   love.graphics.setShader()
   love.graphics.rectangle("fill",player.pos.x,player.pos.y,5,5);
  
  
  love.graphics.scale(1,1)
  
   norm_x =( player.pos.x + map_min_x ) * scale_x
   norm_y =( player.pos.y + map_min_y ) * scale_y
   
   

   --print(norm_x.." "..norm_y)
  -- print(player.pos.x.." "..player.pos.y .."----".. player.pos.x +map_min_x )
  --love.graphics.translate((map_min_x+(screen_width/2))-norm_x,(map_min_y+(screen_height/2))-norm_y)
  --love.graphics.translate((map_min_x+(screen_width/2))-norm_x,(map_min_y+(screen_height/2))-norm_y)
    --love.graphics.draw(map_canvas,0,0)
    
  --love.graphics.origin()
  draw_player()
  
  --imgui.Render()

  
  love.graphics.origin()
  
 -- draw_menue()
  
  love.graphics.setColor(255,255,255,255)
  
 -- for i = 1, #tilesets[1]-1 do
 --   love.graphics.draw(tilesets[1].image, tilesets[1][i], 32*(i-1),0)
 -- end
  
 end
  





function love.keypressed(key,code)
  if key == "left" or key == "right" or key == "up" or key == "down" then
    last_key = key
  --  imgui.KeyPressed(key,code)
  end

end

function love.mousepressed(x,y,but,touch)
 -- imgui.MousePressed(x,y,but)
end

function love.mousemoved(x,y,dx,dy,tou)
 -- imgui.MouseMoved(x,y,dx,dy)
end

function love.mousereleased(x,y,but)
  --  imgui.MouseReleased(x,y,but)
end


