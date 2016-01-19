local housePanelGUI = {}
local setPriceDialog = false

local housePermissions = false
local houseDrugs = false
local houseWeapons = false
local isHouseOwner = false

function createHousePanel()
	housePanelGUI.window = exports.USGGUI:createWindow("center", "center", 400, 300, false, "House panel")
	housePanelGUI.toggleSale = exports.USGGUI:createButton(5,5,90,25,false,"Toggle sale", housePanelGUI.window)
		addEventHandler("onUSGGUISClick", housePanelGUI.toggleSale, toggleHouseSale, false)
	housePanelGUI.setPrice = exports.USGGUI:createButton(100,5,70,25,false,"Set price", housePanelGUI.window)
		addEventHandler("onUSGGUISClick", housePanelGUI.setPrice, setHousePrice, false)	
	housePanelGUI.tabpanel = exports.USGGUI:createTabPanel("center", 45, 390, 250, false, housePanelGUI.window, tocolor(0,0,0,50))
	housePanelGUI.permissions = { tab = exports.USGGUI:addTab(housePanelGUI.tabpanel, "Permissions") }
	housePanelGUI.permissions.accounts = exports.USGGUI:createGridList(5,5,165,185,false,housePanelGUI.permissions.tab)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.permissions.accounts, "Account", 0.7)
	addEventHandler("onUSGGUISClick", housePanelGUI.permissions.accounts, onClickPermissionsAccountList, false)	
	housePanelGUI.permissions.account = exports.USGGUI:createEditBox(5,195,100,25,false,"",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.add = exports.USGGUI:createButton(105,195,65,25,false,"Add",housePanelGUI.permissions.tab)
	addEventHandler("onUSGGUISClick", housePanelGUI.permissions.add, onAddPermissionAccount, false)

	housePanelGUI.permissions.options = {}
	housePanelGUI.permissions.options.canEnter = exports.USGGUI:createCheckBox(175,5,200,25,false,"Enter house",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.drugsLabel = exports.USGGUI:createLabel(175,35,200,25,false,"Drugs",housePanelGUI.permissions.tab)
	exports.USGGUI:setTextAlignment(housePanelGUI.permissions.drugsLabel,"center","center")
	housePanelGUI.permissions.options.depositDrugs = exports.USGGUI:createCheckBox(175,65,75,25,false,"Deposit",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.options.withdrawDrugs = exports.USGGUI:createCheckBox(250,65,75,25,false,"Withdraw",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.options.viewDrugs = exports.USGGUI:createCheckBox(330,65,70,25,false,"View",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.weaponsLabel = exports.USGGUI:createLabel(175,95,200,25,false,"Weapons",housePanelGUI.permissions.tab)
	exports.USGGUI:setTextAlignment(housePanelGUI.permissions.weaponsLabel,"center","center")
	housePanelGUI.permissions.options.depositWeapons = exports.USGGUI:createCheckBox(175,125,75,25,false,"Deposit",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.options.withdrawWeapons = exports.USGGUI:createCheckBox(250,125,75,25,false,"Withdraw",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.options.viewWeapons = exports.USGGUI:createCheckBox(330,125,70,25,false,"View",housePanelGUI.permissions.tab)
	housePanelGUI.permissions.save = exports.USGGUI:createButton(315, 195, 70, 25, false, "Save", housePanelGUI.permissions.tab)
	addEventHandler("onUSGGUISClick", housePanelGUI.permissions.save, onSavePermissions, false)
	
	housePanelGUI.drugs = { tab = exports.USGGUI:addTab(housePanelGUI.tabpanel, "Drugs") }
	housePanelGUI.drugs.myGrid = exports.USGGUI:createGridList(5,5,165,220,false,housePanelGUI.drugs.tab)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.drugs.myGrid, "Drug", 0.7)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.drugs.myGrid, "Hits", 0.3)
	housePanelGUI.drugs.houseGrid = exports.USGGUI:createGridList(220,5,165,220,false,housePanelGUI.drugs.tab)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.drugs.houseGrid, "Drug", 0.7)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.drugs.houseGrid, "Hits", 0.3)
	housePanelGUI.drugs.deposit = exports.USGGUI:createButton(185,60,20,25,false,"->", housePanelGUI.drugs.tab)
	addEventHandler("onUSGGUISClick", housePanelGUI.drugs.deposit, depositDrug, false)
	housePanelGUI.drugs.amount = exports.USGGUI:createEditBox(175,105,40,25,false,"", housePanelGUI.drugs.tab)
	housePanelGUI.drugs.withdraw = exports.USGGUI:createButton(185,145,20,25,false,"<-", housePanelGUI.drugs.tab)
	addEventHandler("onUSGGUISClick", housePanelGUI.drugs.withdraw, withdrawDrug, false)
	
	housePanelGUI.weapons = { tab = exports.USGGUI:addTab(housePanelGUI.tabpanel, "Weapons") }
	housePanelGUI.weapons.myGrid = exports.USGGUI:createGridList(5,5,165,220,false,housePanelGUI.weapons.tab)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.weapons.myGrid, "Weapon", 0.7)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.weapons.myGrid, "Ammo", 0.3)
	housePanelGUI.weapons.houseGrid = exports.USGGUI:createGridList(220,5,165,220,false,housePanelGUI.weapons.tab)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.weapons.houseGrid, "Weapon", 0.7)
	exports.USGGUI:gridlistAddColumn(housePanelGUI.weapons.houseGrid, "Ammo", 0.3)
	housePanelGUI.weapons.deposit = exports.USGGUI:createButton(185,60,20,25,false,"->", housePanelGUI.weapons.tab)
	addEventHandler("onUSGGUISClick", housePanelGUI.weapons.deposit, depositWeapon, false)
	housePanelGUI.weapons.amount = exports.USGGUI:createEditBox(175,105,40,25,false,"", housePanelGUI.weapons.tab)
	housePanelGUI.weapons.withdraw = exports.USGGUI:createButton(185,145,20,25,false,"<-", housePanelGUI.weapons.tab)
	addEventHandler("onUSGGUISClick", housePanelGUI.weapons.withdraw, withdrawWeapon, false)
	
	housePanelGUI.music = { tab = exports.USGGUI:addTab(housePanelGUI.tabpanel, "Music") }
