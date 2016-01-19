addEvent("USGcnr_houses.onAttemptOpenHousePanel", true)
function onPlayerAttemptOpenHousePanel()
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		local pAccount = exports.USGaccounts:getPlayerAccount(client)
		local isOwner = exports.USGcnr_houses_sys:getHouseOwner(houseID) == pAccount		
		local permissions = exports.USGcnr_houses_sys:getHousePermissions(houseID)
		local drugsStorage = false
		if(isOwner or (permissions[pAccount] and permissions[pAccount][2][3])) then
			drugsStorage = exports.USGcnr_houses_sys:getHouseDrugStorage(houseID)
		end
		local weaponsStorage = false
		if(isOwner or (permissions[pAccount] and permissions[pAccount][3][3])) then
			weaponStorage = exports.USGcnr_houses_sys:getHouseWeaponStorage(houseID)
		end
		local forSale = exports.USGcnr_houses_sys:isHouseForSale(houseID)
		-- music ?
		triggerClientEvent(client, "USGcnr_houses.openHousePanel", client, isOwner, forSale, permissions, drugsStorage, weaponStorage)
	end
end
addEventHandler("USGcnr_houses.onAttemptOpenHousePanel", root, onPlayerAttemptOpenHousePanel)

addEvent("USGcnr_houses.toggleSale", true)
function onPlayerToggleSale()
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		local newState = not exports.USGcnr_houses_sys:isHouseForSale(houseID)
		exports.USGcnr_houses_sys:setHouseForSale(houseID, newState)
		triggerClientEvent(client, "USGcnr_houses.updateForSale", client, newState)
	end
end
addEventHandler("USGcnr_houses.toggleSale", root, onPlayerToggleSale)

addEvent("USGcnr_houses.setPrice", true)
function onPlayerSetPrice(price)
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		exports.USGcnr_houses_sys:setHouseSellPrice(houseID, price)
		exports.USGmsg:msg(client, "Your house's price has been changed to "..exports.USG:formatMoney(price)..".", 0, 255, 0)
	end
end
addEventHandler("USGcnr_houses.setPrice", root, onPlayerSetPrice)

addEvent("USGcnr_houses.updatePermissions", true)
function onPlayerUpdatePermissions(permissions)
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		if(exports.USGcnr_houses_sys:getHouseOwner(houseID) == exports.USGaccounts:getPlayerAccount(client)) then
			exports.USGcnr_houses_sys:setHousePermissions(permissions)
			exports.USGmsg:msg(client, "You have successfully updated the permissions.", 0, 255, 0)
		else
			exports.USGmsg:msg(client, "You are not allowed to update this house's permissions.", 255, 0, 0)
			return false
		end
	end
end
addEventHandler("USGcnr_houses.updatePermissions", root, onPlayerUpdatePermissions)

addEvent("USGcnr_houses.withdrawDrug", true)
function onPlayerWithdrawDrug(drugType, amount)
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		local account = exports.USGaccounts:getPlayerAccount(client)
		if(account ~= exports.USGcnr_houses_sys:getHouseOwner(houseID)) then
			local permissions = exports.USGcnr_houses_sys:getHousePermissions(houseID)
			if(not permissions[account] or not permissions[account][2][2]) then
				exports.USGmsg:msg(client, "You are not allowed to withdraw drugs from this house.", 255,0,0)
				return false
			end
		end
		local drugsStorage = exports.USGcnr_houses_sys:getHouseDrugStorage(houseID)
		if(drugsStorage and drugsStorage[drugType]) then
			local sAmount = drugsStorage[drugType]
			if(sAmount >= amount) then
				drugsStorage[drugType] = sAmount - amount
				if(exports.USGcnr_houses_sys:setHouseDrugStorage(houseID, drugsStorage)) then
					exports.USGcnr_drugs:givePlayerDrugs(client, drugType, amount)
					triggerClientEvent(client, "USGcnr_houses.updateDrugStorage", client, drugsStorage)
				else
					exports.USGmsg:msg(client, "Something went wrong trying to update your storage, try again later.", 255,0,0)
				end
			else
				exports.USGmsg:msg(client, "You do not have enough drugs in your house to withdraw "..amount.." hits.", 255,0,0)
			end
		else
			exports.USGmsg:msg(client, "You do not have enough drugs in your house to withdraw "..amount.." hits.", 255,0,0)			
		end
	end
end
addEventHandler("USGcnr_houses.withdrawDrug", root, onPlayerWithdrawDrug)

