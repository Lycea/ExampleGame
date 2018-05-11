normalizer = {}

local is_finished = false
local norm ={}
local norm_step = 1

local min_x = 2000
local min_y = 2000

local data_in = {}

local lookup_table = {}
local lookup_rooms = {}

  --metatable used for checking tiles
  -- if index is not available it will simply return 0
  -- means no problem in setting tiles
  local meta_map = {
    __index = function(t,key)
      return 0
    end
    }

norm[1] = function ()
    
    --TODO: Probably put them in one table already here ?
  --find min x and min y
  for i,room in ipairs(data_in.rooms) do
    if room.x < min_x then
      min_x = room.x
      --print(min_x)
    end
    if room.y < min_y then
      min_y = room.y
     -- print(min_y)
    end
    
  end
  
  for i, room in ipairs(data_in.main) do
    if room.x < min_x then
      min_x = room.x
     -- print(min_x)
    end
    if room.y < min_y then
      min_y = room.y
     -- print(min_y)
    end
    
  end
  --print(min_x.."  "..min_y)
  min_x = min_x -1
  norm_step = norm_step +1
  --is_finished = true
end

local tile_lookup = {
  [7]   = 7,
  [28]  = 2,
  [29]  = 2, --??
  [31]  = 8,
  [63]  = 8,
  [112] = 4,
  [113] = 4,
  [124] = 3,
  [125] = 3, --?
  [126] = 3,
  [127] = 13,
  [159] = 8,
  [193] = 1,--ch,
  [199] = 6,
  [207] = 6,--1,
  [223] = 9,
  [231] = 6,
  [241] = 5,
  [243] = 5,
  [247] = 12,
  [249] = 5,
  [252] = 3,
  [253] = 11,
  [255] = 17,
  [0]   = 17,
  
  
  [135] = 7,
  [56]  = 17,
  [240] = 4,
  [191] = 8,
  [14]  = 17,
  [251] = 5,
  [60]  = 2,
  [254] = 3,
  [195] = 1,
  [30]  = 2,
  [131] = 17,
  [143] = 7,
  [239] = 6,
  [158] = 2,
  [120] = 4,
  [205] = 17,
  [15]  = 7,
  [225] = 1,
  [248] = 4,
  [201] = 1,
  [64]  = 17,
  [156] = 2,
  [203] = 1,
  [62]  = 2,
  [114] = 4,
  [122] = 4,
  [227] = 1,
  [39]  = 7,
  [47]  = 17,
  [220] = 2
  }
local max_cols = 0
local max_rows = 0


local checkable_points = {}

local function lerp_(x,y,t) local num = x+t*(y-x)return num end


local function lerp_point(x1,y1,x2,y2,t)
  local x = lerp_(x1,x2,t)
  local y = lerp_(y1,y2,t)
  --print(x.." "..y)
  return x,y
end


local function dist(p1,p2) return ((p2.x-p1.x)^2+(p2.y-p1.y)^2)^0.5 end

-- removes floating points ... they are lot of reason for strange errors!!
local function floor_point(p)
 p.x = math.floor(p.x)
 p.y = math.floor(p.y)
end


