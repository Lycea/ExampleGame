local BASE = (...)..'.' 
print(BASE)
local i= BASE:find("enemies.")
print (i)
BASE=BASE:sub(1,i-1)
print(BASE)


--[[
    About all the small classes they should have
    methods:
    -new
    -update
    -draw
        private:
        -attack
        -move
        ...
    
    attributes:
    -min_spawn
    -max_spawn
    -health
    -strength
    -stat table
    -defense
    -speed      (probably a really fast spider ? :P)
    -position   (nearly forgot this ...)
    
    -returns from update always damage done 

]]

--[[
TODO: Add callback function for giving player damage !!
]]
local enemies ={}

local mob_classes = {}

local spawn_lookup = {}
--[[looks like:
f1(imp,bat)
f2(imp,bat,mouse)
f3(imp,bat,mouse,dragon)
f4(imp,bat,mouse,dragon,hugeDragon)
]]

local function recursiveEnumerate(folder, fileTree)
	local lfs = love.filesystem
	local filesTable = lfs.getDirectoryItems(folder)
	for i,v in ipairs(filesTable) do
		local file = folder.."/"..v
		if lfs.isFile(file) then
			table.insert(fileTree,file) --fileTree.."\n"..file
		elseif lfs.isDirectory(file) then
			fileTree = fileTree.."\n"..file.." (DIR)"
            print(file)
			fileTree = recursiveEnumerate(file, fileTree)
		end
	end
	return fileTree
end


function enemies.init()
    print("initing")
   local mobs 
    --first get the default mobs !!!
   mobs = recursiveEnumerate("/modules/npcs/foes",{})
   
   
   --parse them to the right format and require them
   for i_=1,#mobs do
        --print(mobs[i_])
        mobs[i_]=((mobs[i_]:gsub("/",".")):gsub(".","",1)):gsub(".lua","")
        --print(mobs[i_])
        mob_classes[#mob_classes+1]= require(mobs[i_])
   end
   
    
end

function enemies.spawn()


end


function enemies.update(dt)
    
end

function enemies.draw()
    
end


function enemies.addSprites()
        
end




return enemies