end

function isHousePanelVisible()
	return isElement(housePanelGUI.window) and exports.USGGUI:getVisible(housePanelGUI.window)
end

function closeHousePanel()
	if(isHousePanelVisible()) then
		exports.USGGUI:setVisible(housePanelGUI.window, false)
		showCursor("panel", false)
	end
end

function toggleHousePanel()
	if(isHousePanelVisible()) then
		closeHousePanel()
	else
		triggerServerEvent("USGcnr_houses.onAttemptOpenHousePanel", localPlayer)
	end
end

addEvent("USGcnr_houses.updateDrugStorage", true)
function updateDrugs(drugs)
	houseDrugs = drugs
	exports.USGGUI:setEnabled(housePanelGUI.drugs.tab, drugs ~= false)
	exports.USGGUI:setEnabled(housePanelGUI.drugs.deposit, isHouseOwner or (permissions[exports.USGaccounts:getPlayerAccount()] and permissions[exports.USGaccounts:getPlayerAccount()][2][1]))
	exports.USGGUI:setEnabled(housePanelGUI.drugs.withdraw, isHouseOwner or (permissions[exports.USGaccounts:getPlayerAccount()] and permissions[exports.USGaccounts:getPlayerAccount()][2][2]))	
	exports.USGGUI:gridlistClear(housePanelGUI.drugs.myGrid)
	exports.USGGUI:gridlistClear(housePanelGUI.drugs.houseGrid)
	if(drugs) then
		local types = exports.USGcnr_drugs:getDrugTypes()
		for i, drugType in ipairs(types) do
			local pAmount = exports.USGcnr_drugs:getPlayerDrugAmount(drugType)
			if(pAmount and pAmount > 0) then
				local row = exports.USGGUI:gridlistAddRow(housePanelGUI.drugs.myGrid)
				exports.USGGUI:gridlistSetItemText(housePanelGUI.drugs.myGrid, row, 1, drugType)
				exports.USGGUI:gridlistSetItemText(housePanelGUI.drugs.myGrid, row, 2, tostring(pAmount))
			end
			local sAmount = drugs[drugType] 
			if(sAmount and sAmount > 0) then
				local row = exports.USGGUI:gridlistAddRow(housePanelGUI.drugs.houseGrid)
				exports.USGGUI:gridlistSetItemText(housePanelGUI.drugs.houseGrid, row, 1, drugType)
				exports.USGGUI:gridlistSetItemText(housePanelGUI.drugs.houseGrid, row, 2, tostring(sAmount))
			end
		end
	end
