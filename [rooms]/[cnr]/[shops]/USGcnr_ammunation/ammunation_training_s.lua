loadstring(exports.mysql:getQueryTool())()
-- [weaponID] = statID
local maxSkill = { [26] = 998, [28] = 998, [32] = 998, }
local weaponStat = { [22]=69, [23]=70, [24]=71, [25]=72, [26]=73, [27]=74, [28]=75, [29]=76, [32]=75, [30]=77, [31]=78, [34]=79, [33]=79 }
local defaultSkills = {}
for k, v in pairs(weaponStat) do
	defaultSkills[k] = 0
end
local playerSkills = {}

addEvent("onPlayerJoinRoom", true)
function onPlayerJoinRoom(room)
	if(room == "cnr") then
		loadPlayerWeaponSkills(source)
	end
end
addEventHandler("onPlayerJoinRoom", root, onPlayerJoinRoom)

addEventHandler("onResourceStart", resourceRoot,
	function ()
		for i, player in ipairs(getElementsByType("player")) do
			if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
				loadPlayerWeaponSkills(player)
			end
		end
	end
)

function loadPlayerWeaponSkills(player)
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(account) then
		singleQuery(loadPlayerWeaponSkillsCallback, {player}, "SELECT * FROM cnr__weaponskills WHERE username=?",account)
	end
end

function loadPlayerWeaponSkillsCallback(result, player)
	if(not isElement(player)) then return end
	if(not result) then
		exports.MySQL:execute("INSERT INTO cnr__weaponskills ( username ) VALUES ( ? )",exports.USGaccounts:getPlayerAccount(player))
		loadPlayerWeaponSkillsCallback(defaultSkills, player)
		return false
	end
	local skills = {}
	for id, value in pairs(result) do
		local newID = tonumber(id)
		if(newID and (not skills[newID] or skills[newID] < value)) then skills[newID] = value end
	end
	playerSkills[player] = skills
	enablePlayerWeaponSkills(player)
end

function enablePlayerWeaponSkills(player)
	if(not isElement(player) or not playerSkills[player]) then return false end
	for weapon, skill in pairs(playerSkills[player]) do
		enablePlayerWeaponSkill(player, weapon)
	end
end

function enablePlayerWeaponSkill(player, weaponID)
	if(not isElement(player) or not playerSkills[player]) then return false end
	local skill = playerSkills[player][weaponID]
	if(not skill) then return end
	local statID = weaponStat[weaponID]
	if(statID) then
		local stat = skill*10 -- percent*10 = 0-1000
		if(maxSkill[weaponID]) then
			stat = math.floor((skill/100)*maxSkill[weaponID])
		end
		setPedStat(player, statID, math.min(1000, stat))
	end
end

function savePlayerWeaponSkill(player, weaponID)
	local key = type(weaponID) == "number" and tostring(weaponID) or false
	local value = playerSkills[player] and playerSkills[player][weaponID] or false
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(account and key and value) then
		return exports.Mysql:execute("UPDATE cnr__weaponskills SET `"..key.."`=? WHERE username=?", value, account)
	end
	return false
end

addEvent("USGcnr_ammunation.training.complete", true)
function onTrainingComplete(weaponID)
	local stat = weaponStat[weaponID]
	if(stat) then
		local oldStat = playerSkills[client][weaponID]
		if(not oldStat) then return false end
		if(oldStat >= 100) then
			exports.USGmsg:msg(client, "Your weapon skill for the "..getWeaponNameFromID(weaponID).." is already at 100%!",0,255,0)
		elseif(exports.USGcnr_money:buyItem(client, 200, "weapon training for "..getWeaponNameFromID(weaponID))) then
			if(weaponID == 28 or weaponID == 32) then
				playerSkills[client][28] = math.min(oldStat+25, 100)
				playerSkills[client][32] = math.min(oldStat+25, 100)
				savePlayerWeaponSkill(client, 28)
				savePlayerWeaponSkill(client, 32)		
			elseif(weaponID == 33 or weaponID == 34) then
				playerSkills[client][33] = math.min(oldStat+25, 100)
				playerSkills[client][34] = math.min(oldStat+25, 100)
				savePlayerWeaponSkill(client, 33)
				savePlayerWeaponSkill(client, 34)
			else
				playerSkills[client][weaponID] = math.min(oldStat+25, 100)
				savePlayerWeaponSkill(client, weaponID)
			end
			enablePlayerWeaponSkill(client, weaponID)
			exports.USGmsg:msg(client, "Your weapon skill for the "..getWeaponNameFromID(weaponID).." is now "..playerSkills[client][weaponID].."%!",0,255,0)
		end
	else
		exports.USGmsg:msg(client,"This weapon's skill cannot be upgraded.", 255, 0, 0)
	end
end
addEventHandler("USGcnr_ammunation.training.complete", root, onTrainingComplete)