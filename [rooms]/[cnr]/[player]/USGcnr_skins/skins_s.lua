local playerSkins = {}
local playerClothes = {}

addEventHandler("onResourceStart", resourceRoot,
	function ()
		for i, player in ipairs(getElementsByType("player")) do
			if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
				local data = exports.USGcnr_room:getPlayerAccountData(player)
				if(data) then
					playerSkins[source] = data.skin or 0
					playerClothes[source] = fromJSON(data.clothes) or {}
					restorePlayerCJClothes(player)
				end
			end
		end
	end
)

addEvent("onPlayerJoinCNR", true)
function onPlayerJoinCNR(data)
	playerSkins[source] = data.skin or 0
	local clothes
	if(not fromJSON(data.clothes)) then
		clothes = {}
		local account = exports.USGaccounts:getPlayerAccount(source)
		if(account) then
			exports.MySQL:execute("UPDATE cnr__accounts SET clothes=? WHERE username=?",toJSON(clothes),account)
		end
	else
	clothes = fromJSON(data.clothes)
		local nClothes = {}
		for k,v in pairs(clothes) do
			nClothes[tonumber(k)] = v
		end
		clothes = nClothes
	end
	playerClothes[source] = clothes
	restorePlayerCJClothes(source) -- activate them
end
addEventHandler("onPlayerJoinCNR", root, onPlayerJoinCNR)

addEvent("onPlayerPostExitRoom", true)
function onPlayerExitRoom(room)
	if(room == "cnr") then
		playerSkins[source] = nil
		playerClothes[source] = nil
	end
end
addEventHandler("onPlayerPostExitRoom",root,onPlayerExitRoom)

function restorePlayerSkin(player)
	return setElementModel(player, playerSkins[player] or 0)
end

function getPlayerGeneralSkin(player)
	return playerSkins[player]
end

function setPlayerGeneralSkin(player, skin)
	playerSkins[player] = skin
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(account) then
		return exports.MySQL:execute("UPDATE cnr__accounts SET skin=? WHERE username=?",skin,account)
	end
	return false
end

function restorePlayerCJClothes(player)
	if(not playerClothes[player]) then return false end
	for slot=0,17 do
		local clothes = playerClothes[player][slot]
		if(clothes) then
			addPedClothes(player, clothes[1], clothes[2], slot)
		end
	end
	return true
end

function getPlayerCJClothes(player)
	return playerClothes[player]
end

function setPlayerCJClothes(player, clothes)
	playerClothes[player] = clothes
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(account) then
		return exports.MySQL:execute("UPDATE cnr__accounts SET clothes=? WHERE username=?",toJSON(clothes),account)
	end
	return false
end