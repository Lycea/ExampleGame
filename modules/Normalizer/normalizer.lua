normalizer = {}

local is_finished = false
local norm ={}
local norm_step = 1

local data_in = {}

norm[1] = function ()
  --find min x and min y
end

norm[2] = function ()
  --adjust all data to min x and y
end

norm[3] = function ()
  --don't do anything  just wait for reset ...
end



function normalizer.isFinished()
  return is_finished
end


function normalizer.Update()
  norm[norm_step]()
end





function normalizer.SetData()
  
end


function normalizer.GetData()
  
end


