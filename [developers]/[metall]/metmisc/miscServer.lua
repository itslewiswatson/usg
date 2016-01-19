local cigarettes = {}
local cooldown = {}

function pizzaPos(plr)
	local x, y, z = getElementPosition(plr)
	x, y, z = math.ceil(x), math.ceil(y), math.ceil(z)
	local shit = "{"..x..", "..y..", "..z.."},"
	outputChatBox(shit, plr, math.random(1, 255), math.random(1, 255), math.random(1, 255))
end
addCommandHandler("pussyslayer", pizzaPos)

function mapBus(plr)
	
end


function destroyTheVehicle(element)
	if (isElement(element) and getElementType(element) == "vehicle") then
		outputChatBox("Destroyed "..getVehicleName(element), client, 0, 200, 0)
		destroyElement(element)
	end
end
addEvent("metmisc.destroyVeh", true)
addEventHandler("metmisc.destroyVeh", root, destroyTheVehicle)

function startSmoking(plr)
	if (isPedInVehicle(plr)) then return outputChatBox("You can not smoke inside a vehicle", plr, 255, 0, 0) end
	setElementData(plr, "smoking", true)
	if (cigarettes[plr] == nil and not isTimer(cooldown[plr])) then
		if getPlayerMoney(plr) >= 10 then
			-- Bind the keys
			bindKey(plr, "mouse1", "down", smokeAnimation2)
			bindKey(plr, "mouse2", "down", smokeAnimation)
			bindKey(plr, "W", "down", stopSmoking)
			
			outputChatBox("Click left or right mouse to toggle between animations", plr, 0, 200, 0)
			takePlayerMoney(plr, 10)
			
			-- Activate the animation
			setPedAnimation(plr, "SMOKING", "M_smk_in", -1, false, false)
			cooldown[plr] = setTimer(function() end, 3000, 1)
			
			-- Create the cigarette
			local cigarette = createObject(1485, 0, 0, 0)
			cigarettes[plr] = cigarette
			exports.bone_attach:attachElementToBone(cigarette, plr, 11, 0.15, 0.1, 0.15, 0, 180, 30)
		end
	end
end
addCommandHandler("smoke", startSmoking)

function stopSmoking(plr)
	-- Unbind the keys
	unbindKey(plr, "mouse1", "down", smokeAnimation2)
	unbindKey(plr, "mouse2", "down", smokeAnimation)
	unbindKey(plr, "W", "down", stopSmoking)
	
	-- Stop the animation
	setPedAnimation(plr)
	if (isElement(cigarettes[plr])) then
		destroyElement(cigarettes[plr])
		cigarettes[plr] = nil
	end
end
addCommandHandler("stopsmoke", stopSmoking)

function stopSmoking_()
	if (cigarettes[source]) then
		stopSmoking(source)
	end
end
addEventHandler("onPlayerQuit", root, stopSmoking_)

function smokeAnimation(plr)
	setPedAnimation(plr, "SMOKING", "M_smkstnd_loop", -1, false, false)
end

function smokeAnimation2(plr)
	setPedAnimation(plr, "SMOKING", "M_smklean_loop", -1, false, false)
end

function onQuit(plr)
	if (cigarettes[plr] and isElement(cigarettes[plr])) then
		destroyElement(cigarettes[plr])
		cigarettes[plr] = nil
	end
end
addEventHandler("onPlayerQuit", root, onQuit)

function bool(var)
	return (not (not var))
end