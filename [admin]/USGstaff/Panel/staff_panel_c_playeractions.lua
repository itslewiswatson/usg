local dialogArgs = {
	warpPlayerTo = {"Warp player to...", "Warp a player to someone", "select"},
	setDimension = {"Set dimension", "Set dimension, normal dimension is 0.", "input", "%d+"},
	setInterior = {"Set interior", "Set interior, normal interior is 0.", "input", "%d+"},
	setHealth = {"Set health", "Set health.", "input", "%d+"},
	setArmor = {"Set armor", "Set armor.", "input", "%d+"},
	giveVehicle = {"Give vehicle", "Give player a vehicle, enter name or ID.", "input", nil, 1},
	giveMoney = {"Give money", "Give player money, negative value to take.", "input", "%d+"},
	setSkin = {"Set skin", "Set player skin.", "input", "%d+"},
	giveWeapon = {"Give weapon", "Give player weapon,  ( name or ID | AMMO ).", "input"},
	renamePlayer = {"Rename player", "Rename the player.", "input", "[^%s]+", 1},
	kick = {"Kick player", "Kick the player.", "input", ".*", 1},
	shout = {"Shout to player", "Shout at the player.", "input", "[^%s]+", 1},
}
local normalActions = {
	warpToPlayer = true,
	destroyVehicle = true,
	fixVehicle = true,
	removeFromVehicle = true,
	frozenVehicle = true,
	toggleJetpack = true,
	freezePlayer = true,
	releaseArrest = true,
	forceRules = true,
	kickFromRoom = true,
	reconnect = true,
}

local clientActions = {
	spectate = true,
}
	

local actionDialogs = {}
local dialogActions = {}
local selectedPunishment

function createPlayerActionsTab()
	panelGUI.playeractions = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Player actions")}
	-- first row
	panelGUI.playeractions.warpToPlayer = exports.USGGUI:createButton(15,5,85,30,false,"Warp to",panelGUI.playeractions.tab)
	panelGUI.playeractions.warpPlayerTo = exports.USGGUI:createButton(110,5,85,30,false,"Warp player to",panelGUI.playeractions.tab)
	panelGUI.playeractions.setDimension = exports.USGGUI:createButton(205,5,85,30,false,"Set dimension",panelGUI.playeractions.tab)
	panelGUI.playeractions.setInterior = exports.USGGUI:createButton(300,5,85,30,false,"Set interior",panelGUI.playeractions.tab)
	panelGUI.playeractions.setHealth = exports.USGGUI:createButton(395,5,85,30,false,"Set health",panelGUI.playeractions.tab)
	panelGUI.playeractions.setArmor = exports.USGGUI:createButton(490,5,85,30,false,"Set armor",panelGUI.playeractions.tab)
	-- second row
	panelGUI.playeractions.giveVehicle = exports.USGGUI:createButton(15,45,85,30,false,"Give vehicle",panelGUI.playeractions.tab)
	panelGUI.playeractions.destroyVehicle = exports.USGGUI:createButton(110,45,85,30,false,"Destroy vehicle",panelGUI.playeractions.tab)
	panelGUI.playeractions.fixVehicle = exports.USGGUI:createButton(205,45,85,30,false,"Fix vehicle",panelGUI.playeractions.tab)
	panelGUI.playeractions.removeFromVehicle = exports.USGGUI:createButton(300,45,135,30,false,"Eject from vehicle",panelGUI.playeractions.tab)

	panelGUI.playeractions.frozenVehicle = exports.USGGUI:createButton(440,45,135,30,false,"(un)Freeze vehicle",panelGUI.playeractions.tab)
	-- third row
	panelGUI.playeractions.giveMoney = exports.USGGUI:createButton(15,85,85,30,false,"Give money",panelGUI.playeractions.tab)
	panelGUI.playeractions.setSkin = exports.USGGUI:createButton(110,85,85,30,false,"Set skin",panelGUI.playeractions.tab)
	panelGUI.playeractions.giveWeapon = exports.USGGUI:createButton(205,85,85,30,false,"Give weapon",panelGUI.playeractions.tab)
	panelGUI.playeractions.toggleJetpack = exports.USGGUI:createButton(300,85,85,30,false,"Toggle jetpack",panelGUI.playeractions.tab)
	panelGUI.playeractions.freezePlayer = exports.USGGUI:createButton(395,85,85,30,false,"(un)Freeze",panelGUI.playeractions.tab)
	panelGUI.playeractions.spectate = exports.USGGUI:createButton(490,85,85,30,false,"Spectate",panelGUI.playeractions.tab)
	-- fourth
	panelGUI.playeractions.renamePlayer = exports.USGGUI:createButton(15,125,85,30,false,"Rename",panelGUI.playeractions.tab)
	panelGUI.playeractions.reconnect = exports.USGGUI:createButton(110,125,85,30,false,"Reconnect",panelGUI.playeractions.tab)
	panelGUI.playeractions.kick = exports.USGGUI:createButton(205,125,85,30,false,"Kick",panelGUI.playeractions.tab)
	panelGUI.playeractions.releaseArrest = exports.USGGUI:createButton(300,125,135,30,false,"Release from arrest",panelGUI.playeractions.tab)
	panelGUI.playeractions.shout = exports.USGGUI:createButton(490,125,85,30,false,"Shout",panelGUI.playeractions.tab)
	-- fifth 
	panelGUI.playeractions.forceRules = exports.USGGUI:createButton(15,165,135,30,false,"Force to read rules",panelGUI.playeractions.tab)
	panelGUI.playeractions.kickFromRoom = exports.USGGUI:createButton(160, 165, 135, 30, false, "Kick from room", panelGUI.playeractions.tab)
	panelGUI.playeractions.punishments = exports.USGGUI:createGridList("center",220,tabWidth-20,tabHeight-225,false,panelGUI.playeractions.tab, tocolor(10,10,10))
		exports.USGGUI:gridlistAddColumn(panelGUI.playeractions.punishments, "Punishment", 0.75)
		exports.USGGUI:gridlistAddColumn(panelGUI.playeractions.punishments, "Date", 0.25)
		addEventHandler("onUSGGUIClick",panelGUI.playeractions.punishments,onPlayerPunishmentsClick)
		
	addEventHandler("onUSGGUIClick",panelGUI.playeractions.tab,onPlayerActionClick)
	panelGUI.playeractions.onPlayerClear = clearPunishments
