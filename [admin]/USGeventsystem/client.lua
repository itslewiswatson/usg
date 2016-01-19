------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
--  RIGHTS:      All rights reserved by developer
--  FILE:        EventPanel/Event_c.lua
--  DEVELOPER:   Prime aka Kunal
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

eventCommands = {
"Freeze Event Players",
"Disable Weapon",
"Create Health Pickup",
"Create Armour Pickup",
"Destroy Pickups",
"Return Players",
"Freeze Event Vehicles",
"Lock Event Vehicles",
"Enable Vehicle Damage proof",
"Enable Vehicle Collision",
"Destroy Event Vehicles",
"Fix Event Vehicles",
}

playerControls = {
"Freeze Player",
"Unfreeze Player",
"Kick Player",
"Give Jetpack",
"Remove Jetpack"
}


---====================================================================================================================---

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		local widthEM, heightEM = guiGetScreenSize()
		eventWindow = guiCreateWindow(273, 167, 453, 361, "Event Panel", false)
		guiSetVisible( eventWindow, false)
        guiWindowSetSizable(eventWindow, false)
        guiSetAlpha(eventWindow, 1.00)	
        eventMainGrid = guiCreateGridList(10, 26, 232, 325, false, eventWindow)      
        warpLabel = guiCreateLabel(247, 30, 97, 21, "Wrap limit:", false, eventWindow)      
        warpEdit = guiCreateEdit(315, 25, 137, 26, "", false, eventWindow)
        freezeCheck = guiCreateCheckBox(248, 60, 204, 19, "Freeze on warp", true, false, eventWindow)       
        multipleCheck = guiCreateCheckBox(248, 79, 204, 19, "Allow multiple warping", false, false, eventWindow)    
        eventVehLabel = guiCreateLabel(248, 113, 137, 21, "Create Event Vehicles :", false, eventWindow)     
        eventVehCombo = guiCreateComboBox(248, 133, 197, 700, "", false, eventWindow)
        eventVehButton = guiCreateButton(249, 160, 93, 29, "Create Vehicle Marker", false, eventWindow)       
        eventDestButton = guiCreateButton(352, 160, 93, 29, "Destroy Vehicle Marker", false, eventWindow)     
		eventMainColumn = guiGridListAddColumn(eventMainGrid, "Commands", 0.9)		
        eventPlayers = guiCreateButton(249, 196, 195, 28, "Get players in Event", false, eventWindow)      
        eventCommand = guiCreateButton(249, 264, 195, 28, "No action selected", false, eventWindow)       
        startEvent = guiCreateButton(249, 229, 93, 29, "Start Event", false, eventWindow)       
        stopEvent = guiCreateButton(352, 229, 92, 29, "Stop Event", false, eventWindow)     
        eventClose = guiCreateButton(249, 323, 195, 28, "Close Panel", false, eventWindow)   
        wrapUsed = guiCreateLabel(249, 297, 97, 21, "Warp used: 0/0", false, eventWindow) 
        
        eventPlayer = guiCreateWindow(314, 130, 364, 464, "Event Players", false)
        guiWindowSetSizable(eventPlayer, false)
        guiSetAlpha(eventPlayer, 1.00)
		guiSetVisible( eventPlayer, false)	
        eventPlayerGrid = guiCreateGridList(9, 24, 165, 403, false, eventPlayer)
        eventPlayerColumn = guiGridListAddColumn(eventPlayerGrid, "Players in Event", 0.9)
        eventPlayerSearch = guiCreateEdit(9, 430, 93, 24, "", false, eventPlayer)
        eventPlayerConGrid = guiCreateGridList(189, 24, 165, 403, false, eventPlayer)
        eventPlayerCont = guiGridListAddColumn(eventPlayerConGrid, "Player controls", 0.9)
        eventPlayerCommand = guiCreateButton(190, 432, 164, 22, "No action selected", false, eventPlayer)  
        eventPlayerClose = guiCreateButton(104, 429, 70, 25, "Close", false, eventPlayer)  
		
		guiLabelSetColor(wrapUsed, 0, 234, 0)
		guiSetFont(eventPlayerClose, "default-bold-small")
		guiSetFont(eventPlayerCommand, "default-bold-small")
		guiSetFont(eventClose, "default-bold-small")
		guiSetFont(stopEvent, "default-bold-small")
		guiSetFont(startEvent, "default-bold-small")
		guiSetFont(eventCommand, "default-bold-small")
		guiSetFont(eventPlayers, "default-bold-small")
		guiSetFont(eventDestButton, "default-bold-small")
		guiSetFont(eventVehButton, "default-bold-small")
		guiSetFont(eventVehLabel, "default-bold-small")
		guiSetFont(multipleCheck, "default-bold-small")
		guiSetFont(freezeCheck, "default-bold-small")
		guiSetFont(warpLabel, "default-bold-small")
		guiSetFont(wrapUsed, "default-bold-small")
		guiSetProperty(eventVehButton, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(eventDestButton, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(eventPlayers, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(eventCommand, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(startEvent, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(stopEvent, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(eventClose, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(eventPlayerCommand, "NormalTextColour", "FFAAAAAA")
        guiSetProperty(eventPlayerClose, "NormalTextColour", "FFAAAAAA") 		
---====================================================================================================================---	
	
		for index, eventCommands in ipairs ( eventCommands ) do 
			guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, eventCommands, false, false )
		end
		
		for index, playerControls in ipairs ( playerControls ) do 
			guiGridListSetItemText ( eventPlayerConGrid, guiGridListAddRow ( eventPlayerConGrid ), eventPlayerCont, playerControls, false, false )
		end
---===================================================== LOADING VEHICLES TO COMOBO BOX ===============================================================---	
	
		local vehicleNames = {}
		for i = 400, 611 do
			if ( getVehicleNameFromModel ( i ) ~= "" ) then
				table.insert( vehicleNames, { model = i, name = getVehicleNameFromModel ( i ) } )
			end
		end
		table.sort( vehicleNames, function(a, b) return a.name < b.name end )
		for _,info in ipairs(vehicleNames) do
			guiComboBoxAddItem( eventVehCombo, info.name )
		end
---====================================================== EVENT HANDLERS ==============================================================---	
		
		addEventHandler("onClientGUIClick", eventClose, openEventPanel, false)
		addEventHandler("onClientGUIClick", eventPlayers, eventPlayerPanel, false)
		addEventHandler("onClientGUIClick", eventPlayerCommand, playerAction, false)
		addEventHandler("onClientGUIClick", eventPlayerClose, eventPlayerPanel, false)	
		addEventHandler("onClientGUIClick", eventCommand, eventAction, false)
		addEventHandler("onClientGUIClick", eventMainGrid, function() local theAction = guiGridListGetItemText(eventMainGrid, guiGridListGetSelectedItem(eventMainGrid), 1)  guiSetText(eventCommand, theAction )end, false)
		addEventHandler("onClientGUIClick", startEvent, startEventWarp, false)
		addEventHandler("onClientGUIClick", stopEvent, stopEventWarp, false)
		addEventHandler("onClientGUIClick", eventVehButton, createVeh, false)
		addEventHandler("onClientGUIClick", eventDestButton, destroyVehMarker, false)
		addEventHandler("onClientGUIClick", eventPlayerConGrid, function() local thePlrAction = guiGridListGetItemText(eventPlayerConGrid, guiGridListGetSelectedItem(eventPlayerConGrid), 1)  guiSetText( eventPlayerCommand, thePlrAction )end, false)
	end
)
---====================================================================================================================---	

addEvent("openEventPanel",true)
function openEventPanel(thePlayer)	
	if (guiGetVisible(eventWindow)) then  
		guiSetVisible(eventWindow, false)
		showCursor(false)
	else  
		guiSetVisible(eventWindow, true)
		showCursor(true)
	end
end
addEventHandler( "openEventPanel", root, openEventPanel )

function eventPlayerPanel()	
	if (guiGetVisible(eventPlayer)) then  
		guiSetVisible(eventPlayer, false)
	else  
		guiSetVisible(eventPlayer, true)
		guiBringToFront ( eventPlayer )
	end
end
---================================================ LOADING EVENT PLAYERS ====================================================================---

addEvent("loadEventPlayers",true)
function loadEventPlayers( eventPlayers )
	eventPlr = getPlayerName ( eventPlayers )
	guiGridListSetItemText ( eventPlayerGrid, guiGridListAddRow ( eventPlayerGrid ), eventPlayerColumn, eventPlr, false, false )
end
addEventHandler( "loadEventPlayers", root, loadEventPlayers )

addEvent("removeEventPlayers",true)
function removeEventPlayers( eventPlayer )
	guiGridListRemoveRow ( eventPlayerGrid, eventPlayer  )
end
addEventHandler( "removeEventPlayers", root, removeEventPlayers )
---================================================ EVENT ACTIONS ====================================================================---	

function eventAction()
	local theAction = guiGridListGetItemText(eventMainGrid, guiGridListGetSelectedItem(eventMainGrid), 1)
	if ( theAction == "Freeze Event Players" ) then
		triggerServerEvent("eventFeezePlayers",localPlayer)
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Unfreeze Event Players", false, false )
	elseif ( theAction == "Unfreeze Event Players" ) then
		triggerServerEvent("eventUnfreezePlayers",localPlayer)
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Freeze Event Players", false, false )
	elseif ( theAction == "Enable Weapon") then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Disable Weapon", false, false )
		enabledWep()
	elseif ( theAction == "Disable Weapon" ) then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Enable Weapon", false, false )
		disableWep()
	elseif ( theAction == "Freeze Event Vehicles" ) then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Unfreeze Event Vehicles", false, false )
		triggerServerEvent("eventFreezeVehicle",localPlayer)
	elseif ( theAction == "Unfreeze Event Vehicles" ) then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Freeze Event Vehicles", false, false )
		triggerServerEvent("eventUnfreezeVehicles",localPlayer)
	elseif ( theAction == "Lock Event Vehicles" ) then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Unlock Event Vehicles", false, false )
		triggerServerEvent("eventLockVehicles",localPlayer)
	elseif ( theAction == "Unlock Event Vehicles") then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Lock Event Vehicles", false, false )
		triggerServerEvent("eventUnlockVehicles",localPlayer)
	elseif ( theAction == "Enable Vehicle Damage proof" ) then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Disable Vehicle Damage proof", false, false )
		triggerServerEvent("eventEnableDamageProof",localPlayer)
	elseif ( theAction == "Disable Vehicle Damage proof" ) then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Enable Vehicle Damage proof", false, false )
		triggerServerEvent("eventDisableDamageProof",localPlayer)
	elseif ( theAction == "Fix Event Vehicles" ) then
		triggerServerEvent("eventFixVehicles",localPlayer)
	elseif ( theAction == "Enable Vehicle Collision") then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Disable Vehicle Collision", false, false )
		triggerServerEvent("eventEnableCollision",localPlayer)
	elseif ( theAction == "Disable Vehicle Collision") then
		guiGridListRemoveRow ( eventMainGrid, guiGridListGetSelectedItem (eventMainGrid, 1) )
		guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Enable Vehicle Collision", false, false )
		triggerServerEvent("eventDisableCollision",localPlayer)
	elseif ( theAction == "Destroy Event Vehicles" ) then
		triggerServerEvent("destroyVehicles",localPlayer)
	elseif ( theAction == "Create Health Pickup" ) then
		triggerServerEvent("createHealth",localPlayer)
	elseif ( theAction == "Create Armour Pickup" ) then
		triggerServerEvent("createArmourPickup",localPlayer)
	elseif ( theAction == "Destroy Pickups" ) then
		triggerServerEvent("destroyPickups",localPlayer)
	elseif ( theAction =="Return Players" ) then
		triggerServerEvent("returnPlayers",localPlayer)
	end
end

function playerAction()
	local thePlrAction = guiGridListGetItemText( eventPlayerConGrid, guiGridListGetSelectedItem(eventPlayerConGrid), 1 )
	local eventSelectedPlr1 = guiGridListGetItemText(eventPlayerGrid, guiGridListGetSelectedItem(eventPlayerGrid), 1)
	local eventSelectedPlr = getPlayerFromName( eventSelectedPlr1 )
	if ( thePlrAction == "Freeze Player" ) then 
		triggerServerEvent("eventFeezePlayers", localPlayer, eventSelectedPlr)
	elseif ( thePlrAction == "Unfreeze Player" ) then
		triggerServerEvent("eventUnfreezePlayers", localPlayer, eventSelectedPlr)
	elseif ( thePlrAction == "Kick Player" ) then 
		triggerServerEvent("eventKickPlayer", localPlayer, eventSelectedPlr)
		guiGridListRemoveRow ( eventPlayerGrid, eventSelectedPlr1  )
	elseif ( thePlrAction == "Give Jetpack" ) then   
		triggerServerEvent("eventGiveJetpack", localPlayer, eventSelectedPlr)
	elseif ( thePlrAction == "Remove Jetpack" ) then
		triggerServerEvent("eventRemoveJetpack", localPlayer, eventSelectedPlr)
	end
end
---============================================== EVENT WARP ======================================================================---

function startEventWarp()
	local warpLimit = guiGetText( warpEdit )
	local freezeOnWarp = guiCheckBoxGetSelected( freezeCheck )
	local multipleWarps = guiCheckBoxGetSelected( multipleCheck )
	guiSetText( wrapUsed, "Warp used: 0/"..warpLimit )
	if (warpLimit ~= "" ) then
		triggerServerEvent("Prime.createEvent", localPlayer, warpLimit, freezeOnWarp, multipleWarps)
	end	
end

function stopEventWarp()
	guiSetText( wrapUsed, "Warp used: 0/0" )
	triggerServerEvent("Prime.stopEvent", localPlayer)
end

addEvent( "eventWarpUsed", true)
function eventWarpUsed( plrWraped, warpLimit )
	guiSetText( wrapUsed, "Warp used: "..plrWraped.."/"..warpLimit )
end
addEventHandler("eventWarpUsed", root, eventWarpUsed)

addEvent("onFreezeOnWarp", true)
function onFreezeOnWarp()
	guiGridListRemoveRow ( eventMainGrid, "Freeze Event Players" )
	guiGridListSetItemText ( eventMainGrid, guiGridListAddRow ( eventMainGrid ), eventMainColumn, "Unfreeze Event Players", false, false )
end
addEventHandler("onFreezeOnWarp", root, onFreezeOnWarp)
---================================================== EVENT PLAYERS WEAPON SWITCHING ==================================================================---

function weaponSwitch()
	triggerServerEvent("weaponSwitch",localPlayer)
end

function disableWep()
	addEventHandler("onClientPlayerWeaponSwitch", root, weaponSwitch)
end
function enabledWep()
	removeEventHandler("onClientPlayerWeaponSwitch", root, weaponSwitch)
end
---================================================  EVENT VEHICLES ====================================================================---

function createVeh()
	eventVeh = guiComboBoxGetItemText( eventVehCombo, guiComboBoxGetSelected( eventVehCombo ))
	triggerServerEvent("createVeh", localPlayer, eventVeh)
end

function destroyVehMarker()
	triggerServerEvent("destroyVehicleMarkers",localPlayer)
end
---=================================================  EVENT VEHICLE DAMAGE ===================================================================---

addEvent( "eventEnableDamageProof", true)
function eventEnableDamageProof(eventVeh)
	setVehicleDamageProof(eventVeh, true)
end
addEventHandler("eventEnableDamageProof", root, eventEnableDamageProof)

addEvent( "eventDisableDamageProof", true)
function eventDisableDamageProof(eventVeh)
	setVehicleDamageProof(eventVeh, false)
end
addEventHandler("eventDisableDamageProof", root, eventDisableDamageProof)

---=================================================== EVENT VEHICLE COLISION=================================================================---

addEvent("enableCollisions", true)
function enableCollisions(eventVeh)
	for i, veh in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith( veh, eventVeh, false)		
	end
end
addEventHandler("enableCollisions", root, enableCollisions)

addEvent("disableCollisions", true)
function disableCollisions(eventVeh)
	for i, veh in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith(veh, eventVeh, true)
	end
end
addEventHandler("disableCollisions", root, disableCollisions)
---====================================================================================================================---