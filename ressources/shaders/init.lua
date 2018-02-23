local BASE = (...)..'.' 


i= BASE:find("init")
if i then
  BASE=BASE:sub(1,i-1)
end

print(BASE)

assert(not BASE:match('%.init%.$'), "Invalid require path `"..(...).."' (drop the `.init').")


return {
  
	minimap = require(BASE .. 'minimap.minimap'),
  effects = require(BASE .. 'effects.effects'),
}