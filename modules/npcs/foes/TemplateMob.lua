local tmp = {}
--basic functions
local function moveTo()
    
end


local function attacking()
    
end

local function following()
    
end



local function idle ()
  
  
end

local behaviors =
{
-- moveTo,Attack
-- moveTo
}


function tmp:new (o)
      o = o or {}   -- create object if user does not provide one
      o.name = "TemplateMob"
      
      o.health   = 5
      o.strength = 1
      o.defense  = 1
      o.speed    = 1 --tile per move
      o.state    = "sleep"  -- following,active,sleep,fighting,roaming,inactive
      o.effects  ={}  --table for fight effects ..
      
      o.min_spawn = 0
      o.max_spawn = 12
      
      o.pos  = o.pos or 0
      setmetatable(o, self)
      self.__index = self
      return o
end

function tmp:update(dt)
    
end


function tmp:draw()
    
end

    