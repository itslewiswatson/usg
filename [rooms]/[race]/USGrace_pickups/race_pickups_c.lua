local MODEL_NOS = 2221
local MODEL_REPAIR = 2222
local MODEL_CHANGE = 2223

function loadPickupMod(name, id)
	local txd = engineLoadTXD(name..".txd")
	if(txd) then
		engineImportTXD(txd, id)
	end
	local dff = engineLoadDFF(name..".dff", id)
	if(dff) then
		engineReplaceModel(dff, id)
	end
	engineSetModelLODDistance(id, 60)
end
loadPickupMod("mods/nitro", MODEL_NOS)
loadPickupMod("mods/repair", MODEL_REPAIR)
loadPickupMod("mods/change", MODEL_CHANGE)


local colPickup = {}
local vehChangePickups = {}
function createPickup(x,y,z,pType, args)
	local model
	if(pType == "nitro") then
		model = MODEL_NOS
	elseif(pType == "repair") then
		model = MODEL_REPAIR
	elseif(pType == "vehiclechange") then
		model = MODEL_CHANGE
	end
	if(not model) then return false end
	local dimension = exports.USGrooms:getRoomDimension(exports.USGrooms:getPlayerRoom() or "dm") or getElementDimension(localPlayer)
	local pickup = createObject(model,x,y,z)
	setElementDimension(pickup, dimension)
	local col = createColSphere(x,y,z,3)
	setElementDimension(col, dimension)
	local pickupInfo = {type=pType,args=args, pickup = pickup}
	colPickup[col] = pickupInfo
	addEventHandler("onClientColShapeHit", col, onPickupHit)
	if(model == MODEL_CHANGE) then
		table.insert(vehChangePickups, pickupInfo)
	end
	return true
end

function clearPickups()
	for col, pickup in pairs(colPickup) do
		if(isElement(pickup.pickup)) then
			destroyElement(pickup.pickup)
		end
		if(isElement(col)) then
			destroyElement(col)
		end
	end
	colPickup = {}
	vehChangePickups = {}
end

function onPickupHit(hitElement)	
	if(getElementType(hitElement) == "vehicle" and getVehicleController(hitElement) == localPlayer) then
		local pickup = colPickup[source]
		local pType = pickup.type
		if(pType == "nitro") then -- give nos
			triggerEvent("USGrace_nitro.onPickup", hitElement)
		elseif(ptype == "vehiclechange") then
			for i, info in ipairs(vehChangePickups) do
				if(info == pickup) then
					table.remove(vehChangePickups, i)
				end
			end
		end
		triggerServerEvent("USGrace_pickups.onPickupHit",hitElement,{args=pickup.args,type=pickup.type})
		playSoundFrontEnd(46)
	end
end

local color_white = tocolor(255,255,255)
local lastFrameTick
function renderPickups()
	if(lastFrameTick) then
		local delta = getTickCount()-lastFrameTick
		for col, pickup in pairs(colPickup) do
			if(isElement(pickup.pickup)) then
				local rx,ry,rz = getElementRotation(pickup.pickup)
				local newRot = rz+(delta*0.3)
				if(newRot < 0) then newRot = 360-newRot 
				elseif(newRot > 360) then newRot = newRot-360 end
				setElementRotation(pickup.pickup, rx,ry,newRot)
			end
		end
	end
	lastFrameTick = getTickCount()
	if(#vehChangePickups == 0) then return end
	local px,py,pz,_,_,_,_,_ = getCameraMatrix()
	for i, info in ipairs(vehChangePickups) do
		if(isElementStreamedIn(info.pickup) and isElementOnScreen(info.pickup)) then
			local x,y,z = getElementPosition(info.pickup)
			z = z + 1.5
			local distance = getDistanceBetweenPoints3D(px,py,pz,x,y,z)
			if(distance < 300) then
				if(isLineOfSightClear(px,py,pz,x,y,z,true,false,false,true,false,true,false,info.pickup)) then
					local sx, sy = getScreenFromWorldPosition(x,y,z)
					if(sx and sy) then
						local scale = 1.2
						local name = getVehicleNameFromModel(info.args[1])
						if(name) then
							local width = dxGetTextWidth(name)
							dxDrawText(name, sx-(width*0.5), sy, sx+(width*0.5)+5, sy+35, color_white,scale,"default")
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, renderPickups)