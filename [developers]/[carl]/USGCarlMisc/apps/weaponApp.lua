local weaponStats = { [22]=69, [23]=70, [24]=71, [25]=72, [26]=73, [27]=74, [28]=75, [29]=76, [32]=75, [30]=77, [31]=78, [34]=79, [33]=79 }

local playerStats = {}
local weapGUI = {}

addEventHandler("onClientResourceStart",resourceRoot,function()
	weapGUI.window = guiCreateWindow(0.8, 0.6, 0.2, 0.4, apps.weapons.name, true)
    guiWindowSetSizable(weapGUI.window, false)    
    refresh()
	guiSetVisible(weapGUI.window,false)
end
)

function showWeapGUI()
    guiSetVisible(weapGUI.window,true)
	showCursor(true)
	refresh()
end

function hideWeapGUI()
	guiSetVisible(weapGUI.window,false)
	showCursor(false)
end

addEvent("UserPanel.App.WeaponApp",true)
addEventHandler("UserPanel.App.WeaponApp",root,showWeapGUI)

bindKey("lalt","down",hideWeapGUI)

function refresh()
    for weaponID, statID in pairs(weaponStats) do
        local progress = getPedStat(localPlayer, statID)/1000
        playerStats[weaponID] = progress
    end
end