end

function clearPunishments()
	exports.USGGUI:gridlistClear(panelGUI.playeractions.punishments)	
end

function onPlayerActionClick(btn,state)
	if ( state == "up" ) then
		if ( isElement(selectedPlayer) ) then
			for key,gui in pairs(panelGUI.playeractions) do
				if ( gui == source ) then
					if ( dialogArgs[key] ) then
						if ( isElement(actionDialogs[key]) ) then exports.USGGUI:closeDialog(actionDialogs[key]) end
						local args = dialogArgs[key]
						if ( args[3] ~= "select" ) then
							actionDialogs[key] = exports.USGGUI:createDialog(unpack(args))
						else
							local selectionItems = false
							if ( key == "warpPlayerTo" ) then
								local players = getElementsByType("player")
								selectionItems = {}
								for i=1,#players do
									selectionItems[players[i]] = getPlayerName(players[i])
								end
								actionDialogs[key] = exports.USGGUI:createDialog(args[1],args[2],args[3],selectionItems, true)
							end
						end
						if ( isElement(actionDialogs[key]) ) then
							dialogActions[actionDialogs[key]] = key
							addEventHandler("onUSGGUIDialogFinish",actionDialogs[key],onActionDialogFinish,false)
						end
					elseif ( normalActions[key] ) then
						triggerServerEvent("USGstaff.panel.playeraction",localPlayer, key, selectedPlayer)
					elseif ( clientActions[key] ) then
						performAction(key)
					end
				end
			end
		end
	end
end