end
addEventHandler("USGcnr_houses.updateDrugStorage", localPlayer, updateDrugs)

addEvent("USGcnr_houses.updateWeaponStorage", true)
function updateWeapons(weapons)
	houseWeapons = weapons
	exports.USGGUI:setEnabled(housePanelGUI.weapons.tab, weapons ~= false)
	exports.USGGUI:setEnabled(housePanelGUI.weapons.deposit, isHouseOwner or (permissions[exports.USGaccounts:getPlayerAccount()] and permissions[exports.USGaccounts:getPlayerAccount()][2][1]))
	exports.USGGUI:setEnabled(housePanelGUI.weapons.withdraw, isHouseOwner or (permissions[exports.USGaccounts:getPlayerAccount()] and permissions[exports.USGaccounts:getPlayerAccount()][2][2]))
	exports.USGGUI:gridlistClear(housePanelGUI.weapons.myGrid)
	exports.USGGUI:gridlistClear(housePanelGUI.weapons.houseGrid)
	if(weapons) then
		for slot=0,12 do
			local myWep = getPedWeapon(localPlayer, slot)
			if(myWep and myWep ~= 0) then
				local ammo = getPedTotalAmmo(localPlayer, slot)
				if(ammo > 0) then
					local row = exports.USGGUI:gridlistAddRow(housePanelGUI.weapons.myGrid)
					exports.USGGUI:gridlistSetItemText(housePanelGUI.weapons.myGrid, row, 1, getWeaponNameFromID(myWep))
					exports.USGGUI:gridlistSetItemText(housePanelGUI.weapons.myGrid, row, 2, tostring(ammo))
					exports.USGGUI:gridlistSetItemData(housePanelGUI.weapons.myGrid, row, 1, myWep)	
				end
			end
			if(weapons[slot]) then
				local houseWep = weapons[slot][1]
				if(houseWep and houseWep ~= 0) then
					local ammo = weapons[slot][2]
					if(ammo > 0) then
						local row = exports.USGGUI:gridlistAddRow(housePanelGUI.weapons.houseGrid)
						exports.USGGUI:gridlistSetItemText(housePanelGUI.weapons.houseGrid, row, 1, getWeaponNameFromID(houseWep))
						exports.USGGUI:gridlistSetItemText(housePanelGUI.weapons.houseGrid, row, 2, tostring(ammo))
						exports.USGGUI:gridlistSetItemData(housePanelGUI.weapons.houseGrid, row, 1, houseWep)	
					end
				end
			end
		end
	end
end
addEventHandler("USGcnr_houses.updateWeaponStorage", localPlayer, updateDrugs)

function updatePermissions(permissions)
	housePermissions = permissions
end

addEvent("USGcnr_houses.openHousePanel", true)
function openHousePanel(isOwner, forSale, permissions, drugs, weapons)
	if(not isElement(housePanelGUI.window)) then
		createHousePanel()
		showCursor("panel", true)
	else
		if(not exports.USGGUI:getVisible(housePanelGUI.window)) then
			exports.USGGUI:setVisible(housePanelGUI.window, true)
			showCursor("panel", true)
		end
	end
	exports.USGGUI:setText(housePanelGUI.toggleSale, forSale and "Toggle sale off" or "Toggle sale on")
	exports.USGGUI:setEnabled(housePanelGUI.setPrice, forSale)
	isHouseOwner = isOwner
	-- load permissions
	exports.USGGUI:setEnabled(housePanelGUI.permissions.tab, isOwner)
	 updatePermissions(permissions)
	-- load drugs
	updateDrugs(drugs)
	-- load weapons
	updateWeapons(weapons)
