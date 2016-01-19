loadstring(exports.mysql:getQueryTool())() -- load mysql query tool into the environment

addEvent( "USGstaff.panel.requestPlayerInfo", true )
addEventHandler("USGstaff.panel.requestPlayerInfo",root,
	function (player)
		if ( isElement(player) and exports.USGadmin:isPlayerStaff(client) ) then
			local data = {}
			data.username = exports.USGaccounts:getPlayerAccount(player)
			data.ip = getPlayerIP(player)
			data.logintime = "N/A"
			data.bankmoney = exports.USGcnr_banking:getPlayerBankBalance(player)
			data.money = getPlayerMoney(player)
			data.group = exports.USGcnr_groups:getPlayerGroupName(player) or "N/A"
			data.premiumtime = 0
			data.serial = getPlayerSerial(player)
			data.punishments = exports.USGadmin:getPlayerPunishments(player, false) or {} -- get all punishments including inactive
			data.weapons = {}
			for slot=1, 11 do
				local weapon = getPedWeapon(player, slot)
				if(weapon) then
					local ammo = getPedTotalAmmo(player, slot)
					if(ammo > 0) then
						table.insert(data.weapons, {weapon, ammo})
					end
				end
			end		
			singleQuery(requestPlayerInfoCallback,{client,player,data},"SELECT x.email, y.staffnotes FROM accounts x, accountsdata y WHERE x.username=? AND y.username=?", data.username, data.username)
		end
	end
)

function requestPlayerInfoCallback(result, requester, player, data)
	if(not exports.USGadmin:isPlayerStaff(requester)) then return end
	local result = result or {email = "Error", staffnotes = "Error"}
	data.email = result.email
	data.staffnotes = result.staffnotes
	triggerClientEvent(requester,"USGstaff.panel.recievePlayerInfo",player,data)
end

addEvent("USGstaff.panel.punish", true)
addEventHandler("USGstaff.panel.punish", root,
	function(serial, account, duration, punishment, reason)
		if(not exports.USGadmin:isPlayerStaff(client)) then return end
		local targetPlayer
		for i, player in ipairs(getElementsByType("player")) do
			if(exports.USGaccounts:getPlayerAccount(player) == account) then
				targetPlayer = player
				break
			end
		end
		if(targetPlayer) then
			if(exports.USGrooms:getPlayerRoom(targetPlayer) ~= "cnr" and punishment == "jail") then
				exports.USGmsg:msg(client, "You can't jail players who are not in the CnR room, he will be jailed when he joins it.", 255, 128, 0)
			else
				exports.USGadmin:addActivePunishment(account, punishment, duration, targetPlayer) -- apply it's effects
				if(punishment == "jail") then
					local output = string.format("%s was jailed by %s for %i seconds ( %s ).",getPlayerName(targetPlayer),getPlayerName(client),duration,reason)
					for i, player in ipairs(getElementsByType("player")) do
						if(exports.USGrooms:getPlayerRoom(player) == exports.USGrooms:getPlayerRoom(targetPlayer) or player == client) then
							outputChatBox(output, player, 255,128,0)
						end
					end
				elseif(punishment:sub(0,4) == "mute") then
					local muteType = punishment:sub(6)
					local output = string.format("%s was muted ( %s ) by %s for %i seconds ( %s ).",getPlayerName(targetPlayer),muteType,getPlayerName(client),duration,reason)
					if(muteType == "global" or mueType == "support") then
						outputChatBox(output, root, 255, 128, 0)
					else
						for i, player in ipairs(getElementsByType("player")) do
							if(exports.USGrooms:getPlayerRoom(player) == exports.USGrooms:getPlayerRoom(targetPlayer) or player == client) then
								outputChatBox(output, player, 255,128,0)
							end
						end
					end
				end
			end
			exports.USGadmin:addPlayerPunishment(targetPlayer,reason,client)
		else
			exports.USGadmin:addOfflinePunishment(account,serial,reason,client) -- log it in the list			
		end
	end
)

