loadstring(exports.mysql:getQueryTool())()
houses = {}
pickups = {}
readyPlayers = {}
playersWithPickups = {}
loaded = false

function loadHouses()
	query(loadHousesCallback, {}, "SELECT * FROM cnr__houses")
end
addEventHandler("onResourceStart", resourceRoot, loadHouses)

function loadHousesCallback(result)
	for i, house in ipairs(result) do
		loadHouse(house)
	end
	loaded = true
	for k, player in ipairs(readyPlayers) do
		sendPlayerHouses(player)
	end
end

function loadHouse(house)
	house.forsale = house.forsale ~= 0
	if(not house.name) then house.name = getZoneName(house.x, house.y, house.z) end
	if(type(house.owner) ~= "string" or house.owner == "") then house.owner = false end
	house.permissions = house.permissions and (fromJSON(house.permissions) or {}) or {}
	house.drugs = house.drugs and (fromJSON(house.drugs) or {}) or {}
	house.weapons = house.weapons and (fromJSON(house.weapons) or {}) or {}
	houses[house.id] = house
	table.insert(pickups, {house.id, house.x, house.y, house.z, type(house.owner) == "string" and not house.forsale})
end

function updateHousePickup(house)
	for i, pickup in ipairs(pickups) do
		if(pickup[1] == house.id) then
			pickup[2] = house.x
			pickup[3] = house.y
			pickup[4] = house.z
			pickup[5] = type(house.owner) == "string" and not house.forsale
			for player,_ in pairs(playersWithPickups) do
				if(isElement(player)) then
					triggerClientEvent(player, "USGcnr_housing_sys.updatePickup", player, pickup)
				end
			end
			break
		end
	end
end

function playerExit()
	playersWithPickups[source] = nil
end
addEventHandler("onPlayerQuit", root, playerExit)
addEventHandler("onPlayerExitRoom", root, playerExit)

addEvent("USGcnr_housing_sys.requestHouses", true)
function sendPlayerHouses(player)
	if(not isElement(player)) then return end
	playersWithPickups[player] = true
	triggerLatentClientEvent(player, "USGcnr_housing_sys.recieveHouses", 500000, false, player, pickups) -- send it to client with a rate of 0.5MB/s, to prevent network freeze
	return true
end
addEventHandler("USGcnr_housing_sys.requestHouses", root, 
	function () 
		if(not loaded) then
			table.insert(readyPlayers, client)
		else
			sendPlayerHouses(client)
		end
	end
)