end
addEventHandler("USGcnr_houses.openHousePanel", root, openHousePanel)

addEvent("USGcnr_houses.updateForSale", true)
addEventHandler("USGcnr_houses.updateForSale", localPlayer,
	function (forSale)
		exports.USGGUI:setText(housePanelGUI.toggleSale, forSale and "Toggle sale off" or "Toggle sale on")
		exports.USGGUI:setEnabled(housePanelGUI.setPrice, forSale)	
		exports.USGmsg:msg(forSale and "Your house has been put up for sale!" or "Your house is no longer for sale!", 0,255,0)
	end
)

function toggleHouseSale()
	triggerServerEvent("USGcnr_houses.toggleSale", localPlayer)
end

function setHousePrice()
	if(not isElement(setPriceDialog)) then
		setPriceDialog = exports.USGGUI:createDialog("Set house price", "Enter the new price for your house", "input","%d+")
		addEventHandler("onUSGGUIDialogFinish", setPriceDialog, setHousePriceFinish, false)
	else
		exports.USGGUI:focus(setPriceDialog)
	end
end

function setHousePriceFinish(result)
	local result = tonumber(result)
	if(result) then
		if(result <= 0) then
			exports.USGmsg:msg("The price must be at least $1.", 255, 0, 0)
			return
		end
		triggerServerEvent("USGcnr_houses.setPrice", localPlayer, result)
	end
end
local selectedPermissionAccount = false

function onSavePermissions()
	if(selectedPermissionAccount) then
		savePermissionsToAccount(selectedPermissionAccount)
	end
	triggerServerEvent("USGcnr_houses.updatePermissions", localPlayer, housePermissions)
end

function onClickPermissionsAccountList()
	local selected = exports.USGGUI:gridlistGetSelectedItem(housePanelGUI.permissions.accounts)
	if(selected) then

		local account = exports.USGGUI:gridlistGetItemText(housePanelGUI.permissions.accounts, selected, 1)
		loadPermissionAccount(account)
	end
end

function savePermissionsToAccount(account)
	local permissions = housePermissions[account]
	permissions[1] = exports.USGGUI:getCheckBoxState(housePanelGUI.permissions.options.canEnter)
	permissions[2] = { 
		exports.USGGUI:getCheckBoxState(housePanelGUI.permissions.options.depositDrugs), 
		exports.USGGUI:getCheckBoxState(housePanelGUI.permissions.options.withdrawDrugs), 
		exports.USGGUI:getCheckBoxState(housePanelGUI.permissions.options.viewDrugs) }
	permissions[3] = { 
		exports.USGGUI:getCheckBoxState(housePanelGUI.permissions.options.depositWeapons), 
		exports.USGGUI:getCheckBoxState(housePanelGUI.permissions.options.withdrawWeapons), 
		exports.USGGUI:getCheckBoxState(housePanelGUI.permissions.options.viewWeapons) }
end

function loadPermissionAccount(account)
	if(selectedPermissionAccount) then
		savePermissionsToAccount(selectedPermissionAccount)
	end
	selectedPermissionAccount = account
	local permissions = housePermissions[account]
	if(permissions) then
		exports.USGGUI:setCheckBoxState(housePanelGUI.permissions.options.canEnter, permissions[1])
		exports.USGGUI:setCheckBoxState(housePanelGUI.permissions.options.depositDrugs, permissions[2][1])
		exports.USGGUI:setCheckBoxState(housePanelGUI.permissions.options.withdrawDrugs, permissions[2][2])
		exports.USGGUI:setCheckBoxState(housePanelGUI.permissions.options.viewDrugs, permissions[2][3])
		exports.USGGUI:setCheckBoxState(housePanelGUI.permissions.options.depositWeapons, permissions[3][1])
		exports.USGGUI:setCheckBoxState(housePanelGUI.permissions.options.withdrawWeapons, permissions[3][2])
		exports.USGGUI:setCheckBoxState(housePanelGUI.permissions.options.viewWeapons, permissions[3][3])
	end
