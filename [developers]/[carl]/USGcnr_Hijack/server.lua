local positions = {
{1382.302734375, 1038.572265625, 10.8203125, 272.55572509766},
{988.91015625, 1070.634765625, 10.8203125, 357.04190063477},
{1108.6142578125, 1794.068359375, 10.8203125, 93.404449462891},
{1153.396484375, 2338.361328125, 16.71875, 99.265747070312},
{1428.85546875, 2878.318359375, 10.8203125, 179.67590332031},
{2815.447265625, 2153.853515625, 10.8203125, 10.286102294922},
{2785.0859375, 1232.0166015625, 10.75, 273.18197631836},
{2129.9609375, 891.943359375, 10.8203125, 1.3266296386719},
{1754.2373046875, 1839.8916015625, 10.812908172607, 178.84094238281},
}

local Car = {445,467,604,426,507,547,585,405,587,409,466,550,492,566,546,540,551,421,516,529}

local vehicle
local CarBlip
local DesBlip
local marker

local timerbeforeEnd 

local GlobalTimer
local ID = 5

function table.compare( a1, a2 )
    if 
        type( a1 ) == 'table' and
        type( a2 ) == 'table'
    then
 
        local function size( t )
            if type( t ) ~= 'table' then
                return false 
            end
            local n = 0
            for _ in pairs( t ) do
                n = n + 1
            end
            return n
        end
 
        if size( a1 ) == 0 and size( a2 ) == 0 then
            return true
        elseif size( a1 ) ~= size( a2 ) then
            return false
        end
 
        for _, v in pairs( a1 ) do
            local v2 = a2[ _ ]
            if type( v ) == type( v2 ) then
                if type( v ) == 'table' and type( v2 ) == 'table' then
                    if size( v ) ~= size( v2 ) then
                        return false
                    end
                    if size( v ) > 0 and size( v2 ) > 0 then
                        if not table.compare( v, v2 ) then 
                            return false 
                        end
                    end 
                elseif 
                    type( v ) == 'string' or type( v ) == 'number' and
                    type( v2 ) == 'string' or type( v2 ) == 'number'
                then
                    if v ~= v2 then
                        return false
                    end
                else
                    return false
                end
            else
                return false
            end
        end
        return true
    end
    return false
end


local function messageCNR(message,r,g,b)
	for k, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr")then
			exports.USGmsg:msg(player, message, r,g,b)
		end
	end
end

function OnVehicleEnter(player)
    messageCNR(getPlayerName(player).." has entered the hijacked vehicle", 0, 255, 0)
    setElementVisibleTo ( marker, player, true )
    setElementVisibleTo ( DesBlip, player, true )
    exports.USGcnr_wanted:givePlayerWantedLevel(player,10)

    if (isElementInWater(source)) then
        over()
    end
end

function OnVehicleExit(player)
	messageCNR(getPlayerName(player).." has exited the hijacked vehicle", 0, 255, 0)
    setElementVisibleTo ( marker, player, false )
    setElementVisibleTo ( DesBlip, player, false )

    if (isElementInWater(source)) then
        over()
    end
end

function OnVehicleExplode()
    over()
end

function OnMarkerHit(hitElement )
    local hitVehicle

	if (isElement(hitElement))then
		if (getElementType(hitElement) == "player")then
    		hitVehicle = getPedOccupiedVehicle(hitElement)

    		if(hitVehicle == vehicle)then
    			over(getVehicleOccupant (hitVehicle))
    		end
		end
	end
end

function start()
    local startPos = positions[math.random(#positions)]
    local destinationPos = positions[math.random(#positions)]

    if (table.compare( startPos, destinationPos )) then
        start() -- If start and destination are the same get new ones
    else
        local randomCar = Car[math.random(#Car)]
        vehicle = createVehicle ( randomCar, startPos[1], startPos[2], startPos[3] ,0, 0, startPos[4], "Hijack")
        addEventHandler ( "onVehicleEnter", vehicle, OnVehicleEnter )
        addEventHandler ( "onVehicleExit", vehicle, OnVehicleExit )
        addEventHandler ( "onVehicleExplode", vehicle, OnVehicleExplode )
        CarBlip = createBlipAttachedTo ( vehicle, 12, 1)

        for k, player in ipairs(getElementsByType("player")) do
            if(not exports.USGrooms:getPlayerRoom(player) == "cnr") then
                setElementVisibleTo ( CarBlip, player, false )
            end
        end

        marker = createMarker ( destinationPos[1], destinationPos[2], destinationPos[3] - 1 ,"cylinder")
        addEventHandler( "onMarkerHit", marker, OnMarkerHit )
        DesBlip = createBlipAttachedTo ( marker, 53, 1)
        clearElementVisibleTo ( marker )
        clearElementVisibleTo ( DesBlip )

        for k, player in ipairs(getElementsByType("player")) do
            setElementVisibleTo ( marker, player, false )
            setElementVisibleTo ( DesBlip, player, false )
        end

        messageCNR("A vehicle has to be delivered from "..getZoneName(startPos[1], startPos[2], startPos[3]).." to an unknown destination", 0, 255, 0)
        timerbeforeEnd = setTimer(over,10 * 60 * 1000 , 1)
    end
end

function over(player)
    if (isVehicleBlown (vehicle)) then
        messageCNR("The hijacked vehicle has blown up! Mission failed.", 0, 255, 0)
        killTimer(timerbeforeEnd)
    elseif (isElementInWater(vehicle)) then
        messageCNR("The hijacked vehicle has been sent into water! Mission failed.", 0, 255, 0)
    elseif (player) then
        exports.USGcnr_wanted:givePlayerWantedLevel(player,5)
        givePlayerMoney(player, 10000)
        killTimer(timerbeforeEnd)
		messageCNR(getPlayerName(player).." delivered the hijacked car in time!", 0, 255, 0)
    else 
        messageCNR("No one delivered the hijacked car in time!", 0, 255, 0)
    end

    removeEventHandler ( "onVehicleEnter", vehicle, OnVehicleEnter )
    removeEventHandler ( "onVehicleExit", vehicle, OnVehicleExit  )
    removeEventHandler ( "onVehicleExplode", vehicle, OnVehicleExplode )
    destroyElement(vehicle)
    destroyElement(CarBlip)
    destroyElement(DesBlip)
    destroyElement(marker)
	GlobalTimer = setTimer ( start,15 * 60 * 1000, 1)
end

addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGEventsApp (re)started
        if(res == resource or res == getResourceFromName("USGEventsApp")) then
        
        end

		if(res == resource)then
		    start()
		end
    end
)

addEventHandler ( "onResourceStop", resourceRoot, 
    function (  )
   end 
) 
