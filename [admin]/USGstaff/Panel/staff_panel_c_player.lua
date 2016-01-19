
selectedPlayer = false
local playerInfoLabels = {}
local playerRow = {}

function createPlayerInfoTab()
	playerInfoLabels = {}
	selectedPlayer = false
	panelGUI.playerinfo = {tab = exports.USGGUI:addTab(panelGUI.tabpanel,"Player info")}
		addEventHandler("onUSGGUIClick",panelGUI.playerinfo.tab,onPlayerInfoClick)
	panelGUI.playerinfo.ip = exports.USGGUI:createLabel("left", "top", tabWidth/2, 20,false,"IP: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="ip", element = panelGUI.playerinfo.ip, infoType = "server", pre = "IP: "})
	panelGUI.playerinfo.serial = exports.USGGUI:createLabel("right", "top", tabWidth/2, 20,false,"Serial: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="serial", element = panelGUI.playerinfo.serial, infoType = "server", pre = "Serial: "})
	panelGUI.playerinfo.account = exports.USGGUI:createLabel("left", 20, tabWidth/2, 20,false,"Account: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="account", element = panelGUI.playerinfo.account, infoType = "client", pre = "Account: "})
	panelGUI.playerinfo.logintime = exports.USGGUI:createLabel("right", 20, tabWidth/2, 20,false,"Logged in at: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="logintime", element = panelGUI.playerinfo.logintime, infoType = "client", pre = "Logged in at: "})
	panelGUI.playerinfo.position = exports.USGGUI:createLabel("left", 40, tabWidth, 20,false,"Position : N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="position", element = panelGUI.playerinfo.position, infoType = "client", pre = "Position: "})
	panelGUI.playerinfo.dim_int = exports.USGGUI:createLabel("left", 60, tabWidth/2, 20,false,"Dimension, interior: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="dim_int", element = panelGUI.playerinfo.dim_int, infoType = "client", pre = "Dimension, interior: "})
	panelGUI.playerinfo.vehicle = exports.USGGUI:createLabel("right", 60, tabWidth/2, 20,false,"Vehicle: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="vehicle", element = panelGUI.playerinfo.vehicle, infoType = "client", pre = "Vehicle: "})
	panelGUI.playerinfo.vehiclehp = exports.USGGUI:createLabel("left", 80, tabWidth/2, 20,false,"Vehicle health: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="vehiclehp", element = panelGUI.playerinfo.vehiclehp, infoType = "client", pre = "Vehicle health: "})
	panelGUI.playerinfo.health_armor = exports.USGGUI:createLabel("right", 80, tabWidth/2, 20,false,"Health, armor: N/A, N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="health_armor", element = panelGUI.playerinfo.health_armor, infoType = "client", pre = "Health, armor: "})
	panelGUI.playerinfo.room = exports.USGGUI:createLabel("left", 100, tabWidth/2, 20,false,"Room: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="room", element = panelGUI.playerinfo.room, infoType = "client", pre = "Room: "})
	panelGUI.playerinfo.skin = exports.USGGUI:createLabel("right", 100, tabWidth/2, 20,false,"Skin: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="skin", element = panelGUI.playerinfo.skin, infoType = "client", pre = "Skin: "})
	panelGUI.playerinfo.playtime = exports.USGGUI:createLabel("left", 120, tabWidth/2, 20,false,"Hours played: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="playtime", element = panelGUI.playerinfo.playtime, infoType = "client", pre = "Playtime: "})
	panelGUI.playerinfo.team = exports.USGGUI:createLabel("right", 120, tabWidth/2, 20,false,"Team: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="team", element = panelGUI.playerinfo.team, infoType = "client", pre = "Team: "})
	panelGUI.playerinfo.occupation = exports.USGGUI:createLabel("left", 140, tabWidth/2, 20,false,"Occupation: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="occupation", element = panelGUI.playerinfo.occupation, infoType = "client", pre = "Occupation: "})
	panelGUI.playerinfo.money = exports.USGGUI:createLabel("right", 140, tabWidth/2, 20,false,"Money: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="money", element = panelGUI.playerinfo.money, infoType = "server", pre = "Money: "})
	panelGUI.playerinfo.bankmoney = exports.USGGUI:createLabel("left", 160, tabWidth/2, 20,false,"Bank money: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="bankmoney", element = panelGUI.playerinfo.bankmoney, infoType = "server", pre = "Bank money: "})
	panelGUI.playerinfo.premium = exports.USGGUI:createLabel("right", 160, tabWidth/2, 20,false,"Premium hours: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="premiumtime", element = panelGUI.playerinfo.premium, infoType = "server", pre = "Premium hours: "})
	panelGUI.playerinfo.group = exports.USGGUI:createLabel("left", 180, tabWidth/2, 20,false,"Group: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="group", element = panelGUI.playerinfo.group, infoType = "server", pre = "Group: "})
	panelGUI.playerinfo.email = exports.USGGUI:createLabel("right", 180, tabWidth/2, 20,false,"Email: N/A",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="email", element = panelGUI.playerinfo.email, infoType = "server", pre = "Email: "})
	panelGUI.playerinfo.weapons = exports.USGGUI:createGridList("center",220,tabWidth-20,175,false,panelGUI.playerinfo.tab, tocolor(10,10,10))
		exports.USGGUI:gridlistAddColumn(panelGUI.playerinfo.weapons, "Weapon", 0.55)
		exports.USGGUI:gridlistAddColumn(panelGUI.playerinfo.weapons, "Ammo", 0.45)

	panelGUI.playerinfo.staffnotes = exports.USGGUI:createMemo("center",405,tabWidth-20,165,false,"",panelGUI.playerinfo.tab)
		table.insert(playerInfoLabels, {key="staffnotes", element = panelGUI.playerinfo.staffnotes, infoType = "server", pre = ""})
	panelGUI.playerinfo.updatestaffnotes = exports.USGGUI:createButton("right", "bottom", 60,25,false,"Update",panelGUI.playerinfo.staffnotes)
	addEventHandler("onUSGGUISClick", panelGUI.playerinfo.updatestaffnotes, onPlayerUpdateNotes, false)
	return true
end

function addPlayerToGrid(player,filter)
	if ( isElement(panelGUI.playergrid) ) then
		local nick = getPlayerName(player)
		if ( not filter or filter == "" or string.find(nick:lower(),exports.USG:escapeString(filter):lower()) ) then
			local team = getPlayerTeam(player)
			local r,g,b = 100,100,100 -- teamless
				if ( team ) then
					r,g,b = getTeamColor(team)
				end
			local row = exports.USGGUI:gridlistAddRow(panelGUI.playergrid)
			exports.USGGUI:gridlistSetItemText(panelGUI.playergrid,row,1,nick)
			exports.USGGUI:gridlistSetItemColor(panelGUI.playergrid,row,1,tocolor(r,g,b))
			exports.USGGUI:gridlistSetItemData(panelGUI.playergrid,row,1,player)
			playerRow[player] = row
		end
	end
end

function fillPlayerGrid(filter)
	if ( isElement(panelGUI.playergrid) ) then
		playerRow = {}
		exports.USGGUI:gridlistClear(panelGUI.playergrid)
		local players = getElementsByType("player")
		for i, player in ipairs(players) do
			addPlayerToGrid(player,filter)
		end
	end
end

addEventHandler("onClientPlayerChangeNick", root,
	function (old, new)
		if(playerRow[source]) then
			exports.USGGUI:gridlistSetItemText(panelGUI.playergrid,playerRow[source],1,new)
		else
			fillPlayerGrid()
		end
	end
)

addEventHandler("onClientPlayerJoin", root,
	function ()
		addPlayerToGrid(source)
	end
)
addEventHandler("onClientPlayerQuit", root,
	function ()
		fillPlayerGrid()
	end
)

function loadPlayerInfo(player)
	exports.USGGUI:closeDialog(punishTextChangeDialog)
	exports.USGGUI:gridlistClear(panelGUI.playerinfo.weapons)
	loadClientPlayerInfo(player)
	triggerServerEvent("USGstaff.panel.requestPlayerInfo",localPlayer,player)
end

function loadPlayerInfoTable(info,loadType)
	for i=1,#playerInfoLabels do
		if ( info[playerInfoLabels[i].key] and playerInfoLabels[i].infoType == loadType ) then
			exports.USGGUI:setText(playerInfoLabels[i].element,playerInfoLabels[i].pre..info[playerInfoLabels[i].key])
		elseif ( loadType == playerInfoLabels[i].infoType ) then
			exports.USGGUI:setText(playerInfoLabels[i].element,playerInfoLabels[i].pre.."N/A")
		end
	end
end

function loadClientPlayerInfo(player)
	local cInfo = {}
	cInfo.logintime = exports.USG:getDateTimeString(getElementData(player, "loginTick"))
	cInfo.account = exports.USGaccounts:getPlayerAccount(player) or "N/A"
	cInfo.dim_int = (getElementDimension(player) or 0)..", "..( getElementInterior(player) or 0)
	local px,py,pz = getElementPosition(player)
	cInfo.position = table.concat({math.floor(px),math.floor(py),math.floor(pz)},", ").." ("..getZoneName(px,py,pz)..", "..exports.USG:getPlayerChatZone(player)..")"
	cInfo.playtime = math.floor((getElementData(player, "playTime") or 0)/60).." hours"
	local veh = getPedOccupiedVehicle(player)
	cInfo.vehicle = "N/A"
	cInfo.vehiclehp = "N/A"
		if ( isElement(veh) ) then
			local model = getElementModel(veh)
			cInfo.vehicle = getVehicleNameFromModel(model).." ["..model.."]"
			cInfo.vehiclehp = math.floor(getElementHealth(veh)).."%"
		end
	cInfo.health_armor = (getElementHealth(player) or "N/A")..", "..(getPedArmor(player) or "N/A")
	cInfo.room = exports.USGrooms:getPlayerRoomFriendly(player)
	cInfo.skin = getElementModel(player) or "N/A"
	cInfo.team = "N/A"
	cInfo.occupation = getElementData(player, "occupation") or "N/A"
	local pTeam = getPlayerTeam(player)
		if ( isElement(pTeam) ) then
			cInfo.team  = getTeamName(pTeam)
		end
	loadPlayerInfoTable(cInfo,"client")
end

addEvent("USGstaff.panel.recievePlayerInfo", true)
function loadServerPlayerInfo(data)
	if ( source == selectedPlayer ) then
		data.money = exports.USG:formatMoney(data.money)
		data.bankmoney = exports.USG:formatMoney(data.bankmoney)
		loadPlayerInfoTable(data,"server")
		for _,tab in pairs(panelGUI) do
			if ( type(tab) == "table" and type(tab.receivedPlayerSerial) == "function" ) then
				tab.receivedPlayerSerial(data.serial)
			end
		end		
		--load punishments in playeractions tab
		exports.USGGUI:gridlistClear(panelGUI.playeractions.punishments)
		for i=1, #data.punishments do
			local punish = data.punishments[i]
			local row = exports.USGGUI:gridlistAddRow(panelGUI.playeractions.punishments)
			exports.USGGUI:gridlistSetItemData(panelGUI.playeractions.punishments,row,1,punish)
			exports.USGGUI:gridlistSetItemText(panelGUI.playeractions.punishments,row,1,punish.punishtext)
			exports.USGGUI:gridlistSetItemText(panelGUI.playeractions.punishments,row,2,punish.punishdate)
			if ( punish.active == 0 ) then
				exports.USGGUI:gridlistSetItemColor(panelGUI.playeractions.punishments,row,1,tocolor(255,0,0))
				exports.USGGUI:gridlistSetItemColor(panelGUI.playeractions.punishments,row,2,tocolor(255,0,0))
			end
		end
		-- load weapons
		exports.USGGUI:gridlistClear(panelGUI.playerinfo.weapons)
		for i, wep in ipairs(data.weapons) do
			local row = exports.USGGUI:gridlistAddRow(panelGUI.playerinfo.weapons)
			exports.USGGUI:gridlistSetItemText(panelGUI.playerinfo.weapons,row,1,getWeaponNameFromID(wep[1]))
			exports.USGGUI:gridlistSetItemText(panelGUI.playerinfo.weapons,row,2,tostring(wep[2]))
		end	
	end
end
addEventHandler("USGstaff.panel.recievePlayerInfo", root, loadServerPlayerInfo)

function onPlayerSearchChange(old,new)
	fillPlayerGrid(new)
end

function onClickPlayerGrid(btn,state)
	if ( state == "down" ) then
		local selRow = exports.USGGUI:gridlistGetSelectedItem(panelGUI.playergrid)
		if ( selRow ) then
			local player = exports.USGGUI:gridlistGetItemData(panelGUI.playergrid,selRow,1)
			if ( isElement(player) ) then
				selectedPlayer = player
				exports.USGGUI:gridlistClear(panelGUI.playeractions.punishments)
				loadPlayerInfo(player)
				for _,tab in pairs(panelGUI) do
					if ( type(tab) == "table" and type(tab.onPlayerSelect) == "function" ) then
						tab.onPlayerSelect(selectedPlayer)
					end
				end
			end
		else
			for _,tab in pairs(panelGUI) do
				if ( type(tab) == "table" and type(tab.onPlayerClear) == "function" ) then
					tab.onPlayerClear()
				end
			end
			exports.USGGUI:gridlistClear(panelGUI.playeractions.punishments)
			exports.USGGUI:closeDialog(punishTextChangeDialog)
			exports.USGGUI:gridlistClear(panelGUI.playerinfo.weapons)
			selectedPlayer = false
			loadPlayerInfoTable({},"client")
			loadPlayerInfoTable({},"server")
		end
	end
end

function onPlayerInfoClick(btn,state)
	if ( state == "down" ) then
		for i=1, #playerInfoLabels do
			if ( playerInfoLabels[i].element == source ) then
				local valueString = exports.USGGUI:getText(source) -- include pre
				if ( btn == 1 ) then
					valueString = string.sub(valueString,#playerInfoLabels[i].pre+1) -- remove pre
				end
				setClipboard(valueString)
			end
		end
	end
end

function onPlayerUpdateNotes()
	if(selectedPlayer) then
		triggerServerEvent("USGstaff.updateNotes", localPlayer, selectedPlayer, exports.USGGUI:getText(panelGUI.playerinfo.staffnotes))
	end
end