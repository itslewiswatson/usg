
local weaponStats = { [22]=69, [23]=70, [24]=71, [25]=72, [26]=73, [27]=74, [28]=75, [29]=76, [32]=75, [30]=77, [31]=78, [34]=79, [33]=79 }

local playerStats = {}
local weapGUI = {}

local statCount = 0
for k,v in pairs(weaponStats) do statCount = statCount+1 end




function createweapGUI()
    local y = 0
     weapGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"Weapon Stats")
    refresh()
    for weaponID, progress in pairs(playerStats) do
         weapGUI.stat = exports.USGGUI:createLabel("center",y,298,35,false,getWeaponNameFromID(weaponID)..": "..(progress*100).."%", weapGUI.window)
   
        y = y +30
    end
end

function toggleweapGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(weapGUI.window )) then
        if(exports.USGGUI:getVisible(weapGUI.window )) then
         exports.USGGUI:setVisible(weapGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
            else
            showCursor(true)
            exports.USGGUI:setVisible(weapGUI.window , true)
            exports.USGblur:setBlurEnabled()
			open()
        end
    else
        createweapGUI()
        exports.USGblur:setBlurEnabled()
        showCursor(true)
		open()
    end 
end 
addEvent("UserPanel.App.WeaponApp",true)
addEventHandler("UserPanel.App.WeaponApp",root,toggleweapGUI)



function open()
    refresh()
end

function refresh()
    for weaponID, statID in pairs(weaponStats) do
        local progress = getPedStat(localPlayer, statID)/1000
        playerStats[weaponID] = progress
    end
end

function close()
    playerStats = {}
end