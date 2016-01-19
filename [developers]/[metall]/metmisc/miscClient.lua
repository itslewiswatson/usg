local dest = false

function toggleDestroy()
	if (not exports.USGaccounts:getPlayerAccount() == "metall") then return end
	if (dest) then
		dest = false
		showCursor(false)
	else
		dest = true
		showCursor(true)
	end
end
addCommandHandler("metdest", toggleDestroy)

function handleClicks(button, state, absolutex, absolutey, wx, wy, wz, plr)
	if (state ~= "down") then return end
	if (button ~= "left") then return end
	if (not isElement(plr)) then return end
	if (plr and isElement(plr) and getElementType(plr) == "vehicle") then
		if (dest) then
			local veh = getVehicleController(plr)
			if (not veh or not isElement(veh)) then
				triggerServerEvent("metmisc.destroyVeh", root, plr)
				return
			end
		end
	end
end
addEventHandler("onClientClick", root, handleClicks)

--[[
function testDx()
	local screenW, screenH = guiGetScreenSize()
    local screenW = screenW - 100
    dxDrawText("Deliveries left: 0", screenW, screenH+60, screenW+10, screenH/2, tocolor(255, 255, 0, 255), 1.25, "arial", "center", "center", false, false, true, false, false)
end
addEventHandler("onClientRender", root, testDx)

--]]
function bool(var)
	return (not (not var))
end

fileDelete("miscClient.lua")