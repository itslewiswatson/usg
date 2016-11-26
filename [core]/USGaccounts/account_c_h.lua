fileDelete("account_c_h.lua")
local rX,rY = guiGetScreenSize()
local startX,startY = 90,90
local scaleMain = 2
local scaleGeneral = 1.5
local scaleHeight = 150
local banData
local y = (screenH-400)/2

addEvent("returnPlayerIsBanned",true)
addEventHandler("returnPlayerIsBanned",root,
function(data)
    if (data) then
        banData = data
        banData.endtime = exports.USG:getDateTimeString(data.endtimestamp)
        addEventHandler("onClientRender",root,drawBanScreen)
    end
end)

function drawBanScreen()
    dxDrawText("This "..banData.type.." is banned.\n",0,y,screenW,y+100,tocolor(255,0,0),3.5,"default-bold","center","center")
    dxDrawText("Reason: "..banData.reason,0,y+100,screenW,y+300,tocolor(255,0,0),2.5,"default-bold","center","center")
    dxDrawText("Expires on: "..banData.endtime,0,y+300,screenW,y+400,tocolor(255,0,0),2.5,"default-bold","center","center")
end

--- mods
local modX,modY = (screenW-600)/2,(screenH-400)/2
local drawingModInfo = false
local modInfo = {}
local modInfoGUI = {}

addEvent("USGaccounts.onShowModInfo",true)
addEventHandler("USGaccounts.onShowModInfo",root,
    function (newModInfo)
        hideLoginScreen(true) -- hide login screen and let it know logging in failed ( to keep hud hidden )
        modInfo = newModInfo
        if not drawingModInfo then
            addEventHandler("onClientRender",root,drawModInfo)
            drawingModInfo = true
            modInfoGUI.mainlabel = exports.USGgui:createLabel(modX,modY,600,20,false,"You have illegal mods installed, please restore the following mods:",false,tocolor(255,0,0))
            modInfoGUI.grid = exports.USGgui:createGridList(modX,modY+20,600,400-40,false,false)
                exports.USGgui:gridlistAddColumn(modInfoGUI.grid, "Name",1)
            modInfoGUI.infolabel = exports.USGgui:createLabel(modX,modY+400-20,600,20,false,
                "Lost your backup? Download a backup at https://USGmta.net/downloads/GTA/gta3.rar",false, tocolor(255,255,0))
        end
        loadMods()
    end
)

function loadMods()
    if ( isElement ( modInfoGUI.grid ) and modInfo ) then
        exports.USGgui:gridlistClear(modInfoGUI.grid)
        for name, _ in pairs(modInfo) do
            local row = exports.USGgui:gridlistAddRow(modInfoGUI.grid)
            exports.USGgui:gridlistSetItemText(modInfoGUI.grid,row,1,name)
        end
    end
end


function drawModInfo()
    dxDrawRectangle(modX,modY,600,400,tocolor(0,0,0,200))
end