fileDelete("client.lua")
local locations = {
    --{x,y,z,rot}
    {1213.509765625, -1308.96875, 13.556906700134, 87.241027832031},--LS AS Hospital
    {1517.7939453125, -1656.39453125, 13.539175033569, 263.27215576172},--LSPD
    {1584.853515625, 1799.9892578125, 10.828001022339, 3.9798583984375},--LV hospital
    {1994.919921875, -1443.6484375, 13.566557884216, 173.54541015625},--LS Jefferson Hospital
    {1345.6220703125, -1045.0859375, 26.6484375, 305.97665405273},--LS LS entrance intersection
    {1969.9306640625, -2187.93359375, 13.546875, 85.235992431641},--LS Airport
    {2305.111328125, 2457.5751953125, 10.8203125, 181.2579498291},--LVPD
    {525.5302734375, -1281.072265625, 17.2421875, 290.99108886719},--Next to BR and Car Shop
    {1696.177734375, -1102.73046875, 24.078125, 2.9526062011719},--Mullohand Intersection
    {190.1767578125, -204.0068359375, 1.578125, 140.37719726562},-- BlueBerry
    {1269.3359375, 321.2626953125, 19.7578125, 331.28405761719},--Montgomery Hospital
    {-2168.1435546875, -2408.8828125, 30.625, 324.80749511719},--Angel Pine
    {-2595.1025390625, 613.5771484375, 14.453125, 182.54336547852},--SF Hospital
    {-1591.6630859375, 718.849609375, 9.458251953125, 13.653472900391},-- SFPD
    {1736.796875, 1546.666015625, 10.8203125, 105.27536010742},--LV Airport
    {-285.9541015625, 1055.1142578125, 19.7421875, 81.198455810547},--Fort Carson
    {405.708984375, 2540.2880859375, 16.546192169189, 173.96838378906},--Desert Airport
    {-1637.08984375, -531.9189453125, 11.5078125, 40.075988769531}, --SF Airport
    {-2325.916015625, 2379.19140625, 5.9296875, 18.289764404297},-- BaySide Marina 
}

local markers = {}

local PriceMultiplier = 1.5

local transportGUI = {}

local hour, min, weather


local sm = {}
sm.moov = 0
sm.object1,sm.object2 = nil,nil
 
local function removeCamHandler()
    if(sm.moov == 1)then
        sm.moov = 0
    end
end
 
local function camRender()
    if (sm.moov == 1) then
        local x1,y1,z1 = getElementPosition(sm.object1)
        local x2,y2,z2 = getElementPosition(sm.object2)
        setCameraMatrix(x1,y1,z1,x2,y2,z2)
    end
end
addEventHandler("onClientPreRender",root,camRender)
 
function smoothMoveCamera(x1,y1,z1,x1t,y1t,z1t,x2,y2,z2,x2t,y2t,z2t,time)
    if(sm.moov == 1)then return false end
    sm.object1 = createObject(1337,x1,y1,z1)
    sm.object2 = createObject(1337,x1t,y1t,z1t)
    setElementCollisionsEnabled ( sm.object1, false )
    setElementCollisionsEnabled ( sm.object2, false )
    setElementAlpha(sm.object1,0)
    setElementAlpha(sm.object2,0)
    setObjectScale(sm.object1,0.01)
    setObjectScale(sm.object2,0.01)
    moveObject(sm.object1,time,x2,y2,z2,0,0,0,"InOutQuad")
    moveObject(sm.object2,time,x2t,y2t,z2t,0,0,0,"InOutQuad")
    sm.moov = 1
    setTimer(removeCamHandler,time,1)
    setTimer(destroyElement,time,1,sm.object1)
    setTimer(destroyElement,time,1,sm.object2)
    return true
end

function createTransportGUI()
    transportGUI.window = exports.USGGUI:createWindow("center","center", 300, 430, false,"Transport")
    transportGUI.locationgrid = exports.USGGUI:createGridList("center","top",298,400,false,transportGUI.window)
    exports.USGGUI:gridlistAddColumn(transportGUI.locationgrid, "Locations", 0.8)
    exports.USGGUI:gridlistAddColumn(transportGUI.locationgrid, "Price", 0.2)
    transportGUI.playerwarp = exports.USGGUI:createButton("left","bottom",145,25,false,"Warp",transportGUI.window)
    transportGUI.closegui = exports.USGGUI:createButton("right","bottom",145,25,false,"Close",transportGUI.window)
        addEventHandler("onUSGGUISClick",  transportGUI.closegui, toggletransportGUI, false)
        addEventHandler("onUSGGUISClick", transportGUI.playerwarp, warpPlayer, false)
end

function transportfillLocationGrid()
    exports.USGGUI:gridlistClear(transportGUI.locationgrid)
    local px,py,pz = getElementPosition(source)
    for k, marker in pairs(markers) do
        local row = exports.USGGUI:gridlistAddRow(transportGUI.locationgrid)
        local x,y,z = getElementPosition(marker[1])
        local rotation = marker[2]
        local City = getZoneName ( x,y,z, true )
        local Zone = getZoneName ( x,y,z)
        local price = math.floor(getDistanceBetweenPoints3D ( px,py,pz,x,y,z ) * PriceMultiplier)
        local Data = {x,y,z + 1,rotation,price}
        exports.USGGUI:gridlistSetItemData(transportGUI.locationgrid, row, 1, Data)
        exports.USGGUI:gridlistSetItemText(transportGUI.locationgrid, row, 1, City.." - "..Zone)
        exports.USGGUI:gridlistSetItemText(transportGUI.locationgrid, row, 2, "$"..tostring(price))
    end
