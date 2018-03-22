local BASE = (...)..'.' 
local i= BASE:find("debug")
BASE=BASE:sub(1,i-1)
local profi = require(BASE..'profile')

local debugster = {}
debugster.profile = profi

local shown = false

function debugster.init()
  ids= {
    
  ui.AddButton("debug..1",0,0,100,40),
  ui.AddButton("debug..2",0,50,100,40),
}
ui.AddGroup(ids,"DebugView")
ui.SetGroupVisible("DebugView",false)

ui.SetSpecialCallback(ids[1],debug_callback)

end

function debug_callback (id,name)
  
end



function debugster.draw()
end

function debugster.show()
 shown = not shown
  
  ui.SetGroupVisible("DebugView",shown)
  return shown
end

return debugster