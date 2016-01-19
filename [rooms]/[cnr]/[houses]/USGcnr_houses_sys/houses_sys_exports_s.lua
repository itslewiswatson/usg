function getHouseName(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].name or getZoneName(houses[houseID].x, houses[houseID].y, houses[houseID].z)
end

function getHouseSellPrice(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].price
end

function isHouseForSale(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].forsale
end

function getHouseInterior(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].int
end

function getHousePosition(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].x, houses[houseID].y, houses[houseID].z
end

function getHouseOwner(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].owner or false
end

function setHouseSellPrice(houseID, price)
	if(not houses[houseID]) then return false end
	if(not tonumber(price) or price <= 0) then return false end
	houses[houseID].price = price
	exports.MySQL:execute("UPDATE cnr__houses SET price=? WHERE id=?", price, houseID)
	return true
end

function setHouseForSale(houseID, forSale)
	if(not houses[houseID]) then return false end
	houses[houseID].forsale = forSale
	updateHousePickup(houses[houseID])
	exports.MySQL:execute("UPDATE cnr__houses SET forsale=? WHERE id=?", forSale and 1 or 0, houseID)
	return true
end

function setHouseOwner(houseID, player)
	if(type(player) ~= "string" and ( not isElement(player) or not exports.USGaccounts:isPlayerLoggedIn(player))) then return false end
	if(not houses[houseID]) then return false end
	local account = type(player) == "string" and player:lower() or exports.USGaccounts:getPlayerAccount(player)
	if(account) then
		local hadOwner = type(houses[houseID].owner) == "string"
		houses[houseID].owner = account
		houses[houseID].forsale = false
		if(not hadOwner) then -- used to be unoccupied
			-- update pickup
			updateHousePickup(houses[houseID])
		end
		if(not hadOwner or houses[houseID].owner ~= account) then
			-- new account
			setHousePermissions(houseID, {}) -- reset permissions
		end
		exports.MySQL:execute("UPDATE cnr__houses SET owner=? WHERE id=?", account, houseID)
		return true
	end
	return false
end

function getHousePermissions(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].permissions or false
end

function getHouseDrugStorage(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].drugs or false
end
function getHouseWeaponStorage(houseID)
	if(not houses[houseID]) then return false end
	return houses[houseID].weapons or false
end

function setHousePermissions(houseID, permissions)
	if(not houses[houseID]) then return false end
	houses[houseID].permissions = permissions
	return exports.MySQL:execute("UPDATE cnr__houses SET permissions=? WHERE id=?", toJSON(permissions), houseID)
end

function setHouseDrugStorage(houseID, drugs)
	if(not houses[houseID]) then return false end
	houses[houseID].drugs = drugs
	return exports.MySQL:execute("UPDATE cnr__houses SET drugs=? WHERE id=?", toJSON(drugs), houseID)
end
function setHouseWeaponStorage(houseID, weapons)
	if(not houses[houseID]) then return false end
	houses[houseID].weapons = weapons
	return exports.MySQL:execute("UPDATE cnr__houses SET weapons=? WHERE id=?", toJSON(weapons), houseID)
end