addEvent("USGstaff.panel.setPunishmentActive", true )
addEventHandler("USGstaff.panel.setPunishmentActive", root,
	function (punishID,active)
		if(not exports.USGadmin:isPlayerStaff(client)) then return end
		if ( punishID and active == 1 or active == 0 ) then
			exports.USGadmin:setPunishmentActive(punishID, active)
		end
	end
)

addEvent("USGstaff.panel.setPunishmentText", true )
addEventHandler("USGstaff.panel.setPunishmentText", root,
	function (punishID, newText)
		if(not exports.USGadmin:isPlayerStaff(client)) then return end
		if ( punishID and type(newText) == "string" ) then
			exports.USGadmin:setPunishmentText(punishID, newText)
		end
	end
)

addEvent("USGstaff.panel.playeraction", true)
addEventHandler("USGstaff.panel.playeraction",root,
	function (action, player, args)
		if not ( isElement(player)) then return false end
		if not (exports.USGadmin:isPlayerStaff(client)) then return false end
		local pVehicle = getPedOccupiedVehicle(player)
		if ( action == "warpPlayerTo" ) then
			teleportPlayerTo(player,args[1])
			exports.USGmsg:msg(player,"You have been warped to "..getPlayerName(args[1]).." by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have warped "..getPlayerName(player)..".", 0, 255,0)
		elseif ( action == "setDimension" ) then
			setElementDimension(player,args[1])
			exports.USGmsg:msg(player,"Your dimension was set to "..args[1].." by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have set "..getPlayerName(player).."'s dimension to "..args[1]..".", 0, 255,0)
		elseif ( action == "setInterior" ) then
			setElementInterior(player,args[1])
			exports.USGmsg:msg(player,"Your interior was set to "..args[1].." by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have set "..getPlayerName(player).."'s interior to "..args[1]..".", 0, 255,0)
		elseif ( action == "setHealth" ) then
			if (isProtected(player,source)) then return end
			setElementHealth(player,args[1])
			exports.USGmsg:msg(player,"Your health was set to "..args[1].." by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have set "..getPlayerName(player).."'s health to "..args[1]..".", 0, 255,0)
		elseif ( action == "setArmor" ) then
			setPedArmor(player,args[1])
			exports.USGmsg:msg(player,"Your armor was set to "..args[1].." by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have set "..getPlayerName(player).."'s armor to "..args[1]..".", 0, 255,0)
		elseif ( action == "setSkin" ) then
			setElementModel(player,args[1])
			exports.USGmsg:msg(player,"Your skin was set to "..args[1].." by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have set "..getPlayerName(player).."'s skin to "..args[1]..".", 0, 255,0)
		elseif ( action == "giveMoney" ) then
			if(args[1] < 0) then
				takePlayerMoney(player, -args[1])
			else
				givePlayerMoney(player, args[1])
			end
			exports.USGmsg:msg(client, "You have given "..getPlayerName(player).." "..exports.USG:formatMoney(args[1])..".", 0, 255,0)
		elseif ( action == "giveVehicle" ) then
			local px,py,pz = getElementPosition(player)
			local _,_,prz = getElementRotation(player)
			local veh = createVehicle(args[1],px,py,pz+2,0,0,prz)
			setElementData(veh, "room", "cnr")
			setElementDimension(veh, getElementDimension(player))
			setElementInterior(veh, getElementInterior(player))
			warpPedIntoVehicle(player,veh)
			exports.USGmsg:msg(player,"You have been given a "..getVehicleNameFromModel(args[1]).." by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have given "..getPlayerName(player).." a "..getVehicleNameFromModel(args[1])..".", 0, 255,0)
		elseif ( action == "giveWeapon" ) then
			giveWeapon(player,args[1],args[2],true)
			local wepName = getWeaponNameFromID(args[1])
			exports.USGmsg:msg(player,"You have been given a "..wepName.." with "..args[2].." ammo by "..getPlayerName(client))
			exports.USGmsg:msg(client, "You have given "..getPlayerName(player).." a "..wepName..".", 0, 255,0)
		elseif ( action == "renamePlayer" ) then
			if (isProtected(player,source)) then return end
			setPlayerName(player,args[1])
			exports.USGmsg:msg(player,"Your name was changed to "..args[1].." by "..getPlayerName(client))	
		elseif ( action == "kick" ) then
			if (isProtected(player,source)) then return end
			kickPlayer(player,getPlayerName(client), args[1])
		elseif ( action == "shout" ) then
			triggerClientEvent(player,"USGstaff.panel.onShout",client,args[1])
			exports.USGmsg:msg(client, "You have sent a shout to "..getPlayerName(player)..".", 0, 255,0)
		-- STATIC ACTIONS
		elseif ( action == "warpToPlayer" ) then
			teleportPlayerTo(client,player)
		elseif ( action == "destroyVehicle" ) then
			if (isProtected(player,source)) then return end
			if ( pVehicle ) then
				destroyElement(pVehicle)
				exports.USGmsg:msg(player,"Your vehicle was destroyed by "..getPlayerName(client))
				exports.USGmsg:msg(client, "You have destroyed "..getPlayerName(player).."'s vehicle.", 0, 255,0)
			else
				exports.USGmsg:msg(client, "This player is not in a vehicle.", 255, 0,0)				
			end
		elseif ( action == "fixVehicle" ) then
			if ( pVehicle ) then
				local rx, ry, rz = getElementRotation(pVehicle)
				if (rx > 110) and (rx < 250) then
					local x, y, z = getElementPosition(pVehicle)
					setElementRotation(pVehicle, rx + 180, ry, rz)
					setElementPosition(pVehicle, x, y, z + 2)
				end
				fixVehicle(pVehicle)
				exports.USGmsg:msg(player,"Your vehicle was fixed by "..getPlayerName(client))
				exports.USGmsg:msg(client, "You have fixed "..getPlayerName(player).."'s vehicle.", 0, 255,0)
			else
				exports.USGmsg:msg(client, "This player is not in a vehicle.", 255, 0,0)				
			end
		elseif ( action == "removeFromVehicle" ) then
			if (isProtected(player,source)) then return end
			if ( pVehicle ) then
				removePedFromVehicle(player)
				exports.USGmsg:msg(player,"You have been ejected from your vehicle by "..getPlayerName(client))
				exports.USGmsg:msg(client, "You have ejected "..getPlayerName(player).." from their vehicle.", 0, 255,0)
			else
				exports.USGmsg:msg(client, "This player is not in a vehicle.", 255, 0,0)
			end
		elseif ( action == "frozenVehicle" ) then
			if ( pVehicle ) then
				if ( isElementFrozen(pVehicle) ) then
					setElementFrozen(pVehicle,false)
					exports.USGmsg:msg(player,"Your vehicle has been unfrozen by "..getPlayerName(client))			
					exports.USGmsg:msg(client, "You have unfrozen "..getPlayerName(player).."'s vehicle.", 0, 255,0)		
				else
					setElementFrozen(pVehicle,true)
					exports.USGmsg:msg(player,"Your vehicle has been frozen by "..getPlayerName(client))
					exports.USGmsg:msg(client, "You have frozen "..getPlayerName(player).."'s vehicle.", 0, 255,0)
				end
			else
				exports.USGmsg:msg(client, "This player is not in a vehicle.", 255, 0,0)				
			end
		elseif ( action == "toggleJetpack" ) then
			if ( doesPedHaveJetPack(player) ) then
				removePedJetPack(player)
				exports.USGmsg:msg(player,"Your jetpack was removed by "..getPlayerName(source))
				exports.USGmsg:msg(client, "You have removed "..getPlayerName(player).."'s jetpack.", 0, 255,0)
			else
				givePedJetPack(player)
				exports.USGmsg:msg(player,"You have been given a jetpack by "..getPlayerName(source))	
				exports.USGmsg:msg(client, "You have give "..getPlayerName(player).." a jetpack.", 0, 255,0)
			end
		elseif ( action == "freezePlayer" ) then
			if (isProtected(player,source)) then return end
			if ( isElementFrozen(player) ) then
				setElementFrozen(player,false)
				exports.USGmsg:msg(player,"You have been unfrozen by "..getPlayerName(source))
				exports.USGmsg:msg(client, "You have unfrozen "..getPlayerName(player)..".", 0, 255,0)
			else
				setElementFrozen(player,true)
				exports.USGmsg:msg(player,"You have been frozen by "..getPlayerName(source))
				exports.USGmsg:msg(client, "You have frozen "..getPlayerName(player)..".", 0, 255,0)
			end
		elseif ( action == "spectate" ) then
			--
		elseif ( action == "releaseArrest" ) then
			if(exports.USGcnr_job_police:releasePlayer(player)) then
				exports.USGmsg:msg(client, "You have released "..getPlayerName(player)..".", 0, 255,0)
			else
				exports.USGmsg:msg(client, "This player is not arrested.", 255, 0,0)
			end
		elseif ( action == "forceRules" ) then
			if (isProtected(player,source)) then return end
			exports.USGadmin:showPlayerRules(player)
			exports.USGmsg:msg(player, "You have been forced to read the rules by "..getPlayerName(client)..".", 0, 255,0)
			exports.USGmsg:msg(client, "You have forced "..getPlayerName(player).." to read the rules.", 0, 255,0)
		elseif( action == "kickFromRoom" ) then
			if (isProtected(player,source)) then return end
			exports.USGrooms:removePlayerFromRoom(player)
			exports.USGmsg:msg(client, "You have removed " ..getPlayerName(player).." from his room.", 0, 255, 0)
		elseif( action == "reconnect" ) then
			if (isProtected(player,source)) then return end
			redirectPlayer(player, "", 0)
		end
	end
)

