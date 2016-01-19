addEvent("USGcnr_houses.requestHouseMenuData", true)
function sendPlayerHouseMenuData(player, houseID)
	local name = exports.USGcnr_houses_sys:getHouseName(houseID)
	local forSale, price = exports.USGcnr_houses_sys:isHouseForSale(houseID), nil
	if(forSale) then price = exports.USGcnr_houses_sys:getHouseSellPrice(houseID) end
	local owner = exports.USGcnr_houses_sys:getHouseOwner(houseID)
	triggerClientEvent(player, "USGcnr_houses.recieveHouseMenuData", player, {name=name,forSale=forSale,price=price,owner=owner,canEnter = canPlayerEnterHouse(player, houseID)})
end
addEventHandler("USGcnr_houses.requestHouseMenuData", root, function (...) sendPlayerHouseMenuData(client, ...) end)

addEvent("USGcnr_houses.buyHouse", true)
function buyHouse(houseID)
	if(exports.USGaccounts:isPlayerLoggedIn(client) and exports.USGrooms:getPlayerRoom(client) == "cnr") then
		local forSale = exports.USGcnr_houses_sys:isHouseForSale(houseID)
		if(forSale) then 
			local price = exports.USGcnr_houses_sys:getHouseSellPrice(houseID)
			if(exports.USGcnr_money:buyItem(client, price, "this house")) then
				if(exports.USGcnr_houses_sys:setHouseOwner(houseID, client)) then
					sendPlayerHouseMenuData(client, houseID)
				end
				exports.USGcnr_money:logTransaction(client, "bought house (ID: "..houseID..") for "..exports.USG:formatMoney(price))
			end
		else
			exports.USGmsg:msg(client, "This house is not for sale!",255,0,0)
		end
	end
end
addEventHandler("USGcnr_houses.buyHouse", root, buyHouse)

addEvent("USGcnr_houses.enterHouse", true)
function enterHouse(houseID)
	onPlayerEnterHouse(client, houseID)
end
addEventHandler("USGcnr_houses.enterHouse", root, enterHouse)

addEvent("USGcnr_houses.exitHouse", true)
function exitHouse()
	onPlayerExitHouse(client)
end
addEventHandler("USGcnr_houses.exitHouse", root, exitHouse)