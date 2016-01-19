local HeliSpawnX,HeliSpawnY,HeliSpawnZ,HeliSpawnROT = -284.4208984375, 1530.4375, 76.072448730469, 315.11193847656

local drugsPrize = 30
local drugPrizePerKill = 10

local DoorID,DoorClosedX,DoorClosedY,DoorClosedZ,DoorClosedROT,DoorOpenX,DoorOpenY,DoorOpenZ,Time = 10841, -1949, -1035.5996, 34.9, 179.995, -1949.5996, -1035.5996, 10,5000
local door = createObject (DoorID,DoorClosedX,DoorClosedY,DoorClosedZ, 0, 0, DoorClosedROT )
local DoorOpen = false

local isEventActive = false

local helicopter
local driver
local waypoint
local waypointBlip
local colshape

local timer

local GlobalTimer
local ID = 1

local Digit1,Digit2,Digit3,Digit4

local function messageCNR(message, r, g, b)
    for k, player in ipairs(getElementsByType("player")) do
        if (exports.USGrooms:getPlayerRoom(player) == "cnr") then
            exports.USGmsg:msg(player, message, r, g, b, 5000)
        end
    end
end

local function messageMedics(message, r, g, b)
	for k, medics in pairs(getElementsByType("player")) do
		if (exports.USGrooms:getPlayerRoom(medics) == "cnr") then
			if (exports.USGcnr_jobs:getPlayerJob(medics) == "medic") then
				exports.USGmsg:msg(medics, message, r, g, b, 5000)
			end
		end
	end
end


function toggleDoor(state)
    if (state == "close") then
        moveObject(door,Time,DoorClosedX,DoorClosedY,DoorClosedZ)
        DoorOpen = false
    elseif (state == "open") then
        moveObject(door,Time,DoorOpenX,DoorOpenY,DoorOpenZ)
        DoorOpen = true
    end
end

function isDoorOpen()
    return DoorOpen
end

function onDeathLoose()
	messageCNR("The paramedic transporting the medicines has been killed!",255,255,255)
	loose()
end

