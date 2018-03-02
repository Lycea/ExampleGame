local stater = {}

local states = {}
local active_state
local active_sub


function stater.add(name,draw,update)
  states[name] = {}
  states[name].draw   = draw
  states[name].update = update
  states[name].hasSub = false
end


function stater.addSub(state,substate,draw,update)
  if states[state].subs == nil then
     states[state].subs  = {}
  end
  states[state].hasSub = true
  
  states[state].subs[substate] = {}
  states[state].subs[substate].update = update
  states[state].subs[substate].draw = draw
end

function stater.change(state,substate)
  stater.update =  (substate ==nil)and states[state].update or states[state].subs[substate].update
  stater.draw =  (substate ==nil)and states[state].draw or states[state].subs[substate].draw
end

function stater.getState()
  return{active_state,active_sub}  
end


return stater