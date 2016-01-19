addEvent("USGcnr_protectpresident.monitorDamage", true)
addEventHandler("USGcnr_protectpresident.monitorDamage", root,
	function ()
		addEventHandler("onClientVehicleDamage", source, onVehicleDamage)
	end
)
addEvent("USGcnr_protectpresident.stopMonitoringDamage", true)
addEventHandler("USGcnr_protectpresident.stopMonitoringDamage", root,
	function ()
		removeEventHandler("onClientVehicleDamage", source, onVehicleDamage)
	end
)

function onVehicleDamage(attacker, weapon, loss)
	if(attacker) then
		if(getElementType(attacker) == "vehicle") then
			attacker = getVehicleController(attacker)
		end
		if(attacker and getElementType(attacker) == "player") then
			if(weapon == 16 or weapon == 39) then
				loss = loss*0.5
			end
			triggerServerEvent("USGcnr_protectpresident.reportDamage",attacker, loss)
		end
	end
end

-- blips
addEvent("onPlayerChangeJob", true)
addEvent("onPlayerExitRoom", true)
local convoyBlip
function destroyConvoyBlip()
	if(isElement(convoyBlip)) then
		destroyElement(convoyBlip)
		removeEventHandler("onPlayerChangeJob",localPlayer,destroyConvoyBlip)
		removeEventHandler("onClientElementDestroy",source,destroyConvoyBlip)
		removeEventHandler("onPlayerExitRoom",localPlayer,destroyConvoyBlip)
		return true
	end
	return false
end

addEvent("USGcnr_protectpresident.addConvoyBlip", true)
addEventHandler("USGcnr_protectpresident.addConvoyBlip", root,
	function ()
		if(isElement(convoyBlip)) then
			destroyElement(convoyBlip)
		else
			addEventHandler("onPlayerChangeJob",localPlayer,destroyConvoyBlip)
			addEventHandler("onClientElementDestroy",source,destroyConvoyBlip)
			addEventHandler("onPlayerExitRoom",localPlayer,destroyConvoyBlip)
		end
		convoyBlip = createBlipAttachedTo(source, 59)
	end
)

local convoyStartBlip
function destroyConvoyStartBlip()
	if(isElement(convoyStartBlip)) then
		destroyElement(convoyStartBlip)
		removeEventHandler("onPlayerChangeJob",localPlayer,destroyConvoyStartBlip)
		removeEventHandler("onPlayerExitRoom",localPlayer,destroyConvoyStartBlip)
		return true
	end
	return false
end

addEvent("USGcnr_protectpresident.destroyConvoyStartBlip", true)
addEventHandler("USGcnr_protectpresident.destroyConvoyStartBlip", root, destroyConvoyStartBlip)

addEvent("USGcnr_protectpresident.addConvoyStartBlip", true)
addEventHandler("USGcnr_protectpresident.addConvoyStartBlip", root,
	function (x, y, z)
		if(isElement(convoyStartBlip)) then
			destroyElement(convoyStartBlip)
		else
			addEventHandler("onPlayerChangeJob",localPlayer,destroyConvoyStartBlip)
			addEventHandler("onPlayerExitRoom",localPlayer,destroyConvoyStartBlip)
		end
		convoyStartBlip = createBlip(x, y, z, 59)
	end
)

local targetBlip
function destroyTargetBlip()
	if(isElement(targetBlip)) then
		destroyElement(targetBlip)
		removeEventHandler("onPlayerChangeJob",localPlayer,destroyTargetBlip)
		removeEventHandler("onPlayerExitRoom",localPlayer,destroyTargetBlip)
		return true
	end
	return false
end
addEvent("USGcnr_protectpresident.destroyTargetBlip", true)
addEventHandler("USGcnr_protectpresident.destroyTargetBlip", root, destroyTargetBlip)

addEvent("USGcnr_protectpresident.addTargetBlip", true)
addEventHandler("USGcnr_protectpresident.addTargetBlip", localPlayer,
	function (x,y,z)
		if(isElement(targetBlip)) then
			destroyElement(targetBlip)
		else
			addEventHandler("onPlayerChangeJob",localPlayer,destroyTargetBlip)
			addEventHandler("onPlayerExitRoom",localPlayer,destroyTargetBlip)
		end
		targetBlip = createBlip(x,y,z, 41)
	end
)