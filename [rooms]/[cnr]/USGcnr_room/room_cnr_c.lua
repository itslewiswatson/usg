local registeredGUI = {}

function createRegisteredGUI()
    exports.USGGUI:setDefaultTextAlignment("center","center")
    registeredGUI.window = exports.USGGUI:createWindow("center","center", 800, 410, false,"Welcome to USG")
    exports.USGGUI:setProperty(registeredGUI.window, "movable", false)
	registeredGUI.logo = exports.USGGUI:createImage("center","top",650,250,false,":USGcnr_room/logo.png",registeredGUI.window)
        exports.USGGUI:createLabel("center",250,200,50,false,"You are on your way to San Andreas to start a new life! Please choose where you want to land:",registeredGUI.window)
    registeredGUI.ls = exports.USGGUI:createButton("right",350,200,50,false," Los Santos  ",registeredGUI.window,0,0,0,0)
    registeredGUI.sf = exports.USGGUI:createButton("center",350,200,50,false," San Fierro ",registeredGUI.window,0,0,0,0)
    registeredGUI.lv = exports.USGGUI:createButton("left",350,200,50,false,"Las Venturas ",registeredGUI.window,0,0,0,0)
	addEventHandler("onUSGGUISClick",  registeredGUI.ls, function()
	triggerServerEvent ( "onPlayerRegisterSelectSpawnLocation", localPlayer, 1729.9296875, -2239.373046875, 13.541284561157,190)
	toggleregisteredGUI()
	end, false)
	addEventHandler("onUSGGUISClick",  registeredGUI.sf, function()
	triggerServerEvent ( "onPlayerRegisterSelectSpawnLocation", localPlayer, -1421.9375, -287.876953125, 14.1484375,145)
	toggleregisteredGUI()
	end, false)
	addEventHandler("onUSGGUISClick",  registeredGUI.lv, function()
	triggerServerEvent ( "onPlayerRegisterSelectSpawnLocation", localPlayer, 1674.466796875, 1447.9228515625, 10.79025554657,270)
	toggleregisteredGUI()
	end, false)
end



function toggleregisteredGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(registeredGUI.window )) then
        if(exports.USGGUI:getVisible(registeredGUI.window )) then
         exports.USGGUI:setVisible(registeredGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            else
            showCursor(true)
            exports.USGGUI:setVisible(registeredGUI.window , true)
            exports.USGblur:setBlurEnabled()
        end
    else
        createRegisteredGUI()
        exports.USGblur:setBlurEnabled()
        showCursor(true)
    end 
end 
addEvent("onPlayerRegisterSelectSpawn", true)
addEventHandler("onPlayerRegisterSelectSpawn",localPlayer ,toggleregisteredGUI)


