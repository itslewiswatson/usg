local parkingLocations = {}
local parkedVehicles = {}

function getCarParkFromNode(node)
	local x, y = tonumber(xmlNodeGetAttribute(node, "posX")), tonumber(xmlNodeGetAttribute(node, "posY"))
	local z, width = tonumber(xmlNodeGetAttribute(node, "posZ")), tonumber(xmlNodeGetAttribute(node, "width"))
	local depth, height = tonumber(xmlNodeGetAttribute(node, "depth")), tonumber(xmlNodeGetAttribute(node, "height"))
	return x,y,z,width,depth,height
end

function getNoParkZoneFromNode(node)
	local x, y = tonumber(xmlNodeGetAttribute(node, "posX")), tonumber(xmlNodeGetAttribute(node, "posY"))
	local z, radius = tonumber(xmlNodeGetAttribute(node, "posZ")), tonumber(xmlNodeGetAttribute(node, "radius"))
	return x,y,z,radius
end

function getBlipPostion(x,y,width,depth)
local blipX = x + (width/2) 
local blipY = y + (depth/2)
return blipX,blipY
end

addEventHandler("onResourceStart", resourceRoot,
	function ()
		local xml = xmlLoadFile("carparks.xml")
		if(xml) then
			local carparks = xmlNodeGetChildren(xml)
			for i, carpark in ipairs(carparks) do
				local location = { noparkZones = {} }
				local x,y,z,width,depth,height = getCarParkFromNode(carpark)
				if(x and y and z and width and depth and height) then
					location.colShape = createColCuboid(x,y,z,width,depth,height)
					addEventHandler ( "onColShapeHit", location.colShape, function(element)
						if(getElementType(element) == "player")then
							if(exports.USGrooms:getPlayerRoom(element) == "cnr") then
								exports.USGmsg:msg(element, "You have entered a private vehicles parking space", 0, 255, 0)
							end
						end
					end)
					addEventHandler ( "onColShapeLeave", location.colShape, function(element) 
						if(getElementType(element) == "player")then
							if(exports.USGrooms:getPlayerRoom(element) == "cnr") then
								exports.USGmsg:msg(element, "You have left a private vehicles parking space", 0, 255, 0)
							end
						end
					end )
					local Bx,By = getBlipPostion(x,y,width,depth)
					    local blip = createBlip ( Bx,By , 0 , 48, _, _, _,_, _, _, 225)
						for k, player in ipairs(getElementsByType("player")) do
							if(not exports.USGrooms:getPlayerRoom(player) == "cnr")then
							setElementVisibleTo ( blip, player, false )     
							end 
						end
					for i, zone in ipairs(xmlNodeGetChildren(carpark)) do
						local x,y,z,radius = getNoParkZoneFromNode(zone)
						if(x and y and z and radius) then
							table.insert(location.noparkZones, {x=x,y=y,z=z,radius=radius})
						end
					end
				end
				table.insert(parkingLocations, location)
			end
		end
	end
)

function onVehicleStartExit(player, seat)
	if(exports.USGrooms:getPlayerRoom(player) == "cnr" and seat == 0) then
		if(isVehicleInCarPark(source)) then
			if(isVehiclePurchased(source)) then
				if(canVehiclePark(source)) then
					parkVehicle(source)
					exports.USGmsg:msg(player, "You have parked your vehicle.", 0, 255, 0)
				else
					exports.USGmsg:msg(player, "You can't park near the entrance.", 255, 0, 0)
					cancelEvent()
				end
			else
				exports.USGmsg:msg(player, "This parking location is only for purchased vehicle.", 255, 0, 0)
				cancelEvent()
			end
		end
	end
end
addEventHandler("onVehicleStartExit", root, onVehicleStartExit)

function onVehicleStartEnter(player, seat)
	if(exports.USGrooms:getPlayerRoom(player) == "cnr" and seat == 0) then
		if(isVehicleParked(source)) then
			if(getVehicleOwner(source) == player) then
				retrieveVehicle(source)
				exports.USGmsg:msg(player, "Your vehicle has been retrieved, it is no longer parked.", 60, 255, 0)
			end
		end
	end
end
addEventHandler("onVehicleStartEnter", root, onVehicleStartEnter)

function getVehicleCarPark(vehicle)
	if(isElement(vehicle)) then
		for i, location in ipairs(parkingLocations) do
			if(isElementWithinColShape(vehicle, location.colShape)) then
				return location
			end
		end
	end
	return false
end

function isVehicleInCarPark(vehicle)
	if(isElement(vehicle)) then
		return getVehicleCarPark(vehicle) ~= false
	end
	return false
end

function isVehicleParked(vehicle)
	return parkedVehicles[vehicle] ~= nil
end

function canVehiclePark(vehicle)
	if(isElement(vehicle)) then
		local carPark = getVehicleCarPark(vehicle)
		if(carPark) then
			local px, py, pz = getElementPosition(vehicle)
			for i, zone in ipairs(carPark.noparkZones) do
				local dist = getDistanceBetweenPoints3D(px,py,pz,zone.x,zone.y,zone.z)
				if(dist < zone.radius) then
					return false
				end
			end
			return true
		end
	end
	return false
end

function parkVehicle(vehicle)
	if(not isVehicleParked(vehicle) and isElement(vehicle)) then
		parkedVehicles[vehicle] = true
		setVehicleLocked(vehicle, true)
		setVehicleDamageProof(vehicle, true)
		setElementFrozen(vehicle, true)
	end
end

function retrieveVehicle(vehicle)
	if(isVehicleParked(vehicle) and isElement(vehicle)) then
		parkedVehicles[vehicle] = nil
		setVehicleLocked(vehicle, false)
		setVehicleDamageProof(vehicle, false)
		setElementFrozen(vehicle, false)
	end
end