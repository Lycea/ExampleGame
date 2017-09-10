  local api_ = false
  local fi 
  local seen={}
    
local function dump(t,i,text)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		
		if v == text or api_ == true then
			api_ = true
			print(i,v)
      if v ~=text then
        fi:write(" "..v.."= {\n")
        fi:write('args = "()",\n')
        fi:write('description= "TODO",\n')
        fi:write('returns= "()",\n')
        fi:write('type = "function"\n')
        fi:write("},\n")
      end
			
			v=t[v]
			if type(v)=="table" and not seen[v] then
				dump(v,i.."\t")
			end
		end
	end
	api_ = false
end


function create_api(name)
  fi,er = io.open(name.."_api.lua","w")
   print(fi)
   print(er)
   fi:write("local "..name.." = {\n")
   fi:write("childs = {\n")
   dump(_G,"",name)
   fi:write("},\n")
   fi:write('description = "Provides functions for the 'name' module",\n')
   fi:write('type = "lib",\n')
   fi:write('version = "1.0"\n')
   fi:write('}\n')
 fi:close()
  
end
