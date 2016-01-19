local positions = {
    {--First Building
    2310.830078125, 1456.3037109375, 10.8203125,80,--Building posx,posY,psZ,markerSize
        {2262.865234375, 1398.7529296875, 42.8203125, 268.38635253906},--position in building
        {2342.529296875, 1387.4892578125, 42.8203125, 3.3206787109375},--position in building
        {2271.2001953125, 1518.982421875, 36.421875, 186.98191833496},--position in building
        {2352.453125, 1451.3388671875, 10.8203125, 86.587310791016},--position in building
    },
    {
    2517.5654296875, 2377.8349609375, 4.2109375, 40,
        {2492.0595703125, 2398.0556640625, 4.2109375, 269.33120727539},
        {2485.9580078125, 2356.515625, 4.2109375, 267.69421386719},
    },
    {
    2507.634765625, 2512.9404296875, 10.8203125,40,
        {2462.4853515625, 2496.8818359375, 10.8203125, 179.43969726562},
        {2403.1279296875, 2574.373046875, 10.8203125, 267.37561035156},
        {2521.55859375, 2470.6083984375, 21.875, 0.58502197265625},
        {2404.791015625, 2529.04296875, 21.875, 0.67291259765625},
    },
    {
    2082.4189453125, 2410.21875, 11.067465782166,40,
        {2108.6591796875, 2371.6083984375, 10.8203125, 0.28289794921875},
        {2056.5625, 2433.142578125, 15.1171875, 185.26254272461},
        {2078.6201171875, 2398.5068359375, 19.421875, 180.01007080078},
        {2113.1708984375, 2431.734375, 23.71875, 173.8310546875},
        {2090.6455078125, 2433.5146484375, 28.0234375, 180.97230529785},
        {2112.408203125, 2431.955078125, 32.3203125, 92.531005859375},
        {2090.3837890625, 2383.6162109375, 45.21875, 353.84481811523},
        {2061.091796875, 2372.4462890625, 49.531223297119, 357.2121887207},
    },
    {
    1661.0205078125, -1682.0703125, 21.430557250977, 40,
        {1670.861328125, -1695.6123046875, 20.48034286499, 94.178985595703},
        {1645.857421875, -1705.7626953125, 15.609375, 185.09773254395},
    },
    {
    -1817.19921875, 1299.9140625, 22.5625, 40,
        {-1781.640625, 1311.4482421875, 59.734375, 82.643157958984},
        {-1779.380859375, 1312.6484375, 41.1484375, 163.91577148438},
    },
}

local AnimBlock = "STRIP"

local Car = {445,467,604,426,507,547,585,405,587,409,466,550,492,566,546,540,551,421,516,529}

local Slutskins = {63,64,75,85,87,90,92,138,139,140,145,152,178,237,238,243,244,245,246,256,257}
local Slutanimations = {"STR_A2B", "STR_B2C", "STR_C1", "STR_C2", "STR_Loop_A", "STR_Loop_B", "STR_Loop_C"}

local vehicle
local slut
local blip
local marker

local timerbeforeEnd

local GlobalTimer
local ID = 4

local function messageCNR(message,r,g,b)
    for k, player in ipairs(getElementsByType("player")) do
        if (exports.USGrooms:getPlayerRoom(player) == "cnr") then
            exports.USGmsg:msg(player, message, r,g,b)
        end
    end
end

function start()
    local buildingPos = positions[math.random(#positions)]
    local randomPos = buildingPos[math.random(5,#buildingPos)]
    local randomSlut = Slutskins[math.random(#Slutskins)]
    local randomSlutAnim = Slutanimations[math.random(#Slutanimations)]
    local randomCar = Car[math.random(#Car)]
    
    marker = createMarker(buildingPos[1], buildingPos[2], buildingPos[3] , "checkpoint", buildingPos[4])
    blip = createBlipAttachedTo(marker, 21, 1)
    for k, player in ipairs(getElementsByType("player")) do
        if (not exports.USGrooms:getPlayerRoom(player) == "cnr") then
            setElementVisibleTo(marker, player, false)
            setElementVisibleTo(blip, player, false)
        end
    end
    vehicle = createVehicle(randomCar, randomPos[1], randomPos[2],randomPos[3] + 0.5 ,0,0, randomPos[4], "SLUT")
    setVehicleDamageProof(vehicle ,true)
    slut = createPed(randomSlut, randomPos[1], randomPos[2],randomPos[3] + 1.5, randomPos[4])
    setElementFrozen(slut,true)
    addEventHandler("onPedWasted", slut,
        function ()
            Over()
        end
    )
    --setPedAnimation(slut , AnimBlock, randomSlutAnim, -1, true, false,false, false)
    addEventHandler("onVehicleEnter", vehicle, Over)
    local x, y, z = getElementPosition(slut)
    local location = getZoneName(x,y,z)
    messageCNR("A slut is asking for the D. She is stripping on top of her car at "..location..". Go finger her for some extra health.", 0, 255, 0)
    timerbeforeEnd = setTimer(Over, 7 * 60 * 1000, 1)
end

function Over(p)
    if (p)then
        setPedStat(p, 24, 1000)
        setElementHealth(p, 1000)
        messageCNR(getPlayerName(p).." found the slut!", 0, 255, 0)
        killTimer(timerbeforeEnd)
    else
        if (slut)then
            if (isPedDead(slut))then
                messageCNR("The slut died :(", 0, 255, 0)
                killTimer(timerbeforeEnd)
            else
                messageCNR("The slut couldn't find anyone. She ended up using a dildo...", 0, 255, 0)
            end
        end
    end
    removeEventHandler ("onVehicleEnter", vehicle, Over)
    destroyElement(vehicle)
    destroyElement(slut)
    destroyElement(blip)
    destroyElement(marker)
    GlobalTimer = setTimer(start, 10 * 60 * 1000, 1)
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
