
local playersRequiredToActivate = 20

local markers = {
{ 2292.65625, -17.818359375, 26.33846282959},
{-1935.4775390625, 2381.9013671875, 46.499954223633},
{-1428.2197265625, -964.2802734375, 197.8837890625},
{-60.654296875, 51.4365234375, 0.110269546508},
{2598.1826171875, -2442.896484375, 10.626231}
}

local randomPos = markers[math.random(#markers)]
local marker 
local blip

function start()
--for k,v in ipairs(markers) do
exports.USGmsg:msg(root, "Pharmacy is opened go buy some medicines.", 255, 0, 0)
   local marker = createMarker(randomPos[1], randomPos[2], randomPos[3], "cylinder",4, 200,255,0,170)
        local blip = createBlipAttachedTo ( marker, 26,1,_,_,_,_,_,2000)
        for k, player in ipairs(getElementsByType("player")) do
            if (not exports.USGrooms:getPlayerRoom(player) == "cnr") then
                setElementVisibleTo(marker, player, false)
                setElementVisibleTo(blip, player, false)
            end
        end
        addEventHandler( "onMarkerHit",marker, onShopMarkerHit)
        addEventHandler( "onMarkerLeave",marker, onShopMarkerLeave)
      --  end
      --  setTimer(Over, 7 * 60 * 1000, 1)
end


function onShopMarkerHit(p)

    triggerClientEvent ( p, "USGcnr_pharmacy.sell.open",resourceRoot)
 
end

function onShopMarkerLeave(p)
triggerClientEvent ( p, "USGcnr_pharmacy.sell.close",resourceRoot)
end


--[function over()
--exports.USGmsg:msg(root, "Pharmacy is closed.", 255, 0, 0)
--destroyElement(marker)
--destroyElement(blip)
--setTimer(start, 10 * 60 * 1000, 1)
--end


function onAspirinBuy()
    if(exports.USGrooms:getPlayerRoom(client) == "cnr" and getPlayerMoney(client) > 500) then
        takePlayerMoney(client,500)
        exports.USGcnr_medicines:givePlayerMedicines(client,"Aspirin",1)
    end

end
addEvent( "buyAspirin", true )
addEventHandler( "buyAspirin", resourceRoot, onAspirinBuy )

function onSteroidBuy()
    if(exports.USGrooms:getPlayerRoom(client) == "cnr" and getPlayerMoney(client) > 500) then
        takePlayerMoney(client,500)
        exports.USGcnr_medicines:givePlayerMedicines(client,"Steroid",1)
    end

end
addEvent( "buySteroid", true )
addEventHandler( "buySteroid", resourceRoot, onSteroidBuy )

