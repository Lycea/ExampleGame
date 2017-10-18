normalizer = {}

local is_finished = false
local norm ={}
local norm_step = 1

local min_x = 2000
local min_y = 2000

local data_in = {}

local lookup_table = {}
      local meta_map = {
        __index = function(t,key)
          return 0
        end
        }

norm[1] = function ()
  --find min x and min y
  for i,room in ipairs(data_in.rooms) do
    if room.x < min_x then
      min_x = room.x
      print(min_x)
    end
    if room.y < min_y then
      min_y = room.y
      print(min_y)
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
  print(min_x.."  "..min_y)
  
  norm_step = norm_step +1
  --is_finished = true
end

--8tiles per row
local tile_lookup = {
  [7]   = 7,
  [28]  = 2,
  [31]  = 8,
  [63]  = 8,
  [112] = 4,
  [124] = 3,
  [126] = 3,
  [127] = 13,
  [159] = 8,
  [193] = 1,
  [199] = 6,
  [207] = 1,
  [223] = 9,
  [231] = 6,
  [241] = 5,
  [243] = 5,
  [247] = 12,
  [249] = 5,
  [252] = 3,
  [253] = 11,
  [255] = 17
  }
local max_cols = 0
local max_rows = 0


local checkable_points = {}

norm[2] = function ()
  local start = love.timer.getTime()
  
  --first append both tables for only one loop with all rooms
  for i, room in  ipairs(data_in.main) do
      data_in.rooms[#data_in.rooms+1]=room
  end
  
  
  --adjust all data to min x and y and return table
  for i,room in ipairs(data_in.rooms) do
    for j = 1,room.height+1 do
      for k = 1,room.width+1 do
        -- add 1 to table at position
        if lookup_table[(room.y-min_y)+j] == nil then
            lookup_table[(room.y-min_y)+j] = {}
            setmetatable(lookup_table[(room.y-min_y)+j],meta_map)
            lookup_table[(room.y-min_y)+j][0] = 0
        end
        lookup_table[(room.y-min_y)+j][(room.x-min_x)+k] = 1
        love.graphics.points((room.x-min_x)+k,(room.y-min_y)+j)
        if (room.x-min_x)+k > max_cols then
          max_cols = (room.x-min_x)+k
        end
        
        checkable_points[#checkable_points +1] = {}
        checkable_points[#checkable_points].x = k
        checkable_points[#checkable_points].y = j
      end
    end
  end
  
  print(#lookup_table)
  lookup_table[0] ={}
  setmetatable(lookup_table[0],meta_map)
  
  lookup_table[#lookup_table+1] ={}
  setmetatable(lookup_table[#lookup_table],meta_map)
  
  love.graphics.setColor(0,0xff,0,0xff)
  
  
  local end_t = love.timer.getTime()
  print(end_t-start.." "..end_t.." "..start)
  
  love.graphics.present()
 -- local data=love.graphics.newScreenshot()
 -- data:encode("png","test.png")
  
  
  norm_step = norm_step +1
   
end


norm[3] = function ()
  local start = love.timer.getTime()
  index_table = {}
  -- check  the naighbours of each available cell
  local map = lookup_table
  for i ,point in ipairs(checkable_points) do
      --get other cells
         
         local sum = (map[point.x][point.y] == 0 and 0 or 2^0)+
          (map[point.x-1][point.y+1] == 0 and 0 or 2^1)+
          (map[point.x][point.y+1] == 0 and 0 or 2^2)+
          (map[point.x+1][point.y+1]== 0 and 0 or 2^3)+
          (map[point.x+1][point.y]== 0 and 0 or 2^4)+
          (map[point.x+1][point.y-1]==0 and 0 or 2^5)+
          (map[point.x][point.y-1]==0 and 0 or 2^6)+
          (map[point.x-1][point.y-1]==0 and 0 or 2^7)
         
         lookup_table[point.x][point.y] =  tile_lookup[sum] -- has to be the number in the tile table
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

function normalizer.SetTiles()
  print(max_cols)
  print(#lookup_table)
  local canvas = love.graphics.newCanvas(32*(max_cols+100),32*#lookup_table)
  love.graphics.setCanvas(canvas)
  for i=1,#lookup_table-1 do
    for j=1, max_cols do
      --draw the image
      if lookup_table[i][j] ~= 0 then
          love.graphics.draw(tileset.image,tileset[lookup_table[i][j]],(i-1)*32,(j-1)*32)
      end
    end
  end
  
  love.graphics.setCanvas()
  return canvas
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



function normalizer.SetData(edges,rooms,main_rooms)
  data_in.edges = edges
  data_in.rooms = rooms
  data_in.main  = main_rooms
end


function normalizer.GetData()
  if is_finished == true then
    return min_x,min_y,lookup_table
  end
end