end

function transportRefresh()
    transportfillLocationGrid()
end


function toggletransportGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(transportGUI.window )) then
        if(exports.USGGUI:getVisible(transportGUI.window )) then
        exports.USGGUI:setVisible(transportGUI.window , false)
            showCursor(false)
            exports.USGblur:setBlurDisabled()
           
        else
            showCursor(true)
            exports.USGGUI:setVisible(transportGUI.window , true)
            exports.USGblur:setBlurEnabled()
            transportfillLocationGrid()
        end
    else
        createTransportGUI()
        showCursor(true)
        exports.USGblur:setBlurEnabled()
        transportfillLocationGrid()
    end 
end 


function onTransportMarkerHit(hitElement)
    if(hitElement == localPlayer and exports.USGrooms:getPlayerRoom(hitElement) == "cnr" ) then
        local _,_,z = getElementPosition(localPlayer)
        local _,_,mz = getElementPosition(source)
        if(math.abs(z-mz) <= 2) then -- height check
            if(exports.USGcnr_wanted:getPlayerWantedLevel(localPlayer) == 0 )then
                if(not isPedInVehicle(localPlayer)) then
                    toggletransportGUI()
                    transportfillLocationGrid()
                else
                    exports.USGmsg:msg("Please exit your vehicle before entering this marker.",255,0,0)
                end
            else exports.USGmsg:msg("You are wanted, You cannot use this marker",255,0,0)
            end
        end
    end
end

function onTransportMarkerLeave(hitElement)
    if(hitElement == localPlayer and exports.USGrooms:getPlayerRoom(hitElement) == "cnr" ) then
        if(transportGUI.window)then
            if(exports.USGGUI:getVisible(transportGUI.window ))then
            toggletransportGUI()
            end
        end
    end
end

for k,loc in ipairs(locations)do
    local element = createMarker ( loc[1], loc[2],loc[3] - 1,"cylinder", 1,255,204,0)
    if (isElement(element)) then
        addEventHandler ( "onClientMarkerHit", element, onTransportMarkerHit )
        addEventHandler ( "onClientMarkerLeave", element, onTransportMarkerLeave )
        element = {element , loc[4]}
        table.insert(markers,element)
    end
end

function cameraTranslate(destinationX, destinationY, destinationZ, destinationZRot)
    setElementFrozen(localPlayer, true)
    local maxZ = 290
    local px,py,pz = getElementPosition(localPlayer)
    local x,y,z,lx,ly,lz = getCameraMatrix()
    smoothMoveCamera(x, y, z, lx, ly, lz, px, py, pz + 15, px, py, pz, 2000)
    setTimer(
        function()
            x,y,z,lx,ly,lz = getCameraMatrix()
            smoothMoveCamera(x, y, z, lx, ly, lz, px, py, pz + 15 + 40, px, py, pz, 2000)
            setTimer(
                function()
                    x, y, z, lx, ly, lz = getCameraMatrix()
                    smoothMoveCamera(x, y, z, lx, ly, lz, px, py, maxZ, px, py, pz, 2000)
                    setTimer(function() 
                        weather = getWeather()
                        local h, m = getTime()
                        min = m
                        hour = h
                        setWeather(12)
                        setTime(12,0)
                    end, 2000, 1)
                    setTimer(
                        function()
                            x,y,z,lx,ly,lz = getCameraMatrix()
                            smoothMoveCamera ( x,y,z,lx,ly,lz, destinationX,destinationY,maxZ, destinationX,destinationY,0, 2000 )
                            setTimer(
                                function()
                                    x,y,z,lx,ly,lz = getCameraMatrix()
                                    smoothMoveCamera ( x,y,z,lx,ly,lz, destinationX,destinationY,destinationZ + 15 + 20, destinationX,destinationY,0, 2000 )
                                    setTimer(
                                        function()
                                            x,y,z,lx,ly,lz = getCameraMatrix()
                                            smoothMoveCamera ( x,y,z,lx,ly,lz, destinationX,destinationY,destinationZ + 15, destinationX,destinationY,0, 2000 )
                                            setTimer(
                                                function()
                                                    fadeCamera(false)
                                                    setTimer(function()
                                                        setWeather(weather)
                                                        setTime(hour, min)
                                                    end, 800, 1)
                                                    setTimer(
                                                        function()
                                                            fadeCamera(true)
                                                            setElementPosition(localPlayer, destinationX, destinationY, destinationZ, false)
                                                            setElementRotation(localPlayer, 0, 0, destinationZRot)
                                                            setCameraTarget(localPlayer)
                                                            setElementFrozen(localPlayer, false)
                                                        end, 1000, 1
                                                    )
                                                end, 2000, 1
                                            )
                                        end, 2000, 1
                                    )
                                end, 5000, 1
                            )
                        end, 5000, 1
                    )
                end, 2000, 1
            )
        end, 2000, 1
    )
end

function warpPlayer()
    local selected = exports.USGGUI:gridlistGetSelectedItem(transportGUI.locationgrid) 
    if (selected) then 
        local DestinationData = exports.USGGUI:gridlistGetItemData(transportGUI.locationgrid, selected, 1) -- x,y,z,rotation,price
        if (getPlayerMoney() >= DestinationData[5]) then
            triggerServerEvent ( "USGcnr.transport.onPlayerWarp", localPlayer,DestinationData[5])
            toggletransportGUI()
            cameraTranslate(DestinationData[1],DestinationData[2],DestinationData[3],DestinationData[4])
        else
            exports.USGmsg:msg("You do not have enough money!",255,0,0)
        end
    end
end

