-- manage available hospitals
local hospitals = {}
local pendingRespawns = {}
local playerProtected = {}

function loadHospitals()
	local hospFile
	if ( fileExists("hospitals.xml") ) then
		hospFile = xmlLoadFile("hospitals.xml")
		local xmlHospitals = xmlNodeGetChildren(hospFile)
		hospitals = {}
		for _,xmlHospital in ipairs(xmlHospitals) do
			local name = xmlNodeGetValue(xmlHospital)
			local x,y,z,rot = xmlNodeGetAttribute(xmlHospital, "x"),xmlNodeGetAttribute(xmlHospital, "y"),xmlNodeGetAttribute(xmlHospital, "z"),xmlNodeGetAttribute(xmlHospital, "rot")
			local x,y,z,rot = tonumber(x),tonumber(y),tonumber(z),tonumber(rot)
			table.insert(hospitals,{name = name, x = x, y = y, z = z, rot = rot})
		end
	end
end
addEventHandler("onResourceStart",resourceRoot,loadHospitals)
-- manage death

function onPlayerWasted()
	if(exports.USGrooms:getPlayerRoom(source) ~= "cnr") then return end
	-- find out spawn location
	local possibleSpawns = {}
	if ( getResourceFromName("USGcnr_turfs") and getResourceState(getResourceFromName("USGcnr_turfs")) == "running" ) then
		local spawn = exports.USGcnr_turfs:getSpawnLocation(source)
		if spawn then table.insert(possibleSpawns,spawn) end
	end

	local px,py,pz = getElementPosition(source)
	local shortestDist
	local hospSpawn
	for _,hospital in ipairs(hospitals) do
		local dist = getDistanceBetweenPoints2D(px,py,hospital.x,hospital.y)
		if not shortestDist or dist < shortestDist then
			shortestDist = dist
			hospSpawn = hospital
		end
	end
	if getPlayerTeam(source) and getTeamName(getPlayerTeam(source)) == "National Guard" then
		milSpawn = {name = "Military Base", x = 217.7342376 + math.random(6), y = 1858.941772 + math.random(6), z = 13.1406307220, rot = 3.68059444}
		table.insert(possibleSpawns,1,milSpawn)
	end
	hospSpawn.default = true
	table.insert(possibleSpawns,1,hospSpawn)
	pendingRespawns[source] = { skin = getElementModel(source) }
	-- spawning
	if ( #possibleSpawns == 1 ) then -- if there is only one option dont offer choices
		pendingRespawns[source].timer = setTimer(onPlayerSpawn,5000,1,source,possibleSpawns[1])
	else
		triggerClientEvent(source, "onSpawnOfferChoices", source, possibleSpawns)
	end
	
	pendingRespawns[source].weapons = {}
	for slot=0,12 do
		local wep = getPedWeapon(source,slot)
		local ammo = getPedTotalAmmo(source,slot)
		pendingRespawns[source].weapons[slot] = {wep, ammo}
	end
	-- make sure that if the player would quit during the time it takes to spawn, his pre-death data will be used.
	exports.USGcnr_room:setPlayerDataCache(source,"health",5500,100)
	exports.USGcnr_room:setPlayerDataCache(source,"weapons",5500)
	exports.USGcnr_room:setPlayerDataCache(source,"money",5500)
	exports.USGcnr_room:setPlayerDataCache(source,"pos",5500, hospSpawn.x, hospSpawn.y, hospSpawn.z+0.5 )
	exports.USGcnr_room:setPlayerDataCache(source,"dim",5500, 0)
	exports.USGcnr_room:setPlayerDataCache(source,"int",5500, 0)
end
addEventHandler("onPlayerWasted",root,onPlayerWasted)

function onPlayerSpawn(player, spawnInfo)
	if ( isElement(player) and exports.USGaccounts:isPlayerLoggedIn(player) and spawnInfo and pendingRespawns[player] ) then
		exports.USGmsg:msg(player,"Respawned at "..(spawnInfo.name),0,255,0)
		
		spawnPlayer(player,spawnInfo.x+math.random(-1,1),spawnInfo.y+math.random(-1,1),spawnInfo.z+0.5,spawnInfo.rot, pendingRespawns[player].skin)
		
		playerProtected[player] = true
		setElementAlpha(player,128)
		toggleControl(player,"fire",false)
		toggleControl(player,"aim_weapon",false)
		setTimer(onSpawnProtectionEnd, 15000,1,player)
		
		for slot=0,12 do
			local wep = pendingRespawns[player].weapons[slot][1]
			if wep then
				giveWeapon(player,wep,pendingRespawns[player].weapons[slot][2])
			end
		end

		if (getResourceFromName("USGpremium") and getResourceState(getResourceFromName("USGpremium")) == "running" and exports.USGpremium:isPlayerPremium(player)) then
			setPedArmor(player,50)
		end
		
		triggerClientEvent(player,"onClientPlayerReSpawn",player)
		if(isTimer(pendingRespawns[player].timer)) then
			killTimer(pendingRespawns[player].timer)
		end		
		pendingRespawns[player] = nil
	end
end

function onSpawnProtectionEnd(player)
	if(not isElement(player)) then return end
	toggleControl(player,"fire",true)
	toggleControl(player,"aim_weapon",true)
	setElementAlpha(player,255)
	triggerClientEvent(player,"onClientSpawnProtectionEnd",player)
	playerProtected[player] = nil
end

addEvent("onSpawnClickChoice",true)
addEventHandler("onSpawnClickChoice",root,
	function(choice, timeLeft)
		if timeLeft > 0 then
			pendingRespawns[client].timer = setTimer(onPlayerSpawn,timeLeft*1000,1,source,choice)
		else
			onPlayerSpawn(client,choice)
		end
	end
)

addEvent("onPlayerExitRoom")
function onPlayerExit()
	if(playerProtected[source]) then
		onSpawnProtectionEnd(source)
	end
	if(pendingRespawns[source] and isTimer(pendingRespawns[source].timer)) then
		killTimer(pendingRespawns[source].timer)
	end
	pendingRespawns[source] = nil
end
addEventHandler("onPlayerExitRoom", root, onPlayerExit)
addEventHandler("onPlayerQuit", root, onPlayerExit)

addEvent("onPlayerAttemptArrest")
addEventHandler("onPlayerAttemptArrest", root,
	function (criminal)
		if(playerProtected[criminal]) then
			cancelEvent()
		end
	end
)