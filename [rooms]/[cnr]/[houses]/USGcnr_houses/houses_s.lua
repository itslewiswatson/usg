playersInHouse = {}

function onPlayerEnterHouse(player, houseID)
	if(canPlayerEnterHouse(player, houseID)) then
		local int = exports.USGcnr_houses_sys:getHouseInterior(houseID)
		if(int and interiors[int]) then
			int = interiors[int]
			setElementInterior(player, int.int)
			setElementPosition(player, int.x, int.y, int.z)
			setElementDimension(player, houseID+1000)
			playersInHouse[player] = houseID
			triggerClientEvent(player, "USGcnr_houses.onClientHouseEnter", player, int.int, int.x, int.y, int.z)
			return true
		end
	else
		exports.USGmsg:msg(player, "You are not allowed to enter this house.",255,0,0)
	end
	return false
end

function getPlayerCurrentHouse(player)
	if(not isElement(player)) then return false end
	return playersInHouse[player]
end

function unfreezePlayer(player)
	if(isElement(player)) then setElementFrozen(player, false) end
end

function onPlayerExitHouse(player)
	if(playersInHouse[player]) then
		local houseID = playersInHouse[player]
		local x,y,z = exports.USGcnr_houses_sys:getHousePosition(houseID)
		setElementInterior(player, 0)
		setElementDimension(player, exports.USGrooms:getRoomDimension("cnr"))
		playersInHouse[player] = nil
		if(x and y and z) then			
			setElementPosition(player, x, y, z+0.2)
			setElementFrozen(player, true)
			setTimer(unfreezePlayer, 1000, 1, player)
			playersInHouse[player] = nil
		end
		return true
	else
		return false
	end
end

addEventHandler("onResourceStop", resourceRoot,
	function ()
		for player, _ in pairs(playersInHouse) do
			onPlayerExitHouse(player)
		end
	end
)
addEvent("onPlayerJoinCNR", true)
function playerJoinCNR(data)
	if(not isElement(source) or not data.inhouse or data.inhouse == 0) then return end
	onPlayerEnterHouse(source, data.inhouse)
end
addEventHandler("onPlayerJoinCNR", root, playerJoinCNR)

function canPlayerEnterHouse(player, houseID, owner)
	local account = exports.USGaccounts:getPlayerAccount(player)
	local allowed = false
	if((owner and owner or exports.USGcnr_houses_sys:getHouseOwner(houseID)) == account) then
		return true
	else
		local permissions = exports.USGcnr_houses_sys:getHousePermissions(houseID)[account]
		if(permissions and permissions[1] == true) then
			return true
		end
	end
	return false
end