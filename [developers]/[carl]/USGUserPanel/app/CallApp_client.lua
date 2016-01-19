
local services = {
    {name="Police",id="police"},
    {name="Medic",id="medic"},
    {name="Mechanic",id="mechanic"},
    }
    
local phoneGUI = {}


function createPhoneGUI()
    phoneGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"Phone Call")
    phoneGUI.grid = exports.USGGUI:createGridList("center","top",298,400,false,phoneGUI.window)
    exports.USGGUI:gridlistAddColumn(phoneGUI.grid, "Service", 1.0)
    phoneGUI.call = exports.USGGUI:createButton("center","bottom",110,25,false,"Call",phoneGUI.window)
    addEventHandler("onUSGGUISClick",  phoneGUI.call, phoneCall , false)
    for i, service in ipairs(services) do
            local row = exports.USGGUI:gridlistAddRow(phoneGUI.grid)
            exports.USGGUI:gridlistSetItemText(phoneGUI.grid, row, 1, service.name)
            exports.USGGUI:gridlistSetItemData(phoneGUI.grid, row, 1, i)
    end
end

function togglephoneGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(phoneGUI.window )) then
        if(exports.USGGUI:getVisible(phoneGUI.window )) then
        exports.USGGUI:setVisible(phoneGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            playerStats = {}
        else
            showCursor(true)
            exports.USGGUI:setVisible(phoneGUI.window , true)
            exports.USGblur:setBlurEnabled()
        end
    else
        createPhoneGUI()
        showCursor(true)
        exports.USGblur:setBlurEnabled()
    end 
end 
addEvent("UserPanel.App.CallApp",true)
addEventHandler("UserPanel.App.CallApp",root,togglephoneGUI)

function phoneCall()
    local selected = exports.USGGUI:gridlistGetSelectedItem(phoneGUI.grid)
    if(selected) then
        local id = exports.USGGUI:gridlistGetItemData(phoneGUI.grid, selected, 1)
        triggerServerEvent("testing.callServices", localPlayer, services[id].id, services[id].name)
    else
        exports.USGmsg:msg("You did not select a service from the list.", 255, 0, 0)
    end
end