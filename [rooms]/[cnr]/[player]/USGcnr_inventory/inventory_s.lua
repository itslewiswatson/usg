-- utility
loadstring(exports.Mysql:getQueryTool())()

function table.copy(table)
	local newTable = {}
	for k, v in pairs(table) do
		newTable[k] = v
	end
	return newTable
end

-- inventory

local defaultInventory = {}
local playerInventory = {}
local IDs = {}

function setDefaultInventoryValues(player)
	for id, default in pairs(defaultInventory) do
		if(not playerInventory[player][id]) then -- if the item isnt found, insert it's default value
			playerInventory[player][id] = default
		end
	end
end

function create(ID, vType, default)
	if(type(ID) ~= "string" or type(vType) ~= "string") then
		error("Syntax: create(string ID, string type, mixed default")
	end
	query(createCallback, {ID, vType, default}, "SHOW COLUMNS FROM `cnr__inventory` LIKE ?", ID)
	defaultInventory[ID] = default
	for player, inventory in pairs(playerInventory) do
		if(not inventory[ID]) then
			inventory[ID] = default
		end
	end
	-- add ID to list of columns for in queries
	table.insert(IDs, ID)
	return true
end

function createCallback(result, ID, vType, default)
	if(not result or #result == 0) then
		exports.MySQL:execute("ALTER TABLE `cnr__inventory` ADD `??` ?? NOT NULL DEFAULT ?", ID, vType, default)
	end
end

function add(player, ID, amount)
	if(playerInventory[player] and playerInventory[player][ID]) then
		playerInventory[player][ID] = playerInventory[player][ID]+amount
		triggerClientEvent(player, "USGcnr_inventory.updateInventory", player, ID, playerInventory[player][ID])
		return true
	else
		error("player inventory not loaded or ID not found")
	end
end

function get(player, ID)
	if(playerInventory[player] and playerInventory[player][ID]) then
		return playerInventory[player][ID]
	else
		error("player inventory not loaded or ID not found")
	end
end

function take(player, ID, amount)
	if(playerInventory[player] and playerInventory[player][ID]) then
		playerInventory[player][ID] = playerInventory[player][ID]-amount
		triggerClientEvent(player, "USGcnr_inventory.updateInventory", player, ID, playerInventory[player][ID])
		return true
	else
		error("player inventory not loaded or ID not found")
	end
end

-- loading and saving
function loadPlayerInventories()
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			loadPlayerInventory(player)
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, loadPlayerInventories, true, "low-9999") -- make sure we handle last

function savePlayerInventories()
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr") then
			savePlayerInventory(player)
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, savePlayerInventories)

function onPlayerJoinRoom(room)
	if(room == "cnr") then
		loadPlayerInventory(source)
	end
end

addEvent("onPlayerJoinRoom")
function onPlayerJoinRoom(room)
	if(room == "cnr") then
		loadPlayerInventory(source)
	end
end
addEventHandler("onPlayerJoinRoom", root, onPlayerJoinRoom)

addEvent("onPlayerExitRoom")
function onPlayerExitRoom(room)
	if(room == "cnr") then
		savePlayerInventory(source)
		playerInventory[source] = nil
	end
end
addEventHandler("onPlayerExitRoom", root, onPlayerExitRoom)

function onPlayerQuit()
	if(exports.USGrooms:getPlayerRoom(source) == "cnr") then
		savePlayerInventory(source)
		playerInventory[source] = nil		
	end
end
addEventHandler("onPlayerQuit", root, onPlayerQuit)

function loadPlayerInventory(player)
	singleQuery(loadPlayerInventoryCallback, {player}, "SELECT * FROM cnr__inventory WHERE username=?", exports.USGaccounts:getPlayerAccount(player))
end

function loadPlayerInventoryCallback(result, player)
	if(isElement(player) and exports.USGrooms:getPlayerRoom(player) == "cnr") then -- still in cnr room
		if(not result) then
			-- create a row for the player and give him a default inventory
			exports.MySQL:execute("INSERT INTO cnr__inventory ( username ) VALUES ( ? )", exports.USGaccounts:getPlayerAccount(player))
			playerInventory[player] = table.copy(defaultInventory)
		else
			result.username = nil -- remove it from the inventory, not an item
			playerInventory[player] = result
			setDefaultInventoryValues(player) -- make sure it has all items
		end
		triggerClientEvent(player, "USGcnr_inventory.receiveInventory", player, playerInventory[player])
	end
end

function savePlayerInventory(player)
	if(playerInventory[player]) then
		local queryString = "UPDATE cnr__inventory SET "
		local first = true
		local args = {}
		for id, value in pairs(playerInventory[player]) do
			table.insert(args, id)
			table.insert(args, value)
			if(first) then
				queryString = queryString.."??=?"
				first = false
			else
				queryString = queryString..", ??=?"
			end
		end
		queryString = queryString.." WHERE username=?"
		table.insert(args, exports.USGaccounts:getPlayerAccount(player))
		exports.MySQL:execute(queryString, unpack(args))
	end
end

addEvent("USGcnr_inventory.requestInventory", true)
addEventHandler("USGcnr_inventory.requestInventory", root, 
	function ()
		triggerClientEvent(client, "USGcnr_inventory.receiveInventory", client, playerInventory[client])
	end
)