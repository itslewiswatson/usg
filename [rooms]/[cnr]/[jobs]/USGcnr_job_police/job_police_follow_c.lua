function findRotation(x1,y1,x2,y2)
  local t = -math.deg(math.atan2(x2-x1,y2-y1))
  if t < 0 then t = t + 360 end;
  return t;
end

local cop
local following = false

addEvent("USGcnr_job_police.startFollow", true)
function setCopToFollow()
	if(not following) then
		cop = source
		following = true
		showCursor(true)
		addEventHandler("onClientPreRender", root, onFollowCop)
		addEventHandler("onClientPlayerDamage", localPlayer, cancelDamageWhileArrested)
		setControlState("forwards", false)
		setControlState("sprint", false)
		lastPos = false
	end
end
addEventHandler("USGcnr_job_police.startFollow", root, setCopToFollow)

addEvent("USGcnr_job_police.stopFollow", true)
function disableFollow()
	if(following) then
		cop = nil
		following = false
		showCursor(false)
		removeEventHandler("onClientPreRender", root, onFollowCop)
		removeEventHandler("onClientPlayerDamage", localPlayer, cancelDamageWhileArrested)
		setControlState("forwards", false)
		setControlState("sprint", false)
		setControlState("jump", false)
		setControlState("walk", false)
		lastPos = false
	end
end
addEventHandler("USGcnr_job_police.stopFollow", root, disableFollow)

addEventHandler("onClientResourceStop", resourceRoot, disableFollow)

function cancelDamageWhileArrested()
	cancelEvent()
end

function resetToCop(x,y,z)
	setElementPosition(localPlayer, x+1,y+1,z+1)
end

local lastPos = false
local lastVehicleWarp = false
local lastVehicleRemove = false

function onFollowCop()
	if(not isElement(cop)) then disableFollow() end 
	local px,py,pz = getElementPosition(cop)
	local x,y,z = getElementPosition(localPlayer)
	local rot = ( 360 - math.deg ( math.atan2 ( ( px - x ), ( py - y ) ) ) ) % 360
	setPedRotation(localPlayer, rot)
	setElementDimension(localPlayer, getElementDimension(cop))
	setElementInterior(localPlayer, getElementInterior(cop))
	local distance = getDistanceBetweenPoints2D(x,y,px,py)
	local heightDifference = math.abs(pz-z)
	if(heightDifference > 8) then setElementPosition(localPlayer, x,y, pz+1) end
	if(distance > 35) then
		resetToCop(px,py,pz)
	end
	local copInVehicle, inVehicle = isPedInVehicle(cop), isPedInVehicle(localPlayer)
	if(copInVehicle and not inVehicle) then -- enter vehicle
		setControlState("sprint", false)
		setControlState("forwards", false)
		setControlState("walk", false)	
		setControlState("jump", false)	
		if(not lastVehicleWarp or getTickCount()-lastVehicleWarp > 5000) then
			triggerServerEvent("USGcnr_job_police.warpIntoCopVehicle", localPlayer)
			lastVehicleWarp = getTickCount()
		end
	elseif(not copInVehicle and inVehicle) then -- exit vehicle
		setControlState("sprint", false)
		setControlState("forwards", false)
		setControlState("walk", false)	
		setControlState("jump", false)	
		if(not lastVehicleRemove or getTickCount()-lastVehicleRemove > 5000) then
			triggerServerEvent("USGcnr_job_police.removeFromVehicle", localPlayer)
			lastVehicleRemove = getTickCount()
		end
	elseif(not isPedInVehicle(localPlayer)) then -- on-foot
		local sprint = distance > 2 and distance < 35
		local forward = distance > 0.75 and distance < 35
		local walk = distance < 2
		local prevDist = lastPos and getDistanceBetweenPoints2D(x,y,lastPos.x,lastPos.y)
		if(prevDist and prevDist < 0.3 and forward and not walk) then
			setControlState("jump", true)
		else
			setControlState("jump", false)
		end
		lastPos = {x=x,y=y}

		setControlState("sprint", sprint)
		setControlState("forwards", forward)
		setControlState("walk", walk)
	end
end