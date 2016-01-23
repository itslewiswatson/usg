
local services = {
    {name="Police",id="police"},
    {name="Medic",id="medic"},
    {name="Mechanic",id="mechanic"},
}
    
local callGUI = {}

addEventHandler("onClientResourceStart", resourceRoot,
    function()
		callGUI.window = guiCreateWindow(0.77, 0.26, 0.21, 0.50, apps.call.name, true)
        guiWindowSetSizable(callGUI.window, false)

        callGUI.gridlist = guiCreateGridList(0.03, 0.05, 0.94, 0.84, true, callGUI.window)
        guiGridListAddColumn(callGUI.gridlist, "Service", 0.9)
        callGUI.button = guiCreateButton(0.27, 0.91, 0.45, 0.07, "Call", true, callGUI.window)
        guiSetProperty(callGUI.button, "NormalTextColour", "FFAAAAAA")    
		
		for i, service in ipairs(services) do
            local row = guiGridListAddRow ( callGUI.gridlist )
            guiGridListSetItemText(callGUI.gridlist, row, 1, service.name,false,false)
            guiGridListSetItemData(callGUI.gridlist, row, 1, i)
		end
		
		addEventHandler("onClientGUIClick",  callGUI.button, phoneCall , false)
		
		guiSetVisible ( callGUI.window, false )
    end
)

local function showCallGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
	if(guiGetVisible(callGUI.window) == false)then
		guiSetInputMode("no_binds_when_editing")
		guiSetVisible ( callGUI.window, true )
	end
end

addEvent(apps.call.event,true)
addEventHandler(apps.call.event,root,showCallGUI)

local function hideCallGUI()
	if(guiGetVisible(callGUI.window) == true)then
		guiSetVisible (callGUI.window, false )
		showCursor(false)
	end
end

bindKey("lctrl","down",hideCallGUI)

function phoneCall()
    local selected = guiGridListGetSelectedItem(callGUI.gridlist)
    if(selected) then
        local id = guiGridListGetItemData(callGUI.gridlist, selected, 1)
        triggerServerEvent("testing.callServices", localPlayer, services[id].id, services[id].name)
    else
        exports.USGmsg:msg("You did not select a service from the list.", 255, 0, 0)
    end
end