function start()
	isEventActive = false

    if(isElement(helicopter))then
    	destroyElement(helicopter)
    end

    if(isElement(colshape))then
    	destroyElement(colshape)
    end

    if(isTimer(timer))then
    	killTimer(timer)
    end

    destroyWaypoint()
    driver = nil
    Digit1 = nil
    Digit2 = nil
    Digit3 = nil
    Digit4 = nil
    toggleDoor("open")
    removeEventHandler( "onPlayerWasted", root, copReward )
	
    colshape = createColCuboid ( -2113.16796875, -1267.42578125, 20, 400, 600, 100 )
    addEventHandler ( "onPlayerWasted", root, copReward )
    
    helicopter = createVehicle ( 563, HeliSpawnX,HeliSpawnY,HeliSpawnZ,0,0,HeliSpawnROT)
    setElementFrozen(helicopter,true)
    
    waypointBlip = createBlipAttachedTo ( helicopter, 41)
    for k, player in ipairs(getElementsByType("player")) do
        if (not exports.USGrooms:getPlayerRoom(player) == "cnr") then
        	setElementVisibleTo ( waypointBlip, player, false )     
        end 
    end

    local x,y,z = getElementPosition(helicopter)
    messageCNR("A delivery of medicine needs transporting from ".. getZoneName(x,y,z) .." by a Paramedic to San Fierro complex!",255,255,255)
    messageMedics("Get to the helicopter located in ".. getZoneName(x,y,z) .. " (marked with a red blip in the Desert)",255,255,255)
    
    addEventHandler ( "onVehicleStartEnter", helicopter, 
    	function(player)
	        if (exports.USGcnr_jobs:getPlayerJob(player) ~= "medic") then
	        	exports.USGmsg:msg(player, "Only a paramedic is allowed to enter this helicopter.", 255,255,255)
	        	cancelEvent()
	        end
    	end 
    )
    
    addEventHandler ( "onVehicleEnter", helicopter, 
    	function(p,seat)
	        if (seat == 0) then
	        	destroyWaypoint()
	       		waypoint = createMarker( -2026.4521484375, -986.3203125, 32,"cylinder", 10, 255, 255, 255, 50,p)
	        	waypointBlip = createBlipAttachedTo ( waypoint, 41, _, _, _,_ ,_, _, _,p )
	        	messageCNR("A paramedic entered the transport helicopter and is heading toward San Fierro complex.",255,255,255)
	        	exports.USGmsg:msg(p, "Fly to the red blip marked on your map (South San Fierro).", r, g, b, 5000)
	            setElementFrozen(helicopter,false)
	            driver = p
	            addEventHandler ( "onPlayerWasted", driver, onDeathLoose)
	            
	            addEventHandler ( "onVehicleExit", helicopter, 
	            	function(p,seat)
		                if (seat == 0) then
		                    if (isElementWithinMarker(helicopter,waypoint) and isVehicleOnGround ( helicopter )) then
		                    	messageCNR("The paramedic delivered the medicine to SF complex and is now unloading them!",255,255,255)
		                    	exports.USGmsg:msg(p, "Head into the building marked with a red blip and enter the white marker.", r,g,b, 5000)
		                        destroyWaypoint()

		                        addEventHandler ( "onVehicleStartEnter", helicopter, 
		                        	function()
		                            	cancelEvent()
		                        	end 
		                        )
		                        setElementVelocity ( helicopter,0,0,0 )
		                        setElementFrozen(helicopter,true)
		                        setVehicleDamageProof(helicopter,true)
		                        toggleDoor("open")
		                        waypoint = createMarker(-1948.2607421875, -1079.0693359375, 30,"cylinder", 1, 255, 255, 255, 50,p)
		                        waypointBlip = createBlipAttachedTo ( waypoint, 41, _, _, _,_ ,_, _, _,p )
		                        addEventHandler( "onMarkerHit", waypoint, 
		                        	function(p)
		                                if(p == driver)then
		                                	destroyWaypoint()
		                                	waypoint = createMarker(-1949, -1033.517578125, 31.5,"cylinder", 1, 255, 255, 255, 50,p)
		                                	waypointBlip = createBlipAttachedTo ( waypoint, 41, _, _, _,_ ,_, _, _,p )
		                                	exports.USGmsg:msg(p, "Go to the white marker outside.", r, g, b, 5000)

		                                    addEventHandler( "onMarkerHit", waypoint, 
		                                    	function(p)
			                                        if(p == driver)then
			                                        destroyWaypoint()
			                                        toggleDoor("close")
			                                        setElementFrozen(p,true)
			                                            setTimer( function()
			                                            	setElementFrozen(driver,false)
			                                            	activateEvent()
			                                            	removeEventHandler ( "onPlayerWasted", driver, onDeathLoose)
			                                            	messageCNR("The medicine has been unloaded and the hangar has been sealed!",255,255,255)
														    exports.USGcnr_medicines:givePlayerMedicines(driver,"Steroid",drugsPrize)
															exports.USGcnr_medicines:givePlayerMedicines(driver,"Aspirin",drugsPrize)
															exports.USGmsg:msg(driver,"You have received "..tostring(drugsPrize).." of each medicine",255,255,255, 5000)
			                                            end,Time,1)
			                                        end
		                                    	end
		                                    )
		                                end
		                            end
		                        )
		                    else 
								messageCNR("The paramedic exited the helicopter before getting to the destination!",255,255,255)
								loose()
		                    end
		                end
	            	end
	            )
	        end
    	end
    )    

    addEventHandler("onVehicleExplode", helicopter, 
    	function()
			messageCNR("The helicopter transporting the medicine has blown up!",255,255,255)
			loose()
		end
	)
end

function activateEvent()
	isEventActive = true
	Digit1 = math.random(1,3)
	Digit2 = math.random(1,3)
	Digit3 = math.random(1,3)
	Digit4 = math.random(1,3)

	timer = setTimer(
		function()
			for k, player in ipairs(getElementsByType("player")) do
			    if (exports.USGrooms:getPlayerRoom(player) == "cnr" and isElementWithinColShape(player,colshape) and isEventActive) then
			        if (exports.USGcnr_jobs:getPlayerJob(player) == "police" or exports.USGcnr_jobs:getPlayerJob(player) == "medic") then
			        	exports.USGcnr_medicines:givePlayerMedicines(player,"Steroid",drugsPrize)
			        	exports.USGcnr_medicines:givePlayerMedicines(player,"Aspirin",drugsPrize)
			        	exports.USGmsg:msg(player,"You have received "..tostring(drugsPrize).." of each medicine for successfully defending the medicines",255,255,255, 5000)
			        end
			    end 
			end
			loose()
		end
	,5 * 60 * 1000,1)

	waypoint = createMarker(-1949, -1032, 31.5,"cylinder", 1, 255, 0, 0, 50)
	waypointBlip = createBlipAttachedTo ( waypoint, 41)

    for k, player in ipairs(getElementsByType("player")) do
        if (not exports.USGrooms:getPlayerRoom(player) == "cnr") then
       		setElementVisibleTo ( waypoint, player, false )
        	setElementVisibleTo ( waypointBlip, player, false )     
        end 
    end

    addEventHandler( "onMarkerHit", waypoint, 
    	function(p)
	        if (exports.USGcnr_jobs:getPlayerJob(p) == "criminal") then
	        	showPanel(p)
	        	exports.USGcnr_wanted:givePlayerWantedLevel(p,5)
	        	addEventHandler ( "onPlayerWasted", p, hidePanelDead)
	        end
    	end
    )

    addEventHandler( "onMarkerLeave", waypoint, 
    	function(p)
        	if(exports.USGcnr_jobs:getPlayerJob(p) == "criminal")then
        		hidePanel(p)
        		removeEventHandler ( "onPlayerWasted", p, hidePanelDead)
        	end
    	end
    )
