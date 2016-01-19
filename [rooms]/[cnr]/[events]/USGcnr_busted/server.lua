local crimvehicle = {
    {402,-1904.9326171875, -420.462890625, 25.892049789429,0,0,180}
    }
local copsCar = { 
   {-1909.4384765625, -408.8125, 25.171875,0,0,180},
   {-1904.932675, -411.9296875, 25.171875,0,180},
   {-1900.765625,  -408.8125, 25.171875,0,0,180},
   {-1904.932675, -398.9296875, 25.171875,0,0,180}
    }
local isEvent = false
local warpLimit = 0
local warps = 0
local thePlayers = {}
local copVehicles = {}
local crimVehicles = {}


local function messageCNR(message,r,g,b)
    for k, player in ipairs(getElementsByType("player")) do
                    if(exports.USGrooms:getPlayerRoom(player) == "cnr")then
                    exports.USGmsg:msg(player, message, r,g,b)
                end
            end
end


function prepareEvent()
    for k,pos in ipairs(crimvehicle)do
        local crimcar = createVehicle(pos[1],pos[2],pos[3],pos[4],0,0,180)
        local crimcarcolor = setVehicleColor(crimcar,0 ,0 ,0)
        setElementFrozen(crimcar, true)
        setVehicleDamageProof(crimcar, true)
        if not ( crimVehicles ) then
            crimVehicles = {}
        end
        table.insert( crimVehicles, crimcar )
        vehiclezone = createColSphere(-1904.9326171875, -420.462890625, 25.892049789429,150)
        attachElements(vehiclezone, crimcar)
        addEventHandler ( "onVehicleStartEnter", crimcar, onEnterVehicle )
        addEventHandler("onVehicleEnter",crimcar, startEvent)
        addEventHandler ( "onVehicleExit", crimcar, stopEvent )
    end
    for i, player in ipairs(getElementsByType("player")) do
        if(exports.USGcnr_jobs:getPlayerJobType(player) == "criminal") then
            outputChatBox("Someone lost his car in SF go steal it", player,0, 255, 0)
        end
    end    
end
addEventHandler("onResourceStart", resourceRoot, prepareEvent)

function onEnterVehicle ( player, seat, jacked ) 
    if (  exports.USGcnr_jobs:getPlayerJobType(player) ~= "criminal" ) then 
        cancelEvent()
        exports.USGmsg:msg(player,"Only criminals can enter this car", 0, 255, 0)
    end
end

addEvent( "onCreateWarpEvent", true )
function startEvent()
local driver = getVehicleOccupant ( source ) 
    if ( driver ) then 
        isEvent = true
        warpLimit = 5
        warps = 0
        thePlayers = {}
        

        for i, player in ipairs(getElementsByType("player")) do
            if(exports.USGcnr_jobs:getPlayerJobType(player) == "police") then
                outputChatBox ( getPlayerName ( driver ) .. " is trying to steal a car in SF! Use /stopcrim and try to catch him!!",player)
            end
        end
    end
end
addEventHandler( "onCreateWarpEvent", root, startEvent )




function warpLaw(thePlayer)
    if(exports.USGcnr_jobs:getPlayerJobType(thePlayer) == "police") then
        if (isEvent) then
            if not ( thePlayers[thePlayer] ) then
                thePlayers[thePlayer] = thePlayer
                warps = warps + 1
                --for i, v in ipairs (thePlayers ) do
                        copcar = createVehicle(411,-1909.4384765625, -408.8125, 25.171875,0,0,180)
                        --copcar2 = createVehicle(411,-1904.932675, -411.9296875, 25.171875,0,0,180)
                        setVehicleColor(copcar,0 ,76 ,253)
                        -- setVehicleColor(copcar2,0 ,76 ,253)
                        setVehicleDamageProof(copcar, true)
                        --setVehicleDamageProof(copcar2, true)
                        warpPedIntoVehicle(thePlayers, copcar )
                        --warpPedIntoVehicle(v, copcar2 )
                        --if not ( copVehicles ) then
                        --    copVehicles = {}
                        -- end
                        --table.insert( copVehicles, copcar )
                        --end
                    outputChatBox("test")
                
               
            end
            if ( warps >= warpLimit ) then
                isEvent = false
                outputChatBox( "Enough cops are already trying to stop the criminal" )
            end
        end    
    end
end
addCommandHandler("stopcrim",warpLaw)

function stopEvent()
    if (isEvent) then
        isEvent = false
        if (crimVehicles) then
            for i, theElement in ipairs ( crimVehicles ) do
                if ( isElement( theElement ) ) then
                    destroyElement( theElement )
                end
            end
        end
        if ( copVehicles ) then
        for i, theElement in ipairs (  copVehicles ) do
                if ( isElement( theElement ) ) then
                    destroyElement( theElement )
                end
            end
        end
        
        --if(exports.USGcnr_jobs:getPlayerJobType(player) == "police") then
            outputChatBox ( "The criminal left the car")
    end
end