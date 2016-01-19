--[[
function setPlayerWeaponSlot(slot)
	setPedWeaponSlot(source, tonumber(slot))
end
addEvent("USGcnr_weaponBinds.setPlayerWeaponSlot", true)
addEventHandler("USGcnr_weaponBinds.setPlayerWeaponSlot", localPlayer, setPlayerWeaponSlot)
--]]

function setPlayerWeaponSlot(cmd, slot)
	if (not slot) or (tonumber(slot) > 12) or (tonumber(slot) < 0) then
		return false
	end
	-- Some anti-abuse measures
	if (getPedWeaponSlot(localPlayer) == slot) or (isPedInVehicle(localPlayer)) then
		return false
	end
	
	setPedWeaponSlot(localPlayer, tonumber(slot))
	--triggerEvent("USGcnr_weaponBinds.setPlayerWeaponSlot", localPlayer, slot)
end
addCommandHandler("slot", setPlayerWeaponSlot)