local function add_to_check_and_lookup(x,y)
    if lookup_table[(y-min_y)] == nil then
        lookup_table[(y-min_y)] = {}
        
        lookup_rooms[(y-min_y)] = {}
        
        setmetatable(lookup_table[y-min_y],meta_map)
        setmetatable(lookup_rooms[y-min_y],{__index = function(t,key) return -1 end})
        
        print("Missing lines")
        print(x.." "..y)
        print(x-min_x.." "..y-min_y)
        print("\n\n")
    end
  if lookup_table[(y-min_y)][(x-min_x)] ~= 1 then 
    checkable_points[#checkable_points+1] = {}
    checkable_points[#checkable_points].x = x -min_x
    checkable_points[#checkable_points].y = y -min_y
   
    lookup_table[(y-min_y)][(x-min_x)] = 1
    lookup_rooms[(y-min_y)][(x-min_x)] = 0
  end
end

--get the start and the end point of a line and  "draw" them to the array
local function add_line(p1,p2)
  local steps = dist(p1,p2)
  --these both are the wallpoints
  local p3 = {} --left
  local p4 = {} --left
  local p5 = {} --right
  local p6 = {} --right
  
  if steps > 0 then
  if p1.x == p2.x then
    --change the x -1 and +1
    --print("x same")
    p3.x = p1.x-1
    p3.y = p1.y
    
    p4.x = p2.x-1
    p4.y = p2.y
    
    
    p5.x = p1.x+1
    p5.y = p1.y
    
    p6.x = p2.x+1
    p6.y = p2.y
    
  else
    --change the y - and + 1
    --print("y same")
    p3.x = p1.x
    p3.y = p1.y-1
    
    p4.x = p2.x
    p4.y = p2.y-1
    
    
    p5.x = p1.x
    p5.y = p1.y+1
    
    p6.x = p2.x
    p6.y = p2.y+1
  end
  
    
    for j = 0, steps do 
      local t = j/steps
      local x,y = lerp_point(p1.x,p1.y,p2.x,p2.y,t)
      add_to_check_and_lookup(x,y)
      
      x,y = lerp_point(p3.x,p3.y,p4.x,p4.y,t)
      add_to_check_and_lookup(x,y)
      
      x,y = lerp_point(p5.x,p5.y,p6.x,p6.y,t)
      add_to_check_and_lookup(x,y)
    end  
  end
end



norm[2] = function ()
  local start = love.timer.getTime()
  
  --first append both tables for only one loop with all rooms!
  for i, room in  ipairs(data_in.main) do
      data_in.rooms[#data_in.rooms+1]=room
  end
  
  
  --adjust all data to min x and y and return table
  -- that means just move them to the topmost and the left most
  -- ( all indices minus the minimum and you get the position
  for i,room in ipairs(data_in.rooms) do
    for j = 1,room.height+1 do
      for k = 1,room.width+1 do
        -- add 1 to table at position
        if lookup_table[(room.y-min_y)+j] == nil then
            lookup_table[(room.y-min_y)+j] = {}
            setmetatable(lookup_table[(room.y-min_y)+j],meta_map)
            
            --add value for the edge ... this is needed because the checker will test it and will crash else!
            lookup_table[(room.y-min_y)+j][0] = 0
            
            --now for the room lookup
            lookup_rooms[(room.y-min_y)+j] = {}
            setmetatable(lookup_rooms[(room.y-min_y)+j],{__index = function(t,key) return -1 end})
            lookup_table[(room.y-min_y)+j][0] = -1
            
            
        end
        
        lookup_table[(room.y-min_y)+j][(room.x-min_x)+k] = 1
        lookup_rooms[(room.y-min_y)+j][(room.x-min_x)+k] = room.id  --here set the id of the room to know which it is !
        --love.graphics.points((room.x-min_x)+k,(room.y-min_y)+j)  -- debug for seing it afterwards ... TODO: remove if not needed or put to debug options ?
        if (room.x-min_x)+k > max_cols then
          max_cols = (room.x-min_x)+k
        end
        
        
        
        checkable_points[#checkable_points +1] = {}
        checkable_points[#checkable_points].x = (room.x-min_x)+k
        checkable_points[#checkable_points].y = (room.y-min_y)+j
      end
    end
        if (room.y-min_y)+room.height > max_rows then
          max_rows = (room.y-min_y)+room.height
        end
  end
  
  -- start lerping the lines
  --means it starts now to go  over all lines and add the lines to the lookup table 
  -- max with at the moment is 3
  -- TODO: Make the line width adjustable with a parameter and adjust them dynamically
  print("------------start lerping----------------")
  for i,edge in ipairs(data_in.edges) do

    
    if edge.isL == true then
      floor_point(edge.p1)
      floor_point(edge.p2)
      floor_point(edge.p3)
      --print(i)
      add_line(edge.p1,edge.p3)
      add_line(edge.p2,edge.p3)
      
      
      local x,y = 0,0
      
      --check the 4 edges and place the missing one 
      --when two lines are added with width 3 there is always the connecting
      --edge missing
      if lookup_table[edge.p3.y-min_y -1][edge.p3.x-min_x-1] == 0 then
        lookup_table[edge.p3.y-min_y -1][edge.p3.x-min_x-1] = 1
        x,y = edge.p3.x-min_x-1,edge.p3.y-min_y -1
        
      elseif lookup_table[edge.p3.y-min_y +1][edge.p3.x-min_x+1] == 0 then
        lookup_table[edge.p3.y-min_y +1][edge.p3.x-min_x+1] = 1
        x,y= edge.p3.x-min_x+1,edge.p3.y-min_y +1
        
      elseif lookup_table[edge.p3.y-min_y -1][edge.p3.x-min_x+1] == 0 then
        lookup_table[edge.p3.y-min_y -1][edge.p3.x-min_x+1] = 1
        x,y= edge.p3.x-min_x+1,edge.p3.y-min_y -1
        
      elseif lookup_table[edge.p3.y-min_y+1 ][edge.p3.x-min_x-1] == 0 then
        lookup_table[edge.p3.y-min_y+1 ][edge.p3.x-min_x-1] = 1
        x,y= edge.p3.x-min_x-1,edge.p3.y-min_y +1
      end
      
        --this should not happen but just in case catch it..
        if x == 0 and y == 0 then
          
        else
          checkable_points[#checkable_points +1] = {}
          checkable_points[#checkable_points].x = x
          checkable_points[#checkable_points].y = y
        end
        
    else
      floor_point(edge.p1)
      floor_point(edge.p2)
     
      add_line(edge.p1,edge.p2)
    end  
  end
  
  print("------------finished lerping----------------")
  
  --print(#lookup_table)
  
  --here are the first and the last line added also for 
  -- the checker that it dosn't crash because it tries to check it :)
  lookup_table[0] ={}
  setmetatable(lookup_table[0],meta_map)
  
  lookup_table[#lookup_table+1] ={}
  setmetatable(lookup_table[#lookup_table],meta_map)
  
  
  lookup_rooms[0] ={}
  setmetatable(lookup_rooms[0],{__index= function (t,key)return -1 end})
  
  lookup_rooms[#lookup_rooms+1] ={}
  setmetatable(lookup_rooms[#lookup_rooms],{__index= function (t,key)return -1 end})
  
  
  -- love.graphics.setColor(0,0xff,0,0xff)
  
  
  local end_t = love.timer.getTime()
  print(end_t-start.." "..end_t.." "..start)
  
  --disabled the present because this and the one above is 
  --slowing down... only needed for debug purposes
  -- love.graphics.present()
  
  norm_step = norm_step +1
   
end




norm[3] = function ()
  local start = love.timer.getTime()
  index_table = {}
  lookup_tile = {}
  local map = lookup_table
  
  --go through all the points and calculate their binary sum!
  -- this will say which tile needs to be placeed
  -- it can also be adapted to support more neighbours if needed ... 
  -- or can be used for biomes ...TODO: check back to the tutorial for that
  for i=1 , #checkable_points do
      --get other cells
      
      local point = checkable_points[i]
      --print(i.." "..point.x.." "..point.y)
      
      --print("point "..i.." : "..point.x.." "..point.y)
         local sum = (map[point.y-1][point.x] == 0 and 0 or 2^0)+
          (map[point.y-1][point.x+1] == 0 and 0 or 2^1)+
          (map[point.y][point.x+1] == 0 and 0 or 2^2)+
          (map[point.y+1][point.x+1]== 0 and 0 or 2^3)+
          (map[point.y+1][point.x]== 0 and 0 or 2^4)+
          (map[point.y+1][point.x-1]==0 and 0 or 2^5)+
          (map[point.y][point.x-1]==0 and 0 or 2^6)+
          (map[point.y-1][point.x-1]==0 and 0 or 2^7)
         love.graphics.setColor(255,0,0,255)

         -- fix if the number somehow is 0 ... which should not happen
         if sum == 0 then
          sum = 17
          print("zero")  
         end
         
         if tile_lookup[sum] == 17 and (sum ~= 255 and sum ~= 253) then
          print(point.x.." "..point.y.." sum:"..sum)
         end
      
         
         lookup_table[point.y][point.x] =  tile_lookup[sum] -- has to be the number in the tile table
         
         --for checking if every number is used...
         lookup_tile[sum] = true
  end
  table.sort(lookup_tile)
  
  for i, val in pairs(lookup_tile) do
   print   ((tile_lookup[i]or "not available").." "..i) 
  end
  
  love.graphics.present()
  
  local end_t = love.timer.getTime()
  print(end_t-start.." "..end_t.." "..start)
  norm_step = norm_step +1
  is_finished = true
end

norm[4] = function ()
  --wait for reset ~
end
local tileset

--this function sets all the tiles to a spirit batch for the dungeon
--afterwards this can be used like an image!
function normalizer.SetTiles()
    local tilesetBatch = love.graphics.newSpriteBatch(tileset.image, #checkable_points,"static")
    for i=1 , #checkable_points do
      --get other cells
      
      local point = checkable_points[i]
     -- print(lookup_table[point.y][point.x])

     local success = pcall(tilesetBatch.add,tilesetBatch,tileset[lookup_table[point.y][point.x]],(point.x-1)*32,(point.y-1)*32)
     if not success then
         --TODO: check the summ and put it out !
       print("error ".. point.x-1 .." "..point.y-1 .." got a strange sum posibly!!")
     end
    end
  
  tilesetBatch:flush()
  return tilesetBatch
end

function normalizer.CheckPoint(x,y,table_)
  
  --print(lookup_table[y][x])
  
  if table_ == nil then
      
      if lookup_table[y][x] == 17  then
        return true
      end
      return false
  else
      if table_[y][x] == 17 then
          return true
      end
      return false
  end
end

--check the summ of a specific tile 
--needed for debug purpose or maybe 
--later if you can destroy a wall :)
function normalizer.CheckSum(x,y,table_)
    if table_ == nil then
          --use the default table stored in the module
          local sum = (lookup_table[y-1][x] == 0 and 0 or 2^0)+
          (lookup_table[y-1][x+1] == 0 and 0 or 2^1)+
          (lookup_table[y][x+1] == 0 and 0 or 2^2)+
          (lookup_table[y+1][x+1]== 0 and 0 or 2^3)+
          (lookup_table[y+1][x]== 0 and 0 or 2^4)+
          (lookup_table[y+1][x-1]==0 and 0 or 2^5)+
          (lookup_table[y][x-1]==0 and 0 or 2^6)+
          (lookup_table[y-1][x-1]==0 and 0 or 2^7)
          return sum
      else
          --use a given table from outside ... ( for example if at the moment a different dungeon is in creation)
          local sum = (table_[y-1][x] == 0 and 0 or 2^0)+
          (table_[y-1][x+1] == 0 and 0 or 2^1)+
          (table_[y][x+1] == 0 and 0 or 2^2)+
          (table_[y+1][x+1]== 0 and 0 or 2^3)+
          (table_[y+1][x]== 0 and 0 or 2^4)+
          (table_[y+1][x-1]==0 and 0 or 2^5)+
          (table_[y][x-1]==0 and 0 or 2^6)+
          (table_[y-1][x-1]==0 and 0 or 2^7)
      end
      
end


function normalizer.GetState()
  if is_finished == true then
    return "finished"
  end
    return "working"
end


function normalizer.Update()
  norm[norm_step]()
end


function normalizer.SetTileset(set)
  tileset =  set 
end


--call this function before starting the normalizer
--it needs these data to process them
function normalizer.SetData(edges,rooms,main_rooms)
  data_in.edges = edges
  data_in.rooms = rooms
  data_in.main  = main_rooms
end



--after the normalizer is finished 
--this function gives you the min and max value
--also the lookup_table for when the it is resetting ..
function normalizer.GetData()
  if is_finished == true then
    return min_x,min_y,lookup_table,lookup_rooms
  end
end

function normalizer.GetMaxSizes()
  if is_finished == true then
    return max_rows, max_cols
  end
end

function normalizer.reset()
    max_cols = 0
    max_rows = 0
    min_x = 20000
    min_y = 20000
    
    checkable_points = {}
    lookup_table     = {}
    lookup_rooms     = {}
    is_finished      = false
    norm_step        = 1
    
    data_in = {}
    tileset = nil
end


