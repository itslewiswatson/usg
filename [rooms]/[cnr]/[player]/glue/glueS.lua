
local gluedPlayer = {}

function gluePlayer(slot, vehicle, x, y, z, rotX, rotY, rotZ)
	attachElements(client, vehicle, x, y, z, rotX, rotY, rotZ)
	setPedWeaponSlot(client, slot)
	gluedPlayer[client] = vehicle
end
addEvent("gluePlayer",true)
addEventHandler("gluePlayer",getRootElement(),gluePlayer)

function ungluePlayer(vehicle)
	-- Prevent debug errors
	if (client) and (isElement(vehicle)) then
		detachElements(client, vehicle)
	end
	gluedPlayer[client] = nil
end
addEvent("ungluePlayer",true)
addEventHandler("ungluePlayer",getRootElement(),ungluePlayer)

function ungluePlayerAfterEvent()
	triggerClientEvent(source,"unGluePlayer",source)
end

addEventHandler("onPlayerArrested", root,ungluePlayerAfterEvent)
addEventHandler("onPlayerGetTazed", root, ungluePlayerAfterEvent)
addEventHandler("onPlayerWasted",root,ungluePlayerAfterEvent)
