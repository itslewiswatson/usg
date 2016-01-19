local tazerTimeout = {}

function onTazerDamage(attacker, weapon)
	if(exports.USGrooms:getPlayerRoom() ~= "cnr") then return end
	if(weapon ~= 23) then return end
	if(not attacker or getElementType(attacker) ~= "player" or exports.USGrooms:getPlayerRoom(attacker) ~= "cnr") then return end
	if(exports.USGcnr_jobs:getPlayerJobType(localPlayer) == jobType and attacker == localPlayer) then	
		local ax,ay,az = getElementPosition(attacker)
		local tx,ty,tz = getElementPosition(source)
		if((tazerTimeout[source] and getTickCount()-tazerTimeout[source] < 10000) or (getDistanceBetweenPoints3D ( ax,ay,az, tx,ty,tz ) > 14)) then
			return
		end
		local wantedLevel = exports.USGcnr_wanted:getPlayerWantedLevel(source)
		if(wantedLevel > 0) then
			tazerTimeout[source] = getTickCount()
			triggerServerEvent("USGcnr_job_police.onTazerHit", localPlayer, source)
		end
	elseif(source == localPlayer) then
		if(exports.USGcnr_jobs:getPlayerJobType(attacker) == jobType) then
			cancelEvent()
		end
	end
end

addEventHandler("onClientPlayerDamage", root, onTazerDamage)

addEvent("USGcnr_job_police.hitByTazer", true)
function onHitByTazer()
	if(not isPedOnGround(localPlayer)) then
		local px, py, pz = getElementPosition(localPlayer)
		local z = getGroundPosition(px, py, pz)
		setElementPosition(localPlayer, px, py, z+1)
	end
end
addEventHandler("USGcnr_job_police.hitByTazer", localPlayer, onHitByTazer)