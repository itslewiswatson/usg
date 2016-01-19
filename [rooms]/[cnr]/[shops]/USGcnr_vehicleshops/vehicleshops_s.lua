addEvent("USGcnr_vehicleshops.purchaseVehicle", true)
function onPlayerPurchaseVehicle(ID, location, plate, r1,g1,b1,r2,g2,b2)
	local price = getVehiclePrice(ID)
	if(exports.USGcnr_money:buyItem(client, price, "a(n) "..getVehicleNameFromModel(ID))) then
		exports.USGcnr_money:logTransaction(client, "bought a(n) "..getVehicleNameFromModel(ID).." for "..exports.USG:formatMoney(price))
		local x,y,z,rz = locations[location].spawnLocation.x, locations[location].spawnLocation.y, 
			locations[location].spawnLocation.z, locations[location].spawnLocation.rz
		if(getVehicleType(ID) == "Plane" or getVehicleType(ID) == "Helicopter") then
			z = z +2
		end			
		exports.USGcnr_pvehicles:onPlayerPurchaseVehicle(client, ID, x,y,z, rz,price, plate, r1,g1,b1,r2,g2,b2)
		triggerClientEvent(client, "USGcnr_vehicleshops.closeShop", client)
	end
end
addEventHandler("USGcnr_vehicleshops.purchaseVehicle", root, onPlayerPurchaseVehicle)