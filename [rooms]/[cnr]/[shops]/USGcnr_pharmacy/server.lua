
local playersRequiredToActivate = 20

local markers = {
{ 2292.65625, -17.818359375, 26.33846282959}
}


addEventHandler ( "onResourceStart", resourceRoot, function()
--for k,v in ipairs(markers) do
        local marker = createMarker(2310.171875, -8.421875, 25, "cylinder",4, 200,255,0,170)
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
end
)

function onShopMarkerHit(p)
    if( getPlayerCount() >= playersRequiredToActivate)then
    triggerClientEvent ( p, "USGcnr_pharmacy.sell.open",resourceRoot)
    else exports.USGmsg:msg(p, "A minimum of "..tostring(playersRequiredToActivate).." players is required for the shop to sell medicines (current "..tostring(getPlayerCount()).." players)", 255, 0, 0)
    end
end

function onShopMarkerLeave(p)
triggerClientEvent ( p, "USGcnr_pharmacy.sell.close",resourceRoot)
end

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