function teleportPlayerTo(player,target)
	local veh = getPedOccupiedVehicle(player)
	local tx,ty,tz = getElementPosition(target)

	if ( veh ) then
		setElementPosition(veh,tx+1,ty+1,tz+1)
		setElementDimension(veh, getElementDimension(target))
		setElementInterior(veh, getElementInterior(target))
	else
		setElementPosition(player,tx+1,ty+1,tz+1)
		setElementDimension(player, getElementDimension(target))
		setElementInterior(player, getElementInterior(target))		
	end
end

addEvent("USGstaff.updateNotes", true)
function updatePlayerNotes(player, notes)
	if(not exports.USGadmin:isPlayerStaff(client)) then return end
	if(not isElement(player)) then
		exports.USGmsg:msg(source,"This player has already disconnected!", 255,0,0)
		return
	end
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(account) then
		exports.Mysql:execute("UPDATE accountsdata SET staffnotes=? WHERE username=?",notes,account)
		exports.USGmsg:msg(source,"Successfully updated notes!", 0,255,0)
	end
end
addEventHandler("USGstaff.updateNotes", root, updatePlayerNotes)

----- bans
addEvent("USGstaff.panel.requestBans", true)
addEvent("USGstaff.panel.removeBan", true)
addEvent("USGstaff.panel.addBan", true)

