-- Sorry for my code style.
function onBuyColor(r, g, b)
	local vehicle = getPedOccupiedVehicle(client)
	if (not isElement(vehicle)) then
		outputChatBox("You're not in a vehicle!", client, 255, 0, 0)
		return
	end
	if (r and g and b and isElement(vehicle)) then
		setVehicleColor(vehicle, r, g, b)
	end
	exports.USGmsg:msg(client, "You bought Color", 0, 255, 0)
end
addEvent("USGrace_shop.buycolor", true)
addEventHandler("USGrace_shop.buycolor", root, onBuyColor)

function onBuyExplode()
	local vehicle = getPedOccupiedVehicle(client)
	if (not isElement(vehicle)) then
		outputChatBox("You're not in a vehicle!", client, 255, 0, 0)
		return
	end
	if (isElement(vehicle)) then
		blowVehicle(vehicle)
		takePlayerMoney(client, 750)
	end
	exports.USGmsg:msg(client, "You bought Self Explode", 0, 255, 0)
end
addEvent("USGrace_shop.buyexplode", true)
addEventHandler("USGrace_shop.buyexplode", root, onBuyExplode)

addEvent("USGrace_shop.buynitrous",true)
addEventHandler("USGrace_shop.buynitrous",root,
    function ()
    local vehicle = getPedOccupiedVehicle(client)
        if (not isElement(vehicle)) then outputChatBox("You're not in a vehicle", client, 255, 0, 0) return end
            if (isElement(vehicle)) then 
                addVehicleUpgrade(vehicle, 1010)
                takePlayerMoney(client,100)
                exports.USGmsg:msg(client,"You bought Nitrous", 0,255,0)
            end
    end
)


addEvent("USGrace_shop.buyflip",true)
addEventHandler("USGrace_shop.buyflip",root,
    function ()
        if (not isPedInVehicle(client)) then return end
        local vehicle = getPedOccupiedVehicle(client)
        if (not isElement(vehicle)) then outputChatBox("You're not in a vehicle", client, 255, 0, 0) return end
            if (isElement(vehicle)) then             
                local rx, ry, rz = getElementRotation(vehicle)
                local x, y, z = getElementPosition(vehicle)
                setElementRotation(vehicle, 0, 0, rz)
                setElementPosition(vehicle, x, y, z + 2)
                takePlayerMoney(client,100)
                exports.USGmsg:msg(client,"You bought Flip", 0,255,0)
            end
    end
)

addEvent("USGrace_shop.buyinv",true)
addEventHandler("USGrace_shop.buyinv",root,
    function ()
        local vehicle = getPedOccupiedVehicle(client)
        if (not isElement(vehicle)) then outputChatBox("You're not in a vehicle", client, 255, 0, 0) return end
            if (isElement(vehicle)) then 
                setElementAlpha(client, 30)
                setElementAlpha(vehicle, 30)
                takePlayerMoney(client,300)
            end
    end
)


