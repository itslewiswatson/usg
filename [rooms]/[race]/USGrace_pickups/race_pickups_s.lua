local MODEL_NOS = 2221
local MODEL_REPAIR = 2222

local pickupType = {}
local roomPickups = {}

_createPickup = createPickup
function createPickup(room, x,y,z,pType)
	local model
	if(pType == "nitro") then
		model = MODEL_NOS
	elseif(pType == "repair") then
		model = MODEL_REPAIR
	end
	if(not model) then return false end
	if(not roomPickups[room]) then roomPickups[room] = {} end
	local pickup = _createPickup(x,y,z,3,model,0)
	setElementDimension(pickup, exports.USGrooms:getRoomDimension("dd"))
	pickupType[pickup] = pType
	table.insert(roomPickups[room], pickup)
	addEventHandler("onPickupHit", pickup, onPickupHit)
	return true
end

function clearPickups(room)
	if(roomPickups[room]) then
		for i, pickup in ipairs(roomPickups[room]) do
			if(isElement(pickup)) then
				destroyElement(pickup)
			end
			pickupType[pickup] = nil
		end
		roomPickups[room] = {}
	end
end

addEvent("USGrace_pickups.onPickupHit", true)
function onPickupHit(pickup)
	if(isElement(source)) then
		if(pickup.type == "nitro") then -- give nos
			addVehicleUpgrade(source, 1008)
		elseif(pickup.type == "repair") then -- repair
			fixVehicle(source)
		elseif(pickup.type == "vehiclechange" and pickup.args and pickup.args[1]) then
			setElementModel(source, pickup.args[1])
		end
	end
end
addEventHandler("USGrace_pickups.onPickupHit", root, onPickupHit)