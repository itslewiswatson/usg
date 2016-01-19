local screenWidth, screenHeight = guiGetScreenSize()
local BAR_WIDTH = screenWidth
local BAR_HEIGHT = 15

local BAG_CLEAN_TIME = 30000
local ROB_INTERVAL = 300000
local ROB_DURATION = 10000
local ROB_BAG_REWARD = 7500

local STATE_IDLE = 0
local STATE_ROBBING = 1
local STATE_COLLECTING = 2

function findPointFromDistanceRotation(x,y, angle, dist)
	local angle = math.rad(angle+90)
	return x+(dist * math.cos(angle)), y+(dist * math.sin(angle))
end

function initRobShop()
	initLocations()
	addEventHandler("onClientPlayerTarget", localPlayer, onPlayerTarget)
end

function unloadRobShop()
	if(ROB_STATE == STATE_ROBBING) then
		stopRobbing()
	end
	removeLocations()
	removeEventHandler("onClientPlayerTarget", localPlayer, onPlayerTarget)
end


local lastRob = 0
local ROB_STATE = STATE_IDLE
local robLocation
local moneyRobbed = 0

local robEnd

local lastAttemptTick = 0
function onPlayerTarget(target)
	if(source ~= localPlayer) then return end
	local location = pedLocation[target]
	if(location) then	
		if(getControlState("aim_weapon") == false) then return end
		if(ROB_STATE ~= STATE_IDLE) then return end
		if(lastAttemptTick and getTickCount() - lastAttemptTick < 1000) then
			return
		end
		lastAttemptTick = getTickCount()
		local jobType = exports.USGcnr_jobs:getPlayerJobType(localPlayer)
		if(jobType ~= "criminal") then
			exports.USGmsg:msg("Only criminals can rob stores!", 255, 0, 0)
			return
		end	
		startRobbingLocation(location)
	end
end

addEvent("onPlayerChangeJob", true)
addEvent("onPlayerArrested", true)
function startRobbingLocation(location)
	if(ROB_STATE ~= STATE_IDLE) then return false end
	if(lastRob and getTickCount() - lastRob < ROB_INTERVAL) then
		exports.USGmsg:msg("You robbed a shop too recently.", 255, 0, 0)
		setControlState("aim_weapon", false)
		return false
	end
	moneyRobbed = 0
	lastRob = getTickCount()
	robLocation = location
	ROB_STATE = STATE_ROBBING
	robEnd = getTickCount()+ROB_DURATION
	addEventHandler("onClientRender", root, validateAimTarget)
	addEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)
	addEventHandler("onClientPlayerWasted", localPlayer, onWasted)
	addEventHandler("onPlayerArrested", localPlayer, onArrested)
	setPedAnimation(location.ped, "ped", "handsup",-1,false,false,false,true)
end

function stopRobbing()
	if(ROB_STATE == STATE_ROBBING) then
		removeEventHandler("onClientRender", root, validateAimTarget)
		removeEventHandler("onPlayerChangeJob", localPlayer, onChangeJob)
		removeEventHandler("onClientPlayerWasted", localPlayer, onWasted)
		removeEventHandler("onPlayerArrested", localPlayer, onArrested)
	end
	setPedAnimation(robLocation.ped)
	setPedAnimation(robLocation.ped, "ped", "handscower",-1,false,false,false,false)
	robLocation = nil
	ROB_STATE = STATE_IDLE
end

function onArrested()
	if(ROB_STATE == STATE_ROBBING) then
		stopRobbing()
	end
end

function onWasted()
	if(ROB_STATE == STATE_ROBBING) then
		stopRobbing()
	end
end

function onChangeJob()
	if(ROB_STATE == STATE_ROBBING) then
		stopRobbing()
		exports.USGmsg:msg("You failed to rob this shop because your job changed!", 255, 0, 0)
	end
end

function onRobAimTargetInvalid(giveReward)
	if(giveReward) then
		onRobComplete()
	else
		stopRobbing()
		exports.USGmsg:msg("You failed to keep the cashier in your sights!", 255, 0, 0)
	end
end

local color_bar_bg = tocolor(0,0,0,200)
local color_bar = tocolor(0,200,0)
local color_text = tocolor(110,110,255)
function validateAimTarget()
	local target = getPedTarget(localPlayer)
	if(not getControlState("aim_weapon") or target ~= robLocation.ped) then
		local timeSinceRob = getTickCount() - lastRob
		if(timeSinceRob > 1000) then
			onRobAimTargetInvalid(timeSinceRob > 2000)
			return
		end
	end
	local progress = 1-(robEnd-getTickCount())/ROB_DURATION
	if(progress >= 1) then
		moneyRobbed = ROB_BAG_REWARD
		onRobComplete()
	else
		moneyRobbed = math.floor(progress * ROB_BAG_REWARD)
		dxDrawRectangle(0,screenHeight-BAR_HEIGHT,BAR_WIDTH,BAR_HEIGHT,color_bar_bg)
		dxDrawRectangle(2,screenHeight-BAR_HEIGHT+2,math.floor((BAR_WIDTH-4)*progress),BAR_HEIGHT-4,color_bar)
		dxDrawText("money robbed: "..exports.USG:formatMoney(moneyRobbed), 0, screenHeight-BAR_HEIGHT, BAR_WIDTH, screenHeight, color_text, 0.5,"bankgothic","center","center")
	end
end

function onRobComplete()
	exports.USGmsg:msg("Collect the money bags!", 0, 255, 0)
	-- create bags
	local px,py,pz = robLocation.x, robLocation.y, robLocation.z
	local angle = robLocation.rz
	local x,y = findPointFromDistanceRotation(px,py,angle,1)
	local z = pz+0.3
	local pickup = createPickup(x,y,z,3,1550)
	setElementDimension(pickup, getElementDimension(localPlayer))
	setElementInterior(pickup, robLocation.int)
	addEventHandler("onClientPickupHit", pickup, onBagHit)
	setTimer(removeBag, BAG_CLEAN_TIME, 1, pickup)
	-- clean it up
	stopRobbing()
end

function removeBag(bag)
	if(isElement(bag)) then
		destroyElement(bag)
	end
end

function onBagHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	destroyElement(source)
	triggerServerEvent("USGcnr_robshop.onRobComplete", localPlayer, moneyRobbed)
	exports.USGmsg:msg("You picked up "..exports.USG:formatMoney(moneyRobbed).."!", 0, 255, 0)
	exports.USGmsg:msg("You picked up Aspirin & Steroid!", 0, 255, 0)
end


addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
	function (room)
		if(room == "cnr") then
			initRobShop()
		end
	end
)
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
	function (prevRoom)
		if(prevRoom == "cnr") then
			unloadRobShop()
		end
	end
)
addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
			initRobShop()
		end
	end
)