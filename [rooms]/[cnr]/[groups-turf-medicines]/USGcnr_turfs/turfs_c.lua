fileDelete("turfs_c.lua")
local screenWidth, screenHeight = guiGetScreenSize()

local currentTurfData = false
addEvent("USGcnr_turfs.recieveTurfData", true)
function recieveTurfData(data)
    currentTurfData = data
end
addEventHandler("USGcnr_turfs.recieveTurfData", localPlayer, recieveTurfData)

local turfStartY = screenHeight-200-85
local turfWidth = 220
if(screenWidth > 1300) then
    turfWidth = math.floor((screenWidth/1200)*turfWidth)
end

local turfHalf = math.floor(turfWidth/2)
local turfStartX = screenWidth-turfWidth-5
local turfBarWidth = turfWidth-10
local turfBarX = turfStartX+5
local bar1X,bar2X = math.floor(0.25*turfBarWidth), math.floor(0.75*turfBarWidth)

function renderTurfInterface()
    if(currentTurfData and exports.USGrooms:getPlayerRoom() == "cnr") then
        dxDrawRectangle(turfStartX,turfStartY,turfWidth,84,tocolor(0,0,0,130))  
        local rightText = "Unoccupied"
        if(currentTurfData.rightTeam) then
            rightText = currentTurfData.rightTeam.name
        end
        if(currentTurfData.rightTeam) then
            dxDrawText(currentTurfData.rightTeam.alliance and "the alliance" or "the group", turfStartX+turfHalf,turfStartY,screenWidth-6,230,tocolor(255,255,255), 1, "default", "right", "top", false,false)
        end
        dxDrawText(rightText, turfStartX+turfHalf,turfStartY+17, turfStartX+turfWidth-1, 255,tocolor(255,255,255), 1,"default-bold","right","top",false,true)
        if(currentTurfData.rightTeam) then
            for i=1,currentTurfData.rightTeam.count or 0 do
                dxDrawRectangle(screenWidth-12-((i-1)*7),turfStartY+71,5,10,tocolor(0,255,0))
            end
        end
        if(currentTurfData.leftTeam) then
            dxDrawText(currentTurfData.leftTeam.alliance and "the alliance" or "the group", turfStartX+1,turfStartY,turfStartX+turfHalf,230,tocolor(255,255,255), 1, "default", "left", "top", false,false)
            dxDrawText(currentTurfData.leftTeam.name or "Unoccupied", turfStartX+1,turfStartY+17, turfStartX+turfHalf, 255,tocolor(255,255,255), 1,"default-bold","left","top",false,true)
            for i=1,currentTurfData.leftTeam.count or 0 do
                dxDrawRectangle(turfStartX+10+((i-1)*7),turfStartY+71,5,10,tocolor(255,0,0))
            end
        end
        local influence = currentTurfData.influence
        influence = influence + 100
        local progress = influence/200
        dxDrawRectangle(turfBarX, turfStartY+56, turfBarWidth, 12, tocolor(0,0,0,160))
        local barR, barG, barB = 255,0,0
        if(influence > 150) then
            barR, barG, barB = 0,255,0
        elseif(influence > 50 and influence <= 150) then
            barR, barG, barB = 110,110,110
        end
        dxDrawLine(turfBarX+bar1X, turfStartY+52, turfBarX+bar1X, turfStartY+72, tocolor(90,90,90,255))
        dxDrawLine(turfBarX+bar2X, turfStartY+52, turfBarX+bar2X, turfStartY+72, tocolor(90,90,90,255))
        dxDrawRectangle(turfBarX+2, turfStartY+58, (progress*(turfBarWidth-4)), 8, tocolor(barR, barG, barB,240))
        
        dxDrawText(string.format("%02.0f",progress*100).."%", turfStartX,turfStartY+67, screenWidth, 290,tocolor(255,255,255), 1,"default","center","top",false,true)
    end
end
addEventHandler("onClientRender",root,renderTurfInterface)