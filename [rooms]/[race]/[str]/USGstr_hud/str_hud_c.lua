local fadeStart
local fadeDuration = 5000
local fading = false

local wasInVehicle = false

local screenWidth, screenHeight = guiGetScreenSize()

function getProgressColor(progress)
    return exports.USG:convertHSVToRGB(progress*(1/3), 1, 1)
end

addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "str") then
            resetFade(2000)
            addEventHandler("onClientRender", root, renderHUD)
        end
        addEvent("onPlayerJoinRoom", true)
        addEvent("onPlayerExitRoom", true)
        addEventHandler("onPlayerJoinRoom", localPlayer, onJoinRoom)
        addEventHandler("onPlayerExitRoom", localPlayer, onExitRoom)
    end
)

function onJoinRoom(room)
    if(room == "str") then
        resetFade(5000)
        addEventHandler("onClientRender", root, renderHUD)
    end
end

function onExitRoom(prevRoom)
    if(prevRoom == "str") then
        removeEventHandler("onClientRender", root, renderHUD)
    end
end

function resetFade(duration)
    fading = true
    fadeDuration = duration or 1000
    fadeStart = getTickCount()
end

function renderHUD()
    local vehicle = getCameraTarget(localPlayer) -- allow spectators to see target's hud
    if(not vehicle or getElementType(vehicle) ~= "vehicle") then 
        vehicle = getPedOccupiedVehicle(localPlayer)
    end
    if(not vehicle) then return false end
    local alpha = 255
    if(fading) then
        alpha = (getTickCount()-fadeStart)/fadeDuration
        if(alpha >= 1) then fading = false end
        alpha = alpha * 255
    end
    local y = screenHeight - 40
    if(vehicle) then
        y = renderVehicleHUD(vehicle, alpha) or y   
    end
    local hudX = screenWidth - 180

    renderPlayers()
end

function renderVehicleHUD(vehicle, alpha)
    local hudX = screenWidth - 180
    -- draw seats
    local x = screenWidth - 25
    local y = screenHeight - 55
    -- health
    local healthProgress = math.max(0,(getElementHealth(vehicle)-250)/750)  
    if(healthProgress <= 0) then
        drawBorder(hudX, y, 175, 30, tocolor(255,0,0,alpha))
    else
        drawBorder(hudX, y, 175, 30, tocolor(255,255,255,alpha))
    end
    local r,g,b = getProgressColor(healthProgress)
    local healthText = string.format("Health: %00d%%", math.ceil(healthProgress*100))
    dxDrawRectangle(hudX+2,y+2, 172*healthProgress, 27, tocolor(r,g,b,alpha))
    drawText(healthText, hudX+4, y+1, 172, 28, tocolor(0,0,0,alpha), 1.25)
    drawText(healthText, hudX+2, y, 172, 28, tocolor(255,255,255,alpha), 1.25)
    y = y - 37
    -- nitro
    local nitroProgress = math.max(0,exports.USGrace_nitro:getVehicleNitro(vehicle))
    drawBorder(hudX, y, 175, 30, nitroProgress <= 0 and tocolor(255,0,0,alpha) or tocolor(255,255,255,alpha))
    local r,g,b = 10,175,255
    if(nitroProgress >= 1) then
        r,g,b = 0,140,255
    end
    local nitroText = string.format("Nitro: %00d%%", math.ceil(nitroProgress*100))
    dxDrawRectangle(hudX+2, y+2, 172*nitroProgress, 27, tocolor(r,g,b,alpha))
    drawText(nitroText, hudX+4, y+3, 172, 28, tocolor(0,0,0,alpha), 1.25)
    drawText(nitroText, hudX+2, y+2, 172, 28, tocolor(255,255,255,alpha), 1.25)
    y = y - 37
    -- rockets
    local rocketProgress = math.min(1, exports.USGstr_room:getRocketWaitProgress())
    if(rocketProgress < 1) then
        drawBorder(hudX, y, 175, 30, tocolor(255,0,0,alpha))
    else
        drawBorder(hudX, y, 175, 30, tocolor(255,255,255,alpha))
    end 
    local r,g,b = getProgressColor(rocketProgress)
    dxDrawRectangle(hudX+2, y+2, 172*rocketProgress, 27, tocolor(r,g,b,alpha))
    drawText("rocket", hudX+4, y+3, 172, 28, tocolor(0,0,0,alpha), 1.25)
    drawText("rocket", hudX+2, y+2, 172, 28, tocolor(255,255,255,alpha), 1.25)
    y = y - 37  
    -- money
    local components = { "money"}

    for _, component in ipairs( components ) do
        setPlayerHudComponentVisible( component, true )
    end
    -- speed
    local vx,vy,vz = getElementVelocity(vehicle)
    local speed = string.format("%00i KM/H", math.sqrt(vx^2+vy^2+vz^2)*100)
    dxDrawText(speed, hudX-78, y+38, hudX-5, screenHeight, tocolor(0,0,0,alpha), 1.25, "default", "right", "center")
    dxDrawText(speed, hudX-80, y+37, hudX-5, screenHeight, tocolor(255,255,255,alpha), 1.25, "default", "right", "center")
    return y
end

function renderPlayers()
    local x,y,z,_,_,_,_,_ = getCameraMatrix()
    for i, player in ipairs(getElementsByType("player", root, true)) do
        if(exports.USGrooms:getPlayerRoom(player) == "str" and isPedInVehicle(player)) then
            local vehicle = getPedOccupiedVehicle(player)
            local px,py,pz = getElementPosition(vehicle)
            local sx, sy = getScreenFromWorldPosition(px,py,pz+0.7)
            if(sx and sy) then
                local dist = getDistanceBetweenPoints3D(px,py,pz,x,y,z)
                if(dist < 50) then
                    local scale = 1-(dist/60)
                    local width = math.ceil(scale*250)
                    local height = math.ceil(scale*30)
                    dxDrawText(getPlayerName(player), sx-(width/2), sy-height-height,sx-(width/2)+width,sy-height,tocolor(255,255,255),1.5,"default","center","center")
                    local carHealth = math.max(0,(getElementHealth(vehicle)-250)/750)
                    dxDrawRectangle(sx-(width/2), sy-height,width,height,tocolor(0,0,0,120))
                    dxDrawRectangle(sx-(width/2)+2, sy-height+2,((width-4)*carHealth),0.4*(height-4),tocolor(150,0,0))
                    dxDrawRectangle(sx-(width/2)+2, sy-height+2+(0.4*(height-4)),((width-4)*carHealth),0.6*(height-4),tocolor(120,0,0))
                end
            end
        end
    end
end

function drawText(text, x,y,width,height,color, scale)
    dxDrawText(text, x, y, x+width, y+height, color, scale or 1, "default", "center", "center", true, false)
end

function drawBorder(x,y,width,height,color,lineWidth)
    if not lineWidth then lineWidth = 1.75 end
    local width = width - 1
    if not color then color = tocolor( 255,255,255,255) end
    dxDrawLine(x,y,x+width,y,color,lineWidth, post_gui)
    dxDrawLine(x,y,x,y+height,color,lineWidth, post_gui)
    dxDrawLine(x+width,y,x+width,y+height,color,lineWidth, post_gui)
    dxDrawLine(x,y+height,x+width,y+height,color,lineWidth, post_gui)
end