end

function corretPass()
    if (isTimer(timer)) then
        killTimer(timer)
    end

    for k, player in ipairs(getElementsByType("player")) do
        if (exports.USGrooms:getPlayerRoom(player) == "cnr") then
       		hidePanel(player)
        end 
    end

    messageCNR(getPlayerName(client).." managed to hack the main door, criminals now have 15 seconds to gather what they can!",255,255,255)
    destroyWaypoint()
    toggleDoor("open")
    
    waypoint = createMarker(-1948.2607421875, -1079.0693359375, 30,"cylinder", 3, 255, 0, 0, 50)
    waypointBlip = createBlipAttachedTo ( waypoint, 41)

    local rewardedPlayers = {}
    for k, player in ipairs(getElementsByType("player")) do
        if (not exports.USGrooms:getPlayerRoom(player) == "cnr") then
        	setElementVisibleTo ( marker, player, false )
        	setElementVisibleTo ( blip, player, false )     
        end 
    end

    addEventHandler( "onMarkerHit", waypoint, 
    	function(p)
	        if (exports.USGrooms:getPlayerRoom(p) == "cnr" and isEventActive) then
	            if (exports.USGcnr_jobs:getPlayerJob(p) == "criminal") then
	                hidePanel(p)

	                if (not rewardedPlayers[p]) then
	                	exports.USGcnr_medicines:givePlayerMedicines(p,"Steroid",drugsPrize)
	                	exports.USGcnr_medicines:givePlayerMedicines(p,"Aspirin",drugsPrize)
	                	exports.USGcnr_wanted:givePlayerWantedLevel(p,15)
	                	exports.USGmsg:msg(p,"You have received "..tostring(drugsPrize).." of each medicine",255,255,255)
	                	rewardedPlayers[p] = true
	                end
	            end
	        end
    	end
    )

    setTimer(
    	function()
			driver = nil
			loose()
		end
	,15 * 1000,1)
end
addEvent("USGcnr_medicinerob.onPanelHacked",true)
addEventHandler("USGcnr_medicinerob.onPanelHacked",root,corretPass)

function hidePanelDead()
	hidePanel(source)
end

function showPanel(p)
	triggerClientEvent ( p, "USGcnr_medicinerob.HackPanel.show",resourceRoot,Digit1,Digit2,Digit3,Digit4)
end

function hidePanel(p)
	triggerClientEvent ( p, "USGcnr_medicinerob.HackPanel.hide",resourceRoot)
end

function loose()
    isEventActive = false

    if (isElement(helicopter)) then
    	destroyElement(helicopter)
    end

    if (isElement(colshape)) then
    	destroyElement(colshape)
    end

    if (isTimer(timer)) then
    	killTimer(timer)
    end

    destroyWaypoint()
    driver = nil
    Digit1 = nil
    Digit2 = nil
    Digit3 = nil
    Digit4 = nil
    toggleDoor("open")
    removeEventHandler( "onPlayerWasted", root, copReward )
	messageCNR("The event is now over",255,255,255)
    GlobalTimer = setTimer(start,1.5 * 60 * 60 * 1000,1)
end

function destroyWaypoint()
    if (isElement(waypoint)) then
    	destroyElement(waypoint)
    end

    if (isElement(waypointBlip)) then
   		destroyElement(waypointBlip)
    end
end

addEventHandler("onPlayerAttemptChangeJob",root,
	function(jobID)
	    if (isElement(colshape)) then
	        if (isElementWithinColShape(source,colshape)) then
	            if (jobID == "criminal") then
	            	exports.USGmsg:msg(source,"You cannot change side during an event!",255,255,255)
	            	cancelEvent()
	            end
	        end
	    end
	end
)

function copReward(ammo,killer)
    if (isElementWithinColShape(source,colshape) and isElementWithinColShape(killer,colshape)) then
        if (exports.USGcnr_jobs:getPlayerJob(killer) == "police" and exports.USGcnr_wanted:getPlayerWantedLevel(source) > 0) then
            exports.USGcnr_medicines:givePlayerMedicines(killer,"Steroid",drugPrizePerKill)
            exports.USGcnr_medicines:givePlayerMedicines(killer,"Aspirin",drugPrizePerKill)
            exports.USGmsg:msg(killer,"You received "..tostring(drugPrizePerKill).." of each medicine for killing "..getPlayerName(source),255,255,255, 5000)
        end
    end
end

addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGEventsApp (re)started
        if(res == resource or res == getResourceFromName("USGEventsApp")) then
        
        end 

		if(res == resource)then
			start()
		end
    end
)

addEventHandler ( "onResourceStop", resourceRoot, 
    function (  )

   	end 
) 