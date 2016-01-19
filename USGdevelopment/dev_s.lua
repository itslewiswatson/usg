addCommandHandler("pos",
	function (pSource,cmd,ignoreRot)
		local x,y,z = getElementPosition(pSource)
		if(ignoreRot ~= "1") then
			local _,_,rot = getElementRotation(pSource)
			outputConsole(table.concat({x,y,z,rot},", "), pSource)
		else
			outputConsole(table.concat({x,y,z},", "), pSource)
		end
	end
)
addCommandHandler("pos2",
	function (pSource,cmd,ignoreRot)
		local x,y,z = getElementPosition(pSource)
		x = "x = "..x
		y = "y = "..y
		z = "z = "..z
		if(ignoreRot ~= "1") then
			local _,_,rot = getElementRotation(pSource)
			rot = "rz = "..rot
			outputConsole(table.concat({x,y,z,rot},", "), pSource)
		else
			outputConsole(table.concat({x,y,z},", "), pSource)
		end
	end
)
--[[
local monitorers = {}
addCommandHandler("debugall",
	function (pSource,cmd,iawd)
		monitorers[pSource] = not monitorers[pSource]
	end
)

addEvent("USGdevelopment.onClientDebugMessage", true)
function onClientDebugMessage(message)
	for player, state in pairs(monitorers) do
		if(state and player ~= client) then
			outputConsole("[DEBUG]"..getPlayerName(client)..": "..message, player)
		end
	end
end
addEventHandler("USGdevelopment.onClientDebugMessage", root, onClientDebugMessage)
]]

function convertNumber ( number )  
	local formatted = number  
	while true do      
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')    
		if ( k==0 ) then      
			break   
		end  
	end  
	return formatted
end