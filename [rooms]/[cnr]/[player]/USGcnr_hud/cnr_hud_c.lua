local enabled = false

local screenWidth, screenHeight = guiGetScreenSize()

local WANTED_X, WANTED_Y = math.floor(0.78*screenWidth),math.floor(0.21*screenHeight)
local WANTED_END_X, WANTED_END_Y = math.floor(0.92*screenWidth), math.floor(0.22*screenHeight)+70

local WANTED_STAR_X, WANTED_STAR_Y = math.floor(0.93*screenWidth), math.floor(0.225*screenHeight)


local fadeStart
local fadeDuration = 5000
local fading = false
--local font = dxCreateFont("font.ttf",12,true)

local wasInVehicle = false

function getProgressColor(progress)
    return exports.USG:convertHSVToRGB(progress*(1/3), 1, 1)
end

function isResourceReady(name)
    return getResourceFromName(name) and getResourceState(getResourceFromName(name)) == "running"
end

addEventHandler("onClientResourceStart", resourceRoot,
    function ()
        if(isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr") then
            resetFade(2000)
            addEventHandler("onClientRender", root, renderHUD)
            showPlayerHudComponent("wanted", false)
        end
        addEvent("onPlayerJoinRoom", true)
        addEvent("onPlayerExitRoom", true)
        addEventHandler("onPlayerJoinRoom", localPlayer, onJoinRoom)
        addEventHandler("onPlayerExitRoom", localPlayer, onExitRoom)
    end
)

addEventHandler("onClientResourceStop", resourceRoot,
    function ()
        if(isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr") then
            showPlayerHudComponent("wanted", true)
        end
    end
)

function onJoinRoom(room)
    if(room == "cnr") then
        resetFade(5000)
        addEventHandler("onClientRender", root, renderHUD)
        showPlayerHudComponent("wanted", false)
    end
end

function onExitRoom(prevRoom)
    if(prevRoom == "cnr") then
        removeEventHandler("onClientRender", root, renderHUD)
        showPlayerHudComponent("wanted", true)
    end
end

local cities = { LV = "Las Venturas", LS = "Los Santos", SF = "San Fierro" }

function resetFade(duration)
    fading = true
    fadeDuration = duration or 1000
    fadeStart = getTickCount()
end

function renderHUD()
    if(isPlayerMapVisible()) then return end
    local player = getCameraTarget(localPlayer) -- allow spectators to see target's hud
    if(not player or getElementType(player) ~= "player") then player = localPlayer end
    local inVehicle = isPedInVehicle(player)
    if(inVehicle and not wasInVehicle) then
        wasInVehicle = true
        resetFade()
    elseif(not inVehicle and wasInVehicle) then
        wasInVehicle = false
        resetFade()
    end
    local alpha = 255
    if(fading) then
        alpha = (getTickCount()-fadeStart)/fadeDuration
        if(alpha >= 1) then fading = false end
        alpha = alpha * 255
    end
    local y = screenHeight - 40
    if(inVehicle) then
        y = renderVehicleHUD(player, alpha) or y    
    end
    local hudX = screenWidth - 180
    -- position / zone
    y = y - 5
    drawBorder(hudX, y, 175, 30, tocolor(255,255,255,alpha))
    dxDrawRectangle(hudX+2,y+2,172,27,tocolor(0,0,0,0.4*alpha))
    local px,py,pz = getElementPosition(player)
    local zone = getElementInterior(player) == 0 and getZoneName(px,py,pz, false) or "An interior"
    local city = isResourceReady("USG") and exports.USG:getPlayerChatZone(player) or "N/A"
    if(zone == "Las Venturas" or zone == "Los Santos" or zone == "San Fierro") then zone = false end
    dxDrawText(zone ~= false and (zone.." in "..city) or cities[city], hudX+2, y, hudX+172, y+30,tocolor(255,255,255,alpha),1,"default","center","center",false,true)
    y = y - 35
    -- wanted level
    local wantedlvl = isResourceReady("USGcnr_wanted") and exports.USGcnr_wanted:getPlayerWantedLevel(localPlayer) or 0
    if(wantedlvl > 0) then  
        dxSetAspectRatioAdjustmentEnabled(true)
        --dxDrawText(wantedlvl, WANTED_X, WANTED_Y, WANTED_END_X, WANTED_END_Y, tocolor(180,0,0),2,"pricedown","right","top")  -- Text will be drawn just below HUD money, with any aspect ratio
        --dxDrawImage(WANTED_STAR_X, WANTED_STAR_Y, 32, 32,"wanted-star.png")

        --dxDrawImage(1479, 210, 32, 32, ":USGGUI/skins/abc/window_title_corner.png", 0, 0, 0, tocolor(255, 255, 255, 255), false)
        --dxDrawText("", 1420, 210, 1479, 242, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, false, false, false)

        dxDrawText(wantedlvl, screenWidth * 0.8875, screenHeight * 0.2333, screenWidth * 0.9244, screenHeight * 0.2689, tocolor(180,0,0),2,"pricedown","right","top")
        dxDrawImage(screenWidth * 0.9244, screenHeight * 0.2333, 32, 32, "wanted-star.png")
        dxSetAspectRatioAdjustmentEnabled(false)
    end
    -- 
    --drawPlayers() -- disabled in favor of default mta nametag
    -- when enabling, make sure font is also re-enabled in meta.xml
end
 
function renderVehicleHUD(player, alpha)
    local hudX = screenWidth - 180
    local vehicle = getPedOccupiedVehicle(player)
    if(not vehicle) then return false end
    local driver = getVehicleController(vehicle) == player
    -- draw seats
    local x = screenWidth - 25
    local y = screenHeight - 35
    for seat=math.min(6,getVehicleMaxPassengers(vehicle)),0,-1 do
        local occupant = getVehicleOccupant(vehicle, seat)
        drawBorder(x,y,20,20, tocolor(255,255,255,alpha))
        if(occupant) then
            local r,g,b = 255,255,255
            if(occupant == player) then
                r,g,b = 120,255,120
            end
            dxDrawRectangle(x+2,y+2,17,17,tocolor(r,g,b,alpha))
        end
        x = x - 25
    end
    y = y - 40
    -- health
    if(enabled)then
    local healthProgress = math.max(0,(getElementHealth(vehicle)-250)/750)  
    if(healthProgress <= 0) then
        drawBorder(hudX, y, 175, 30, tocolor(255,0,0,alpha))
    else
        drawBorder(hudX, y, 175, 30, tocolor(255,255,255,alpha))
    end
    local r,g,b = getProgressColor(healthProgress)
    local text = string.format("Health: %00d%%", math.ceil(healthProgress*100))
    dxDrawRectangle(hudX+2,y+2, 172*healthProgress, 27, tocolor(r,g,b,alpha))
    drawText(text, hudX+4, y+1, 172, 28, tocolor(0,0,0,alpha), 1.25)
    drawText(text, hudX+2, y, 172, 28, tocolor(255,255,255,alpha), 1.25)
    end
    y = y - 37
    -- fuel
    local fuelProgress = math.max(0,(getVehicleFuel(vehicle))/100)
    if(fuelProgress <= 0) then
        drawBorder(hudX, y, 175, 30, tocolor(255,0,0,alpha))
    else
        drawBorder(hudX, y, 175, 30, tocolor(255,255,255,alpha))
    end
    local r,g,b = getProgressColor(fuelProgress)
    local text = string.format("Fuel: %00d%%", math.ceil(fuelProgress*100))
    dxDrawRectangle(hudX+2, y+2, 172*fuelProgress, 27, tocolor(r,g,b,alpha))
    drawText(text, hudX+4, y+1, 172, 28, tocolor(0,0,0,alpha), 1.25)
    drawText(text, hudX+2, y, 172, 28, tocolor(255,255,255,alpha), 1.25)
    y = y - 37
    -- speed
    if(enabled)then
    local vx,vy,vz = getElementVelocity(vehicle)
    local speed = string.format("%00i KM/H", math.sqrt(vx^2+vy^2+vz^2)*155)
    dxDrawText(speed, hudX-78, y+38, hudX-5, screenHeight, tocolor(0,0,0,alpha), 1.25, "default", "right", "center")
    dxDrawText(speed, hudX-80, y+37, hudX-5, screenHeight, tocolor(255,255,255,alpha), 1.25, "default", "right", "center")
    end
    return y
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

function getVehicleFuel(vehicle)
    return getElementData(vehicle, "vehicleFuel") or 100
end

-- draw players
function drawPlayers()
    local myDim, myInt = getElementDimension(localPlayer), getElementInterior(localPlayer)
    local x,y,z,_,_,_,_,_ = getCameraMatrix()
    for i, player in ipairs(getElementsByType("player", root, true)) do
    if(player ~= localPlayer and exports.USGrooms:getPlayerRoom(player) == "cnr") or (player ~= localPlayer and exports.USGrooms:getPlayerRoom(player) == "tct") then
            local dim, int = getElementDimension(player), getElementInterior(player)
            if(dim == myDim and int == myInt) then
                local px,py,pz = getElementPosition(player) --getPedBonePosition(player, 8)
                local dist = getDistanceBetweenPoints3D(x,y,z,px,py,pz)
                if(dist <= 60) then
                    local sx, sy = getScreenFromWorldPosition(px,py,pz)
                    if(sx and sy and isLineOfSightClear(x,y,z,px,py,pz, true, false, false)) then
                        local scale = 1-(dist/60)
                        local width = math.ceil(scale*100)
                        local height = math.ceil(scale*40)
                        if(width > 10) then
                            local y = sy
                            -- health & armor
                            local armor = getPedArmor(player)/100
                            local maxHealth = exports.USG:getPedMaxHealth(player)
                            local hp = math.min(1,math.max(0,getElementHealth(player)/maxHealth))
                            local hpHeight = 0.3*height
                            dxDrawRectangle(sx-(width/2),y-hpHeight,width,hpHeight,tocolor(0,0,0,230))
                            dxDrawRectangle(sx-(width/2),y-hpHeight, armor*width,hpHeight, tocolor(230,230,230,210))
                            dxDrawRectangle(2+sx-(width/2),2+y-hpHeight,width-4,hpHeight-4,tocolor(0,0,0,255))
                            dxDrawRectangle(sx-(width/2)+2,y+2-hpHeight,hp*(width-4),hpHeight-4,tocolor(200,0,0,255))
                            y = y-hpHeight-2
                            -- name and wanted level
                            local pr,pg,pb = 0,0,0
                            local pTeam = getPlayerTeam(player)
                            if(pTeam) then
                                pr,pg,pb = getTeamColor(pTeam)
                            end
                            local lvl = isResourceReady("USGcnr_wanted") and exports.USGcnr_wanted:getPlayerWantedLevel(player) or 0
                            dxDrawText(getPlayerName(player).." ["..lvl.."]", sx-(width/2),y-20,sx+(width/2),y, tocolor(pr,pg,pb), math.floor((1-(dist/120))*1.25*100)/100, "clear", "center", "center")
                            y = y-22
                        end
                    end
                end
            end
        end
    end
end

addCommandHandler("togglespeedometer",function()
enabled = not enabled
end)