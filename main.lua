require "modules.ProceduralDungeon"
require "modules.Normalizer"
require "imgui"

local screen_width,screen_height
local build_new = true
local newOptions = {
    --changeable settings
    max_width  = 20,              --max room width
    max_height = 25,              --max room height
    mean_thresh = 1.5,           --mean_thresh - bigger than that will be main rooms
    max_rooms = 150,              --max rooms , more means more rooms, more everything :P
    
    --seed options
    useSeed   = false,            --do you want to create a special seed ?
    seed      = 0 ,                --which seed should that be :p
    
    width_circle  =  400 ,  --these both say if a dungeon will be longer or higher 
    height_circle =  200,
    
    percent_paths_added_back = 0,   --percentage of lines addedd back after the perfect way
  }

local edges_final ,rooms,rooms_n
local select_ = 0
local sel_option = 0


-- dungeon generation stuff
local do_it = true
  


local options = {
    {"new_game","load_game","options","exit"},
    {""}
  }

  

  local seen={}

  local imgui_ = false
  local fi 
  
function dump(t,i)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		
		if v == "imgui" or imgui_ == true then
			imgui_ = true
			print(i,v)
      if v ~="imgui" then
        fi:write(" "..v.."= {\n")
      end
			
			v=t[v]
			if type(v)=="table" and not seen[v] then
				dump(v,i.."\t")
			end
		end
	end
	imgui_ = false
end
  
  
  
function love.load()

 --[[fi,er = io.open("imgui_api.lua","w")
 print(fi)
 print(er)
 fi:write("local imgui = {\n")
 fi:write("childs = {\n")
 dump(_G,"")
 fi:write("},\n")
 fi:write('description = "Provides functions for the imgui module",\n')
 fi:write('type = "lib",\n')
 fi:write('version = "1.0"\n')
 fi:write('}\n')
 fi:close()
 ]]

  --require("mobdebug").start()
  print("hi")
  DungeonCreator.setOptions(newOptions)
  print(text)
  DungeonCreator.newDungeon()
 screen_width = love.graphics.getWidth()
 screen_height = love.graphics.getHeight()
end

local timer_move = 0


function love.update(dt)
  DungeonCreator.Update(dt)
  
  edges_final ,rooms,rooms_n = DungeonCreator.GetDungeon()
  
    if love.keyboard.isDown("up","down","left","right") and timer_move+dt > 0.04 then
      print("mop")
      print(dt)
      timer_move = 0
    else
      timer_move = timer_move +dt
    end
end







function map()
  if DungeonCreator.GetState() ~="finished" then
    return
    
  end
  
  
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
       love.graphics.rectangle("line",rooms[i].x,rooms[i].y,rooms[i].width,rooms[i].height)
       
       love.graphics.setColor(255,255,255,255)
       love.graphics.print(rooms[i].id,rooms[i].CenterX,rooms[i].CenterY)
     else
       
       if rooms[i].isHall == true then
         love.graphics.setColor(255,255,255,255)
       
       
         love.graphics.setColor(0,0,200,200)
         
         love.graphics.rectangle("fill",rooms[i].x,rooms[i].y,rooms[i].width,rooms[i].height)
      
         love.graphics.setColor(0,0,200,255)
         love.graphics.rectangle("line",rooms[i].x,rooms[i].y,rooms[i].width,rooms[i].height)
         
       else

       end
      love.graphics.setColor(255,255,255,200)
    end
   end
  
   for i in ipairs(rooms_n) do    
         love.graphics.setColor(0,200,200,200)
         
         love.graphics.rectangle("fill",rooms_n[i].x,rooms_n[i].y,rooms_n[i].width,rooms_n[i].height)
      
         love.graphics.setColor(0,200,200,255)
         love.graphics.rectangle("line",rooms_n[i].x,rooms_n[i].y,rooms_n[i].width,rooms_n[i].height)
   end
end





function love.draw()
  DungeonCreator.Draw()
  map()
  
  love.graphics.print(DungeonCreator.GetState(),0,0)
  love.graphics.setFont(love.graphics.newFont(35))
  love.graphics.print("Title",screen_width/2 - screen_width/4,50)
  
  love.graphics.setFont(love.graphics.newFont(20))
  love.graphics.rectangle("line",screen_width/2 - screen_width/4 - 10,20,screen_width/2,100)

  
  love.graphics.rectangle("line",screen_width/2 - screen_width/4 -10, 145+select_*50,screen_width/4,35)
  
  love.graphics.setColor(0,255,255,150)
  love.graphics.rectangle("fill",screen_width/2 - screen_width/4 -10, 145+select_*50,screen_width/4,35)
  
  
  love.graphics.setColor(255,0,0,255)
  
  for i,k  in ipairs(options[1]) do
    love.graphics.print(k,screen_width/2 - screen_width/4,100 + 50*i)
  end
  
  --love.graphics.print("Start over new",screen_width/2 - screen_width/4,150)
  --love.graphics.print("continue last",screen_width/2 - screen_width/4,200)
  
 end
  





function love.keypressed(key,code)
    if key == "up" then
      if select_ >0 then
        select_ = select_ -1
      end
    elseif key == "down" then
      if select_ >= #options[1]-1 then
        return
      end
        select_ = select_+1
    end
    
end
