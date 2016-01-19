local destination = false

function getDestination()
	return destination
end

function setDestination(name, ...)
	local dest = {name = name}
	local args = {...}
	if(isElement(args[1])) then -- mark element
		removeDestination()
		dest.target = args[1]
		dest.blip = createBlipAttachedTo(dest.target, 41)
		local tx,ty,tz = getElementPosition(dest.target)
		dest.marker = createMarker(tx,ty,tz-1,"cylinder",5,255,0,0,160)
		attachElements(dest.marker, dest.target, 0, 0, -1)
	else
		local x,y,z = args[1], args[2], args[3]
		if(x and y and z) then
			removeDestination()
			dest.x, dest.y, dest.z = x, y, z
			dest.blip = createBlip(dest.x, dest.y, dest.z, 41)
			dest.marker = createMarker(dest.x, dest.y, dest.z-1,"cylinder",4,255,0,0,160)
		else
			error("setDestination(name, x, y, z) | missing x,y,z")
		end
	end
	addEventHandler("onClientMarkerHit", dest.marker, onDestinationHit)
	destination = dest
	caclulateRoute()
end

function removeDestination()
	if(destination) then
		if(isElement(destination.blip)) then destroyElement(destination.blip) end
		if(isElement(destination.marker)) then destroyElement(destination.marker) end
		clearRoute()
		destination = false
	end
end

function onDestinationHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	if(not exports.USG:validateMarkerZ(hitElement, source)) then return end
	exports.USGmsg:msg("You have reached your destination: "..destination.name, 0, 255, 0)
	removeDestination()
end


-------------------------------
-------------------------------
-------------------------------
-------------------------------
-------------------------------
local nodeElements = {}

function onNodeColHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	local toBeDestroyed = {}
	local i = 0
	for _, node in ipairs(nodeElements) do
		table.insert(toBeDestroyed, node)
		if(node.colShape == source) then
			break
		end
	end
	for i, node in ipairs(toBeDestroyed) do
		destroyNode(node)
		table.remove(nodeElements, 1)
	end
end

function destroyNode(node)
	if(isElement(node.arrow)) then
		destroyElement(node.arrow)
	end
	if(isElement(node.colShape)) then
		destroyElement(node.colShape)
	end
	if(node.point) then
		removeLinePoint(node.point.name, node.point.id)
	end
end

function clearRoute()
	for i, node in ipairs(nodeElements) do
		destroyNode(node)
	end
	removeLinePoints()
	nodeElements = {}
end

function caclulateRoute()
	clearRoute()
	local px,py,pz = getElementPosition(localPlayer)
	local x,y,z
	if(destination.target) then
		x,y,z = getElementPosition(destination.target) 
	else
		x,y,z = destination.x, destination.y, destination.z
	end
	triggerServerEvent("USGcnr_gps.calculatePathByCoords", localPlayer, px,py,pz,x,y,z)
end

addEvent("USGcnr_gps.pathCalculated", true)
function calculateRoutePathCallback(path)
	for i, node in ipairs(path) do
		local elements = {}
		local nextNode
		if(path[i+1]) then
			nextNode = path[i+1]
		else
			nextNode = {x=destination.x,y=destination.y,z=destination.z}
		end
		local arrow = createObject(1318, node.x, node.y, node.z+1)
		local rot = findRotation(nextNode.x,nextNode.y,node.x,node.y)+90
		setElementRotation(arrow, 0, 90, rot)
		elements.arrow = arrow
		local colShape = createColSphere(node.x,node.y,node.z,5)
		addEventHandler("onClientColShapeHit", colShape, onNodeColHit)
		elements.colShape = colShape

		local tileName, pointID = addLinePoint(node.x, node.y)
		elements.point = {name = tileName, id = pointID}

		nodeElements[i] = elements
	end
end
addEventHandler("USGcnr_gps.pathCalculated", localPlayer, calculateRoutePathCallback)

local floor = math.floor

addCommandHandler('path', 
	function(command, node1, node2)
		if not tonumber(node1) or not tonumber(node2) then
			outputChatBox("Usage: /path node1 node2", 255, 0, 0)
			return
		end
		local path = server.calculatePathByNodeIDs(tonumber(node1), tonumber(node2))
		if not path then
			outputConsole('No path found')
			return
		end
		server.spawnPlayer(getLocalPlayer(), path[1].x, path[1].y, path[1].z)
		fadeCamera(true)
		setCameraTarget(getLocalPlayer())
		
		removeLinePoints ( )
		table.each(getElementsByType('marker'), destroyElement)
		for i,node in ipairs(path) do
			createMarker(node.x, node.y, node.z, 'corona', 5, 50, 0, 255, 200)
			addLinePoint ( node.x, node.y )
		end
	end
)
addCommandHandler('path2', 
	function(command, tox, toy, toz)
		if not tonumber(tox) or not tonumber(toy) then
			outputChatBox("Usage: /path2 x y z (z is optional)", 255, 0, 0)
			return
		end
		local x,y,z = getElementPosition(getLocalPlayer())
		local path = server.calculatePathByCoords(x, y, z, tox, toy, toz)
		if not path then
			outputConsole('No path found')
			return
		end
		server.spawnPlayer(getLocalPlayer(), path[1].x, path[1].y, path[1].z)
		fadeCamera(true)
		setCameraTarget(getLocalPlayer())
		
		removeLinePoints ( )
		table.each(getElementsByType('marker'), destroyElement)
		for i,node in ipairs(path) do
			createMarker(node.x, node.y, node.z, 'corona', 5, 50, 0, 255, 200)
			addLinePoint ( node.x, node.y )
		end
	end
)

local function getAreaID(x, y)
	return math.floor((y + 3000)/750)*8 + math.floor((x + 3000)/750)
end

local function getNodeByID(db, nodeID)
	local areaID = floor(nodeID / 65536)
	return db[areaID][nodeID]
end

--[[
addEventHandler('onClientRender', getRootElement(),
	function()
		local db = vehicleNodes
		
		local camX, camY, camZ = getCameraMatrix()
		local x, y, z = getElementPosition(getLocalPlayer())
		local areaID = getAreaID(x, y)
		local drawn = {}
		for id,node in pairs(db[areaID]) do
			if getDistanceBetweenPoints3D(x, y, z, node.x, node.y, z) < 300 then
				--[/[
				local screenX, screenY = getScreenFromWorldPosition(node.x, node.y, node.z)
				if screenX then
					dxDrawText(tostring(id), screenX - 10, screenY - 5)
				end
				--]/]
				--[/[
				for neighbourid,distance in pairs(node.neighbours) do
					if not drawn[neighbourid .. '-' .. id] then
						local neighbour = getNodeByID(db, neighbourid)
						dxDrawLine3D(node.x, node.y, node.z + 1, neighbour.x, neighbour.y, neighbour.z + 1, tocolor(0, 0, 200, 255), 3)
						drawn[id .. '-' .. neighbourid] = true
					end
				end
				--]/]
			end
		end
	end
)
--]]