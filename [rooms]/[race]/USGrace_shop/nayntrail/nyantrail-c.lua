------------------------------------------------------------------------------------
-- PROJECT: Towers Mania DD
-- VERSION: 1.0
-- DATE: July 2013
-- DEVELOPERS: JR10
-- RIGHTS: All rights reserved by developers
------------------------------------------------------------------------------------

nyanTrail = {}

function drawNyanTrail()
    for index, player in pairs(currentPlayers) do
        if (isElement(player) and nyanTable[player]) then
            if (isPedInVehicle(player)) then
                local vehicle = getPedOccupiedVehicle(player)
                if (isElement(vehicle)) then
                    if (not nyanTrail[player]) then
                        local x, y, z = getElementPosition(vehicle)
                        nyanTrail[player] = {
                            tick = getTickCount(),
                            positions = {},
                        }
                    end
                    if (getTickCount() - nyanTrail[player].tick >= 80) then
                        if (isElement(vehicle)) then
                            local velX, velY, velZ = getElementVelocity(vehicle)
                            if (((velX ^ 2 + velY ^ 2 + velZ ^ 2) ^ (0.5) * 180) ~= 0) then
                                local x, y, z = getElementPosition(vehicle)
                                table.insert(nyanTrail[player].positions, {x, y, z - 0.5})
                                if (#nyanTrail[player].positions > 40) then
                                    table.remove(nyanTrail[player].positions, 1)
                                end
                            end
                        end
                    end
                end
                local positions = nyanTrail[player].positions
                for index, position in pairs(positions) do
                    if (index > 1) then
                        local x, y, z = unpack(position)
                        dxDrawLine3D(x, y, z, positions[index - 1][1], positions[index - 1][2], positions[index - 1][3], tocolor(255, 0,0, 255), 9)
                        dxDrawLine3D(x, y, z+0.2, positions[index - 1][1], positions[index - 1][2], positions[index - 1][3]+0.2, tocolor(255, 174,0, 255), 9)
                        dxDrawLine3D(x, y, z+0.4, positions[index - 1][1], positions[index - 1][2], positions[index - 1][3]+0.4, tocolor(255, 246,0, 255), 9)
                        dxDrawLine3D(x, y, z+0.6, positions[index - 1][1], positions[index - 1][2], positions[index - 1][3]+0.6, tocolor(138, 255,0, 255), 9)
                        dxDrawLine3D(x, y, z+0.8, positions[index - 1][1], positions[index - 1][2], positions[index - 1][3]+0.8, tocolor(0, 144,255, 255), 9)
                        dxDrawLine3D(x, y, z+1, positions[index - 1][1], positions[index - 1][2], positions[index - 1][3]+1, tocolor(180, 0,255, 255), 9)
                    end
                end
            end
        end
    end
end
addEventHandler("onClientRender", root, drawNyanTrail)
addCommandHandler("tail",root,drawNyanTrail)

--[[ Save the points
linePointX = {}
linePointY = {}
linePointZ = {}
addEventHandler("onClientResourceStart", getRootElement(),
function()
    setTimer(
    function()
        if isPedInVehicle(getLocalPlayer()) then
            local vehicle = getPedOccupiedVehicle(getLocalPlayer())
            local velX, velY, velZ = getElementVelocity(vehicle)
            local theSpeed = (velX^2 + velY^2 + velZ^2)^(0.5) * 180
            if not (theSpeed == 0)then
                if vehicle then
                    local lX, lY, lZ = getElementPosition(vehicle)
                    if lX and lY and lZ then
                        table.insert(linePointX, lX)
                        table.insert(linePointY, lY)
                        table.insert(linePointZ, lZ-0.5)
                        if(#linePointX > 20)then
                            table.remove(linePointX, 1)
                            table.remove(linePointY, 1)
                            table.remove(linePointZ, 1)
                        end
                    end
                end
            end
        end
    end, 80, 0)
end)
-- Draw
addEventHandler("onClientRender", getRootElement(),
function()
    for i,d in ipairs(linePointX)do
        if i then
            if linePointX[i] and linePointX[i-1] and linePointX[i-2] and linePointX[i-3] and linePointX[i-4] then
                dxDrawLine3D(linePointX[i], linePointY[i], linePointZ[i], linePointX[i-1], linePointY[i-1], linePointZ[i-1], tocolor(255, 0,0, 255), 9)
                dxDrawLine3D(linePointX[i-1], linePointY[i-1], linePointZ[i-1], linePointX[i-2], linePointY[i-2], linePointZ[i-2], tocolor(255, 0,0, 255), 9)
                dxDrawLine3D(linePointX[i-3], linePointY[i-3], linePointZ[i-3], linePointX[i-4], linePointY[i-4], linePointZ[i-4], tocolor(255, 0,0, 255), 9)
                dxDrawLine3D(linePointX[i], linePointY[i], linePointZ[i]+0.2, linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.2, tocolor(255, 174,0, 255), 9)
                dxDrawLine3D(linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.2, linePointX[i-2], linePointY[i-2], linePointZ[i-2]+0.2, tocolor(255, 174,0, 255), 9)
                dxDrawLine3D(linePointX[i-3], linePointY[i-3], linePointZ[i-3]+0.2, linePointX[i-4], linePointY[i-4], linePointZ[i-4]+0.2, tocolor(255, 174,0, 255), 9)
                dxDrawLine3D(linePointX[i], linePointY[i], linePointZ[i]+0.4, linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.4, tocolor(255, 246,0, 255), 9)
                dxDrawLine3D(linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.4, linePointX[i-2], linePointY[i-2], linePointZ[i-2]+0.4, tocolor(255, 246,0, 255), 9)
                dxDrawLine3D(linePointX[i-3], linePointY[i-3], linePointZ[i-3]+0.4, linePointX[i-4], linePointY[i-4], linePointZ[i-4]+0.4, tocolor(255, 246,0, 255), 9)
                dxDrawLine3D(linePointX[i], linePointY[i], linePointZ[i]+0.6, linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.6, tocolor(138, 255,0, 255), 9)
                dxDrawLine3D(linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.6, linePointX[i-2], linePointY[i-2], linePointZ[i-2]+0.6, tocolor(138, 255,0, 255), 9)
                dxDrawLine3D(linePointX[i-3], linePointY[i-3], linePointZ[i-3]+0.6, linePointX[i-4], linePointY[i-4], linePointZ[i-4]+0.6, tocolor(138, 255,0, 255), 9)
                dxDrawLine3D(linePointX[i], linePointY[i], linePointZ[i]+0.8, linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.8, tocolor(0, 144,255, 255), 9)
                dxDrawLine3D(linePointX[i-1], linePointY[i-1], linePointZ[i-1]+0.8, linePointX[i-2], linePointY[i-2], linePointZ[i-2]+0.8, tocolor(0, 144,255, 255), 9)
                dxDrawLine3D(linePointX[i-3], linePointY[i-3], linePointZ[i-3]+0.8, linePointX[i-4], linePointY[i-4], linePointZ[i-4]+0.8, tocolor(0, 144,255, 255), 9)
                dxDrawLine3D(linePointX[i], linePointY[i], linePointZ[i]+1, linePointX[i-1], linePointY[i-1], linePointZ[i-1]+1, tocolor(180, 0,255, 255), 9)
                dxDrawLine3D(linePointX[i-1], linePointY[i-1], linePointZ[i-1]+1, linePointX[i-2], linePointY[i-2], linePointZ[i-2]+1, tocolor(180, 0,255, 255), 9)
                dxDrawLine3D(linePointX[i-3], linePointY[i-3], linePointZ[i-3]+1, linePointX[i-4], linePointY[i-4], linePointZ[i-4]+1, tocolor(180, 0,255, 255), 9)
            end
        end
    end
end)]]