addEvent("USGcnr_houses.depositDrug", true)
function onPlayerDepositDrug(drugType, amount)
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		local account = exports.USGaccounts:getPlayerAccount(client)
		if(account ~= exports.USGcnr_houses_sys:getHouseOwner(houseID)) then
			local permissions = exports.USGcnr_houses_sys:getHousePermissions(houseID)
			if(not permissions[account] or not permissions[account][2][1]) then
				exports.USGmsg:msg(client, "You are not allowed to deposit drugs to this house.", 255,0,0)
				return false
			end
		end	
		local pAmount = exports.USGcnr_drugs:getPlayerDrugAmount(client, drugType)
		if(pAmount and pAmount >= amount) then			
			local drugsStorage = exports.USGcnr_houses_sys:getHouseDrugStorage(houseID)
			if(drugsStorage) then
				drugsStorage[drugType] = ( drugsStorage[drugType] or 0 ) + amount
				if(exports.USGcnr_houses_sys:setHouseDrugStorage(houseID, drugsStorage)) then
					exports.USGcnr_drugs:takePlayerDrugs(client, drugType, amount)
					triggerClientEvent(client, "USGcnr_houses.updateDrugStorage", client, drugsStorage)
				else
					exports.USGmsg:msg(client, "Something went wrong trying to update your storage, try again later.", 255,0,0)
				end
			else
				exports.USGmsg:msg(client, "Something went wrong trying to update your storage, try again later.", 255,0,0)
			end
		else
			exports.USGmsg:msg(client, "You do not have enough drugs on you to deposit "..amount.." hits.", 255,0,0)
		end		
	end
end
addEventHandler("USGcnr_houses.depositDrug", root, onPlayerDepositDrug)

addEvent("USGcnr_houses.withdrawWeapon", true)
function onPlayerWithdrawWeapon(id, amount)
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		local account = exports.USGaccounts:getPlayerAccount(client)
		if(account ~= exports.USGcnr_houses_sys:getHouseOwner(houseID)) then
			local permissions = exports.USGcnr_houses_sys:getHousePermissions(houseID)
			if(not permissions[account] or not permissions[account][3][2]) then
				exports.USGmsg:msg(client, "You are not allowed to withdraw weapons from this house.", 255,0,0)
				return false
			end
		end
		local weaponStorage = exports.USGcnr_houses_sys:getHouseWeaponStorage(houseID)
		local slot = getSlotFromWeapon(id)
		if(slot and weaponStorage[slot]) then
			if(weaponStorage[slot][1] == id and weaponStorage[slot][2] >= amount) then						
				weaponStorage[slot][2] = weaponStorage[slot][2]-amount
				local updated = exports.USGcnr_houses_sys:setHouseWeaponStorage(houseID, weaponStorage)
				if(updated) then
					local ammo = getPedTotalAmmo(client, slot)
					setWeaponAmmo(client, id, ammo+amount)
					triggerClientEvent(client, "USGcnr_houses.updateWeaponStorage", client, weaponStorage)
				end
			else
				exports.USGmsg:msg(client, "You do not have enough ammo in your house to withdraw "..amount.." pieces!", 255,0,0)
			end
		end
	end
end
addEventHandler("USGcnr_houses.withdrawWeapon", root, onPlayerWithdrawWeapon)

addEvent("USGcnr_houses.depositWeapon", true)
function onPlayerDepositWeapon(id, amount)
	local houseID = getPlayerCurrentHouse(client)
	if(houseID) then
		local account = exports.USGaccounts:getPlayerAccount(client)
		if(account ~= exports.USGcnr_houses_sys:getHouseOwner(houseID)) then
			local permissions = exports.USGcnr_houses_sys:getHousePermissions(houseID)
			if(not permissions[account] or not permissions[account][3][1]) then
				exports.USGmsg:msg(client, "You are not allowed to deposit weapons to this house.", 255,0,0)
				return false
			end
		end	
		local slot = getSlotFromWeapon(id)
		local ammo = getPedTotalAmmo(client, slot)
		if(ammo >= amount) then		
			local weaponStorage = exports.USGcnr_houses_sys:getHouseWeaponStorage(houseID)
			if(not weaponStorage[slot]) then 
				weaponStorage[slot] = {id, amount}
			else
				weaponStorage[slot][2] = weaponStorage[slot][2] + amount
			end
			if(exports.USGcnr_houses_sys:setHouseWeaponStorage(houseID, weaponStorage)) then
				takeWeapon(client, id, amount)
				triggerClientEvent(client, "USGcnr_houses.updateWeaponStorage", client, weaponStorage)
			end
		else
			exports.USGmsg:msg(client, "You do not have enough ammo to deposit "..amount.." pieces!", 255,0,0)
		end
	end
end
addEventHandler("USGcnr_houses.depositWeapon", root, onPlayerDepositWeapon)