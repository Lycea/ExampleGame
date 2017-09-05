normalizer = {}

local is_finished = false
local norm ={}
local norm_step = 1

local min_x = 2000
local min_y = 2000

local data_in = {}

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
      print(min_x)
    end
    if room.y < min_y then
      min_y = room.y
      print(min_y)
    end
    
  end
  print(min_x.."  "..min_y)
  
  norm_step = norm_step +2
  is_finished = true
end

norm[2] = function ()
  --adjust all data to min x and y
  --set state to finished
  for i, room in ipairs(data_in.rooms) do
    data_in.rooms[i].x =data_in.rooms[i].x -min_x
    data_in.rooms[i].y =data_in.rooms[i].y -min_y
  end
  
  for i, room in ipairs(data_in.main) do
    data_in.main[i].x =data_in.main[i].x -min_x
    data_in.main[i].y =data_in.main[i].y -min_y
  end
  count = 0
  count_2 = 0
  for i, edge in ipairs(data_in.edges) do
      --print("\n\n-----Before--------")
      
      --print(data_in.edges[i].p2.x .." "..data_in.edges[i].p2.y )
      --print(data_in.edges[i].p1.x .." "..data_in.edges[i].p1.y )
   if data_in.edges[i].isL == true then
    -- print(data_in.edges[i].p3.x .." "..data_in.edges[i].p3.y )
    -- if data_in.edges[i].p3.x - min_x >0 and data_in.edges[i].p3.y - min_y  > 0 then
       data_in.edges[i].p3.x =data_in.edges[i].p3.x - min_x
       data_in.edges[i].p3.y =data_in.edges[i].p3.y - min_y
   --  end
     
     --print("-----After--------")
    -- print(data_in.edges[i].p3.x .." "..data_in.edges[i].p3.y )
   end
    
   if data_in.edges[i].p2.x - min_x >0 and data_in.edges[i].p2.y - min_y  > 0  and data_in.edges[i].p1.x - min_x >0 and data_in.edges[i].p1.y - min_y  > 0 then
     data_in.edges[i].p2.x =data_in.edges[i].p2.x - min_x
     data_in.edges[i].p2.y =data_in.edges[i].p2.y - min_y
    
     data_in.edges[i].p1.x =data_in.edges[i].p1.x - min_x
     data_in.edges[i].p1.y =data_in.edges[i].p1.y - min_y
    else
    count = count + 1 
    if edge.isL == true then
        count_2 = count_2 +1
        
        
        
    end
    --recalculate the lines ...
   end
   
    -- print(data_in.edges[i].p2.x .." "..data_in.edges[i].p2.y )
     --print(data_in.edges[i].p1.x .." "..data_in.edges[i].p1.y )

end
 print ("counter: "..count.." ".. count_2)
  is_finished = true
  norm_step = norm_step +1
end

norm[3] = function ()
  --don't do anything  just wait for reset ...
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





function normalizer.SetData(edges,rooms,main_rooms)
  data_in.edges = edges
  data_in.rooms = rooms
  data_in.main  = main_rooms
end


function normalizer.GetData()
  if is_finished == true then
    return min_x,min_y
  end
end