function onActionDialogFinish(result)
	if ( dialogActions[source] and result ) then
		local action = dialogActions[source]
		local values = {result}
		if ( action == "warpPlayerTo" and not isElement(result) ) then
			return false
		elseif ( ( action == "setDimension" or action == "setInterior" or action == "setSkin" or action == "setHealth" or action == "setArmor" 	 or action == "giveMoney" )
			and type(tonumber(result)) == "number" ) then
				values[1] = tonumber(result)
		elseif (action == "giveWeapon") then
			local wepPart = exports.USG:trimString(string.sub(result,0, string.find(result,"|")-1))
			local ammoPart = exports.USG:trimString(string.sub(result, string.find(result,"|")+1, -1 ))
			if ( ( getWeaponIDFromName(wepPart) or getWeaponNameFromID(tonumber(wepPart)) ) and tonumber(ammoPart)  ) then
				values[1] = getWeaponIDFromName(wepPart) or tonumber(wepPart)
				values[2] = tonumber(ammoPart)
			else
				exports.USGmsg:msg("Use the correct format and make sure the weapon exists.", 255, 0, 0)
				return false
			end
		elseif (action == "giveVehicle") then
			values[1] = tonumber(result)
			if(not values[1] or not getVehicleNameFromModel(values[1])) then
				values[1] = getVehicleModelFromName(result)
				if(not values[1]) then
					exports.USGmsg:msg("Vehicle name/ID invalid!", 255, 0, 0)
					return false
				end
			end
		elseif (action == "rename") then
			if(not values[1]) then
				return false
			end
		end
		triggerServerEvent("USGstaff.panel.playeraction",localPlayer, action, selectedPlayer, values)
	end
end

function onPlayerPunishmentsClick(btn,state)
	if ( state == "down" ) then
		local selRow = exports.USGGUI:gridlistGetSelectedItem(source)
		if ( selRow ) then
			local punishment = exports.USGGUI:gridlistGetItemData(source,selRow,1)
			if ( punishment ) then
				if ( btn == 2 ) then -- toggle activeness
					if ( punishment.active == 1 ) then
						punishment.active = 0
						exports.USGGUI:gridlistSetItemColor(source,selRow,1,tocolor(255,0,0))
						exports.USGGUI:gridlistSetItemColor(source,selRow,2,tocolor(255,0,0))
					elseif ( punishment.active == 0 ) then
						punishment.active = 1
						exports.USGGUI:gridlistSetItemColor(source,selRow,1,tocolor(255,255,255))
						exports.USGGUI:gridlistSetItemColor(source,selRow,2,tocolor(255,255,255))
					end
					triggerServerEvent("USGstaff.panel.setPunishmentActive",localPlayer,punishment.punishid,punishment.active)
				elseif ( btn == 3 ) then -- edit text
					if ( isElement(punishTextChangeDialog) ) then exports.USGGUI:closeDialog(punishTextChangeDialog) end
					punishment.row = selRow
					selectedPunishment = punishment
					punishTextChangeDialog = exports.USGGUI:createDialog("Edit punishment text", "New punishment text:","input")
					addEventHandler("onUSGGUIDialogFinish",punishTextChangeDialog,onPunishTextChangeDialogOK)
				end
				exports.USGGUI:gridlistSetItemData(source,selRow,1,punishment)
			end
		end
	end
end

function onPunishTextChangeDialogOK(newText)
	if ( selectedPunishment and newText and newText ~= "" ) then
		triggerServerEvent("USGstaff.panel.setPunishmentText",localPlayer,selectedPunishment.punishid,newText)
		exports.USGGUI:gridlistSetItemText(panelGUI.playeractions.punishments, selectedPunishment.row, 1, newText)
	end
	selectedPunishment = false
end

function performAction(action)
	if(action == "spectate") then
		toggleSpectate()
	end
end

-- SPECATATING
local spectating = false
local spectateClose
function toggleSpectate()
	if(spectating) then
		setCameraTarget(localPlayer)
		unbindKey("backspace","down",toggleSpectate)
		spectating = false
		setElementFrozen(localPlayer, false)
	else
		setElementFrozen(localPlayer, true)
		setCameraTarget(selectedPlayer)
		bindKey("backspace", "down", toggleSpectate)
		spectating = true
		toggleStaffPanel()
		exports.USGmsg:msg("Use backspace to stop spectating.", 0, 255, 0)
	end
end