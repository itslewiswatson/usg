loadstring(exports.mysql:getQueryTool())() -- load mysql tools

local emptyJSON = "[ [ ] ]"
local defaultAccount = { x = 2.7333984375, y = 28.2099609375, z = 1200.078125,interior=1,rotation=0,armor=0,health=100,
	money=50000,weapons = emptyJSON, job = "", skin = 0, jobskin = 0, score = 0 }
playerDataCache = {}
playerAccountData = {}
playerCreated = {}

local colShape =  createColSphere ( 1.8193359375, 28.6142578125, 1199.59375,8)
setElementInterior ( colShape, 1)


addEventHandler("onResourceStart", resourceRoot,
	function ()
		local players = exports.USGrooms:getPlayersInRoom("cnr")
		if(#players == 0) then return end
		local usernames = {}
		local usernamePlayer = {}
		local fQuery = "SELECT * FROM cnr__accounts WHERE ( "
		for i=1, #players do -- for i=1, # is needed to keep correct order
			bindPlayerCommands(players[i])

			local username = exports.USGaccounts:getPlayerAccount(players[i])
			usernamePlayer[username] = players[i]
			table.insert(usernames,username)
			fQuery = fQuery .. (i == #players and "username=?" or "username=? OR ")
		end
		fQuery = fQuery .." )"
		query(loadPlayersData, {usernamePlayer},fQuery,unpack(usernames))
		setTimer(saveAllPlayerData, 300000, 0)
	end
)

function loadPlayersData(results, usernamePlayer)
	if(results) then
		for i, result in ipairs(results) do
			local player = usernamePlayer[result.username]
			if(isElement(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then
				playerAccountData[player] = result
				playerCreated[player] = true
			end
		end
	end
end

function saveAllPlayerData()
	local players = getElementsByType("player")
	for i, player in ipairs(players) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			if(getPlayerMoney(player) == 0) then
				local cache = playerDataCache[player] and playerDataCache[player].money or false
				exports.system:log("debug","#2 Save with 0 money, room: "..tostring(exports.USGrooms:getPlayerRoom(player)).." money from cache ? "..tostring(cache), player)
			end	
			savePlayerData(player)
		end
	end
end

addEventHandler("onResourceStop", resourceRoot,saveAllPlayerData)
addEventHandler("onPlayerJoinRoom", root,
	function (room)
		if(room ~= "cnr") then return end
		playerCreated[source] = false
		setPlayerNametagShowing(source, true)
		setPlayerNametagText(source, getPlayerName(source).."["..(0).."]")
		bindPlayerCommands(source)
		singleQuery(spawnPlayerCallback,{source},"SELECT * FROM cnr__accounts WHERE username=?",exports.USGaccounts:getPlayerAccount(source))
	end
)

local function newPlayerSpawn(player)
		fadeCamera ( player,false)
		setTimer(function()
		setElementPosition(player,2.7333984375, 28.2099609375,1200.078125)
		setElementRotation(player,0,0,0)
			setPedAnimation ( player,"FOOD","FF_Sit_Look")
			triggerClientEvent ( player, "onPlayerRegisterSelectSpawn", player)
			fadeCamera (player,true)
		end,1000,1)
end 

function spawnPlayerCallback(result, player)
	if(not isElement(player)) then return false end
	if(not result) then -- create CnR default account
		exports.MySQL:execute("INSERT INTO cnr__accounts (username,x,y,z,weapons,job,clothes) VALUES (?,?,?,?,?,?,?)", 
			exports.USGaccounts:getPlayerAccount(player), 0,0,3,emptyJSON, "",emptyJSON)
		startCreatePlayer(player, defaultAccount)
		newPlayerSpawn(player)
	else
		startCreatePlayer(player, result)
		setTimer(function()
			if(getElementInterior ( player ) == 1 and isElementWithinColShape ( player, colShape) )then
				newPlayerSpawn(player)
			end
		end,3000,1)
	end
	playerDataCache[player] = {}
end

function registerChooseCity(x,y,z,rot)
local player = client
	fadeCamera ( player,false)
		setTimer(function()
			fadeCamera (player,true)
			setElementInterior (player, 0)
			setElementPosition(player,x,y,z)
			setElementRotation ( player, 0,0,rot)
			setPedAnimation ( player)
	end,1000,1)
end
addEvent("onPlayerRegisterSelectSpawnLocation", true)
addEventHandler("onPlayerRegisterSelectSpawnLocation",root ,registerChooseCity)

addEvent("onPlayerJoinCNR", true)
function startCreatePlayer(player, data)
	if(not isElement(player) or not data or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	
	showChat(player,true)
	showPlayerHudComponent(player,"radar",true)
	showPlayerHudComponent(player,"area_name",true)
	setElementData(player,"score",data.score)
	playerAccountData[player] = data
	triggerEvent("onPlayerJoinCNR", player, data)
	triggerClientEvent("onPlayerJoinCNR", player, data)
	
	setTimer(createPlayer, 1000, 1, player,data)
end

function requestAccountMoney(player)
	local username = exports.USGaccounts:getPlayerAccount(player)
	singleQuery(requestAccountMoneyCallback,{player},"SELECT money FROM cnr__accounts WHERE username=?",username)
end

function requestAccountMoneyCallback(result, player)
	if(result) then
		setPlayerMoney(player, result.money, true)
	end
end

function createPlayer(player,data)
	if(not isElement(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return end
	spawnPlayer(player,data.x,data.y,data.z+1,data.rotation,data.skin or 0)
	if(data.jailtime and data.jailtime > 5) then -- if jailed, no point in setting dimension/interior since the jail will do that
		exports.USGcnr_jail:jailPlayer(player, data.jailtime, data.jail)
		if(exports.USGcnr_jail:isJailOpen())then
		outputDebugString("Jail is open released "..getPlayerName(player))
			exports.USGcnr_jail:unjailPlayerOpenDoor(player)
		end
	else
		setElementDimension(player, data.dimension or exports.USGrooms:getRoomDimension("cnr"))
		setElementInterior(player,data.interior or 0)
	end
	setCameraTarget(player,player)
	if(not tonumber(data.money)) then -- try to prevent a bug that causes money to not load/save
		requestAccountMoney(player)
	else
		setPlayerMoney(player,tonumber(data.money), true)
	end
	setPedArmor(player,tonumber(data.armor) or 0)
	if (math.floor(tonumber(data.health)) <= 0) then
		killPed(player)
	else
		setElementHealth(player,tonumber(data.health) or 100)
	end
	local weapons = fromJSON(data.weapons) or {}
	for i=1,#weapons do
		if(weapons[i][1] and weapons[i][2] >= 0 and weapons[i][1] ~= 40) then -- weapon exists in mysql and weapon is bought
			local ammo = tonumber(weapons[i][2]) or 0
			giveWeapon(player,weapons[i][1],weapons[i][2],false)
		end
	end
	fadeCamera(player,true)
	if(data.job and #data.job > 0 ) then exports.USGcnr_jobs:setPlayerJob(player, data.job, data.jobskin or 0)
	else exports.USGcnr_jobs:setPlayerJob(player, false) end
	playerCreated[player] = true
end

function onPlayerExitRoom(player)
	if(getPlayerMoney(player) == 0) then
		local cache = tostring(playerDataCache[player] and playerDataCache[player].money or false)
		exports.system:log("debug","#1 Save with 0 money, room: "..tostring(exports.USGrooms:getPlayerRoom(player)).." money from cache ? "..cache, player)
	end
	savePlayerData(player)
	setPlayerNametagShowing(player, true)
	setPlayerTeam(player, nil)
	setPlayerMoney(player, 0)
	local x,y,z = getElementPosition(player)
	setCameraMatrix(player,x,y,z+30,x,y,z)
	killPed(player)
	playerAccountData[player] = nil
	unbindPlayerCommands(player)
	playerCreated[player] = nil
	if(isTimer(suicideTimers[player])) then killTimer(suicideTimers[player]) end
	suicideTimers[player] = nil	
end

addEventHandler("onPlayerExitRoom", root,
	function (previousRoom)
		if(previousRoom == "cnr") then onPlayerExitRoom(source) end
	end
)

function getWeaponsString(player)
	local weps = {}
	local wepAdded = {}
	for slot=0,11 do -- skip slot 12
		local wep = getPedWeapon(player, slot)
		if(wep ~= 0) then
			wepAdded[wep] = true
			local ammo = getPedTotalAmmo(player, slot)
			table.insert(weps,{wep,ammo})
		end
	end
	local boughtWeapons = exports.USGcnr_ammunation:getPlayerBoughtWeapons(player)
	if(boughtWeapons) then
		for i, wepID in ipairs(boughtWeapons) do
			if(not wepAdded[wepID]) then
				table.insert(weps,{wepID,-1})
			end
		end
	end
	return toJSON(weps)
end
addEventHandler("onResourceStop", root,
	function (res)
		if(getResourceName(res) == "USGcnr_ammunation") then -- update the cache
			for i, player in ipairs(getElementsByType("player")) do
				if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
					local data = playerAccountData[player]
					if(data) then
						playerAccountData[player].weapons = getWeaponsString(player)
					end
				end
			end
		end
	end
)

function savePlayerData(player)
	if (isElement(player) and getElementType(player) == "player" and playerCreated[player]) then -- if element and stuff was laoded
		if (exports.USGaccounts:isPlayerLoggedIn(player)) then
			if not (playerDataCache[player]) then playerDataCache[player] = {} end
			local account = exports.USGaccounts:getPlayerAccount(player)
			local x,y,z
			if(playerDataCache[player].pos) then x,y,z = unpack(playerDataCache[player].pos) else x,y,z = getElementPosition(player) end
			local health = playerDataCache[player].health or getElementHealth(player)
			local int,dim = playerDataCache[player].int or getElementInterior(player),playerDataCache[player].dim or getElementDimension(player)
			local money = playerDataCache[player].money or getPlayerMoney(player)
			local weapons = playerDataCache[player].weapons or getWeaponsString(player)
			local inhouse = exports.USGcnr_houses:getPlayerCurrentHouse(player) or 0
			local wantedLevel = exports.USGcnr_wanted:getPlayerWantedLevel(player) or 0
			local job = exports.USGcnr_jobs:getPlayerJob(player) or ""
			local generalSkin, jobSkin = exports.USGcnr_skins:getPlayerGeneralSkin(player) or 0,getElementModel(player)
			local score = getElementData(player, "score")
			if(money == 0) then
				exports.system:log("debug","#3 Save with 0 money, room: "..tostring(exports.USGrooms:getPlayerRoom(player)).." money from cache ? "..tostring(playerDataCache[player].money), player)
			end
			playerDataCache[player] = nil -- clear it
			
			if (account) and (x) and (y) and (z) and (int) and (dim) and (money) and (weapons) then
				local query = exports.mysql:execute("UPDATE cnr__accounts \
				SET x=?,y=?,z=?,interior=?,dimension=?,money=?,weapons=?, job=?, \
				inhouse=?,wantedlvl=?,skin=?,jobskin=?,health=?,score=?\
				WHERE username=?",x,y,z,int,dim,money,weapons,job,inhouse,wantedLevel,generalSkin,jobSkin,health,score,account)

				if (not query) then
					outputDebugString("Data save failed, username: "..account.."!",0,255,0,0)
				end
			end
		end
	end
end
addEventHandler("onPlayerQuit",root,
	function()
		if(exports.USGrooms:getPlayerRoom(source) == "cnr") then
			savePlayerData(source)
		end
		playerCreated[source] = nil
		playerAccountData[source] = nil		
	end,true,"high"
)

function getPlayerAccountData(player)
	return playerAccountData[player]
end

function updatePlayerAccountData(player, key, value)
	if(playerAccountData[player] and key ~= nil) then
		playerAccountData[player][key] = value
		return true
	else
		return false
	end
end