function onPlayerRequestBans(player)
	if(not exports.USGadmin:isPlayerStaff(player) or exports.USGadmin:getPlayerStaffLevel(player) < 5) then return end
	local bans = exports.USGbans:getBans()
	triggerClientEvent(player, "USGstaff.panel.recieveBans", player, bans)
end
addEventHandler("USGstaff.panel.requestBans", root, function () onPlayerRequestBans(source) end)

function removeBan(id)
	if(not exports.USGadmin:isPlayerStaff(client) or exports.USGadmin:getPlayerStaffLevel(client) < 5) then return end
	exports.USGbans:removeBan(id)
	onPlayerRequestBans(client)
end
addEventHandler("USGstaff.panel.removeBan", root, removeBan)

function addBan(banType, target, reason, duration)
	if(not exports.USGadmin:isPlayerStaff(client) or exports.USGadmin:getPlayerStaffLevel(client) < 5) then return end
	exports.USGbans:addBan(banType, target, reason, getPlayerName(client), duration)
	setTimer(onPlayerRequestBans, 1000, 1, client) -- timer because addBan inserts ban, ( has to wait for mysql )
end
addEventHandler("USGstaff.panel.addBan", root, addBan)

function isProtected(plr,adm)
	if not (plr) or not (adm) then return false end
	if(plr == adm) then return false end
	if(exports.USGaccounts:getPlayerAccount(plr) == "union") then return true end
	return false
end