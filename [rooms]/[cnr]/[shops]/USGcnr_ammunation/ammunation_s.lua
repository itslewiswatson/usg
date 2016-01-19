local playerBoughtWeapons = {}

addEvent("onPlayerJoinCNR")
function loadPlayerBoughtWeapons(player, data)
	local weapons = fromJSON(data.weapons)
	playerBoughtWeapons[player] = {}
	if(weapons) then
		for i, weapon in ipairs(weapons) do
			table.insert(playerBoughtWeapons[player], weapon[1]) -- insert weapon id
		end
	end
end
addEventHandler("onPlayerJoinCNR", root, function (...) loadPlayerBoughtWeapons(source,...) end)

addEventHandler("onResourceStart", resourceRoot,
	function ()
		for i, player in ipairs(getElementsByType("player")) do
			if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
				local data = exports.USGcnr_room:getPlayerAccountData(player)
				if(data) then
					loadPlayerBoughtWeapons(player,data)
				end
			end
		end
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function ()
		for i, player in ipairs(getElementsByType("player")) do
			if(exports.USGrooms:getPlayerRoom(player) == "cnr" and playerBoughtWeapons[player]) then
				local data = exports.USGcnr_room:getPlayerAccountData(player)
				if(data) then
					loadPlayerBoughtWeapons(player,data)
				end
			end
		end
	end
)

function doesPlayerOwnWeapon(player, weapon)
	if(playerBoughtWeapons[player]) then
		for i, wepID in ipairs(playerBoughtWeapons[player]) do
			if(wepID == weapon) then
				return true
			end
		end
	end
	return false
end

addEvent("USGcnr_ammunation.getBoughtWeapons", true)
function getPlayerBoughtWeapons(player)
	return playerBoughtWeapons[player] or false
end

function sendClientBoughtWeapons()
	triggerClientEvent(client, "USGcnr_ammunation.receiveBoughtWeapons",client,getPlayerBoughtWeapons(client))
end
addEventHandler("USGcnr_ammunation.getBoughtWeapons", root, sendClientBoughtWeapons)


addEvent("onPlayerPostExitRoom")
function onPlayerExit()
	playerBoughtWeapons[source] = nil
end

addEventHandler("onPlayerQuit", root, onPlayerExit)
addEventHandler("onPlayerPostExitRoom", root, onPlayerExit)

addEvent("USGcnr_ammunation.buyWeapon", true)
function onPlayerBuyWeapon(category, weapon)
	if(categories[category]) then
		local weaponFound = false
		local weaponPrice
		for i, wep in ipairs(categories[category]) do
			if(wep.id == weapon) then
				weaponPrice = wep.price
				weaponFound = true
				break
			end
		end
		if(weaponFound) then
			local weaponOwned = doesPlayerOwnWeapon(client, weapon)
			if(weaponOwned) then
				local ammo = categories[category].ammo
				local price = categories[category].ammoPrice
				if(exports.USGcnr_money:buyItem(client, price, ammo.." ammo for "..getWeaponNameFromID(weapon))) then
					giveWeapon(client, weapon, ammo, true)
				end
			else
				local ammo = categories[category].ammo
				if(weaponPrice and exports.USGcnr_money:buyItem(client, weaponPrice, getWeaponNameFromID(weapon).." with "..ammo.." ammo")) then
					giveWeapon(client, weapon, ammo, true)
					table.insert(playerBoughtWeapons[client], weapon)
					triggerClientEvent(client, "USGcnr_ammunation.receiveBoughtWeapons",client,getPlayerBoughtWeapons(client))
				end
			end
		else
			exports.USGmsg:msg(client, "This weapon was not found, try again later.", 255,0,0)
		end
	end
end
addEventHandler("USGcnr_ammunation.buyWeapon", root, onPlayerBuyWeapon)