end

function onAddPermissionAccount()
	local account = exports.USGGUI:getText(housePanelGUI.permissions.account):lower()
	if(#account > 0) then
		if(housePermissions[account]) then
			exports.USGmsg:msg("This account is already added.", 255, 0, 0)
			return false
		end
		housePermissions[account] = {[1] = false, [2] = {false,false,false}, [3] = {false,false,false}} -- initiate account with all permissions to false
		local row = exports.USGGUI:gridlistAddRow(housePanelGUI.permissions.accounts)
		exports.USGGUI:gridlistSetItemText(housePanelGUI.permissions.accounts, row, 1, account)
		loadPermissionAccount(account)
		exports.USGGUI:setText(housePanelGUI.permissions.account, "")
	end
end

function depositDrug()
	local amount = tonumber(exports.USGGUI:getText(housePanelGUI.drugs.amount))
	if(not amount) then return end
	if(amount > 0) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(housePanelGUI.drugs.myGrid)
		if(selected) then
			local drugType = exports.USGGUI:gridlistGetItemText(housePanelGUI.drugs.myGrid, selected, 1)
			triggerServerEvent("USGcnr_houses.depositDrug", localPlayer, drugType, amount)
		else
			exports.USGmsg:msg("You did not select a drug!", 255, 0, 0)						
		end
	else
		exports.USGmsg:msg("You have to deposit at least 1 hit of drugs.", 255,0,0)
	end
end

function withdrawDrug()
	local amount = tonumber(exports.USGGUI:getText(housePanelGUI.drugs.amount))
	if(not amount) then return end
	if(amount > 0) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(housePanelGUI.drugs.houseGrid)
		if(selected) then
			local drugType = exports.USGGUI:gridlistGetItemText(housePanelGUI.drugs.houseGrid, selected, 1)
			triggerServerEvent("USGcnr_houses.withdrawDrug", localPlayer, drugType, amount)
		else
			exports.USGmsg:msg("You did not select a drug!", 255, 0, 0)			
		end
	else
		exports.USGmsg:msg("You have to withdraw at least 1 hit of drugs.", 255,0,0)
	end
end

function depositWeapon()
	local amount = tonumber(exports.USGGUI:getText(housePanelGUI.weapons.amount))
	if(not amount) then return end
	if(amount > 0) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(housePanelGUI.weapons.myGrid)
		if(selected) then
			local id = exports.USGGUI:gridlistGetItemData(housePanelGUI.weapons.myGrid, selected, 1)
			triggerServerEvent("USGcnr_houses.depositWeapon", localPlayer, id, amount)
		else
			exports.USGmsg:msg("You did not select a weapon!", 255, 0, 0)
		end
	else
		exports.USGmsg:msg("You have to deposit at least 1 piece of ammo.", 255,0,0)
	end
end

function withdrawWeapon()
	local amount = tonumber(exports.USGGUI:getText(housePanelGUI.weapons.amount))
	if(not amount) then return end
	if(amount > 0) then
		local selected = exports.USGGUI:gridlistGetSelectedItem(housePanelGUI.weapons.houseGrid)
		if(selected) then
			local id = exports.USGGUI:gridlistGetItemData(housePanelGUI.weapons.houseGrid, selected, 1)
			triggerServerEvent("USGcnr_houses.withdrawWeapon", localPlayer, id, amount)
		else
			exports.USGmsg:msg("You did not select a weapon!", 255, 0, 0)			
		end
	else
		exports.USGmsg:msg("You have to withdraw at least 1 piece of ammo.", 255,0,0)
	end
end