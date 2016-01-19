-- Some stats
local isPumping = false
local fuelPrice = 5
local currentMarker
local doEventHandlers

-- When the player enters a vehicle
addEventHandler ( "onClientVehicleEnter", root,
	function ( thePlayer, seat )
		if ( thePlayer == localPlayer ) and ( seat == 0 ) and exports.USGRooms:getPlayerRoom() == "cnr" then
			if ( fuelTimer ) and ( isTimer( fuelTimer ) ) then killTimer( fuelTimer ) end
			if not ( getElementData ( source, "vehicleFuel" ) ) then
				setElementData ( source, "vehicleFuel", 100 )
			elseif ( getElementData ( source, "vehicleFuel" ) <= 0 ) then
				disableVehicleFunctions( source )
			else
				enableVehicleFunctions( source )
			end

			if ( doEventHandlers ) then
				addEventHandler ( "onClientVehicleExit", source, onVehicleExitDestroy, false )
				addEventHandler ( "onClientElementDestroy", source, onVehicleExitDestroy, false )
				doEventHandlers = false
			end

			fuelTimer = setTimer ( onDecreaseFuel, 30000, 0 )
		end
	end
)

addEvent("onPlayerExitRoom", true)
function onExitRoom(room)
	if(isTimer(fuelTimer)) then killTimer(fuelTimer) end
end
addEventHandler("onPlayerExitRoom", localPlayer, onExitRoom)

-- Disable all vehicle functions whenever the vehicle has no fuel left
function disableVehicleFunctions ( theVehicle )
	if ( fuelTimer ) and ( isTimer( fuelTimer ) ) then killTimer( fuelTimer ) end
	setVehicleEngineState( theVehicle, false )
	toggleControl ( "accelerate", false )
	toggleControl ( "brake_reverse", false )
	exports.USGmsg:msg( "This vehicle has no fuel left, call a mechanic to refuel it!", 0, 225, 0 )
end

-- Enable the vehicle functions again
function enableVehicleFunctions( theVehicle )
	setVehicleEngineState( theVehicle, true )
	toggleControl ( "accelerate", true )
	toggleControl ( "brake_reverse", true )
end

-- When the resource starts
addEventHandler ( "onClientResourceStart", resourceRoot,
	function ()
		if ( getPedOccupiedVehicle ( localPlayer ) ) and ( getVehicleOccupant ( getPedOccupiedVehicle ( localPlayer ), 0 ) == localPlayer )
			and exports.USGrooms:getPlayerRoom() == "cnr" then
			doEventHandlers = true
			local theVehicle = getPedOccupiedVehicle ( localPlayer )
			if not ( getElementData ( theVehicle, "vehicleFuel" ) ) then
				setElementData ( theVehicle, "vehicleFuel", 100 )
			elseif ( getElementData ( theVehicle, "vehicleFuel" ) <= 0 ) then
				disableVehicleFunctions( theVehicle )
			end

			if ( doEventHandlers ) then
				addEventHandler ( "onClientVehicleExit", root, onVehicleExitDestroy, false )
				addEventHandler ( "onClientElementDestroy", root, onVehicleExitDestroy, false )
				doEventHandlers = false
			end

			fuelTimer = setTimer ( onDecreaseFuel, 30000, 0 )
		end
	end
)

-- Function when a vehicle gets destroyed or when a player exit the vehicle
function onVehicleExitDestroy ( theVehicle )
	local theVehicle = theVehicle or source
	if ( fuelTimer ) and ( isTimer( fuelTimer ) ) then killTimer( fuelTimer ) end

	if ( getElementData ( theVehicle, "vehicleFuel" ) ) then
		setElementData ( theVehicle, "vehicleFuel", getElementData ( theVehicle, "vehicleFuel" ) )
	end

	unbindKey ( "space", "down", onRefuelVehicle )
	unbindKey ( "space", "up", onStopRefuelVehicle )
	isPumping = false

	if ( theVehicle ) then
		removeEventHandler ( "onClientVehicleExit", theVehicle, onVehicleExitDestroy, false )
		removeEventHandler ( "onClientElementDestroy", theVehicle, onVehicleExitDestroy, false )
		doEventHandlers = true
	end
end

-- When the resource gets stopped
addEventHandler ( "onClientResourceStop", resourceRoot,
	function ()
		if ( getPedOccupiedVehicle ( localPlayer ) ) and ( getVehicleOccupant ( getPedOccupiedVehicle ( localPlayer ), 0 ) == localPlayer ) then
			onVehicleExitDestroy ( getPedOccupiedVehicle ( localPlayer ) )
		end
	end
)

-- Function that decreases the fuel
function onDecreaseFuel ()
	local theVehicle = getPedOccupiedVehicle ( localPlayer )
	if ( theVehicle ) then
		if ( getElementModel ( theVehicle ) == 509 ) or ( getElementModel ( theVehicle ) == 481 ) or ( getElementModel ( theVehicle ) == 510 ) then return end
		local theFuel = getElementData ( theVehicle, "vehicleFuel" )
		local team = getPlayerTeam( localPlayer )
		local team = team and getTeamName(team) or false
		if not ( team == "Staff" ) and ( theFuel ) and not ( isPumping ) and ( getVehicleEngineState ( theVehicle ) ) and ( theFuel > 0 ) and ( getVehicleOccupant ( getPedOccupiedVehicle ( localPlayer ), 0 ) == localPlayer ) then
			setElementData ( theVehicle, "vehicleFuel", theFuel - 1 )
			if ( getElementData ( theVehicle, "vehicleFuel" ) <= 0 ) then
				disableVehicleFunctions( theVehicle )
			end
		end
	end
end

-- Get the vehicle speed
function getVehicleSpeed ( theVehicle, unit )
	if ( unit == nil ) then unit = 0 end
	if ( isElement( theVehicle ) ) then
		local x,y,z = getElementVelocity( theVehicle )
		if ( unit=="mph" or unit==1 or unit =='1' ) then
			return ( x^2 + y^2 + z^2 ) ^ 0.5 * 100
		else
			return ( x^2 + y^2 + z^2 ) ^ 0.5 * 1.61 * 100
		end
	else
		return false
	end
end

-- When the player hits a fuel marker
function onFuelPumpMarkerHit ( hitElement, matchingDimension, msgs, theMarker )
	local theMarker = theMarker or source
	local _,_,mz = getElementPosition(theMarker)
	if ( hitElement ) and ( getElementType ( hitElement ) == "player" ) and ( matchingDimension ) 
	and ( getPedOccupiedVehicle( hitElement ) ) and ( getVehicleController( getPedOccupiedVehicle( hitElement ) ) == localPlayer ) then
		local _,_,pz = getElementPosition(hitElement)
		if(math.abs(pz-mz) > 3) then
			return
		end
		local theVehicle = getPedOccupiedVehicle( hitElement )
		if ( getVehicleSpeed ( theVehicle, "kmh" ) >= 1 ) then
			if ( msgs ~= 1 ) or ( msgs ~= 2 ) then exports.USGmsg:msg ( "Please bring the vehicle to a complete stop!", 225, 0, 0 ) end
			setTimer( onFuelPumpMarkerHit, 1000, 1, hitElement, true, 1, theMarker )
		elseif ( getVehicleEngineState( theVehicle ) ) then
			if ( msgs ~= 2 ) then exports.USGmsg:msg ( "Turn off the vehicle engine before refueling! Type /engine to toggle your engine.", 225, 0, 0 ) end
			setTimer( onFuelPumpMarkerHit, 1000, 1, hitElement, true, 2, theMarker )
		elseif ( getElementData( theVehicle, "vehicleFuel" ) >= 100 ) then
			exports.USGmsg:msg ( "Your vehicle has already enough fuel!", 225, 0, 0 )
		else
			currentMarker = theMarker
			bindKey ( "space", "down", onRefuelVehicle )
			exports.USGmsg:msg ( "Hold spacebar if you want to refuel.", 0, 255, 0 )
		end
	end
end

-- When the player hits a fuel marker
function onFuelPumpMarkerLeave ( hitElement, matchingDimension )
	if ( hitElement == localPlayer ) then
		unbindKey ( "space", "down", onRefuelVehicle )
		unbindKey ( "space", "up", onStopRefuelVehicle )

		isPumping = false
	end
end

-- When the player press the space button to refuell
function onRefuelVehicle ()
	if ( getPedOccupiedVehicle( localPlayer ) ) then
		local theVehicle = getPedOccupiedVehicle( localPlayer )
		if ( getPlayerMoney() < fuelPrice ) then
			exports.USGmsg:msg ( "You don't have enough money, the price is $" .. fuelPrice .." per litre!", 255, 0, 0 )
		else
			local oldFuel = math.floor( getElementData ( theVehicle, "vehicleFuel" ) )
			setTimer ( onRefillVehicle, 250, 1, theVehicle, oldFuel )
			exports.USGmsg:msg ( "Your vehicle is being filled, please wait...", 0, 255, 0 )

			isPumping = true

			unbindKey ( "space", "down", onRefuelVehicle )
			bindKey ( "space", "up", onStopRefuelVehicle )
		end
	else
		onStopRefuelVehicle ()
	end
end

-- Actualy refill the vehicle
function onRefillVehicle( theVehicle, oldFuel, price )
	if ( theVehicle ) and ( oldFuel ) then
		local theFuel = tonumber( oldFuel )
		local thePrice = tonumber( price ) or 0
		if not ( getKeyState ( "space" ) ) then
			onStopRefuelVehicle ( theFuel, thePrice, theVehicle )
		elseif ( getPlayerMoney() < fuelPrice ) and not ( getElementData( theVehicle, "vehicleOccupation" ) ) then
			exports.USGmsg:msg ( "You don't have enough money to continue, the price is $" .. fuelPrice .." per litre!", 255, 0, 0 )
			onStopRefuelVehicle ( theFuel, thePrice, theVehicle )
		elseif ( oldFuel >= 100 ) then
			onStopRefuelVehicle ( theFuel, thePrice, theVehicle )
		else
			theFuel = math.floor( theFuel + 1 )
			thePrice = math.floor( thePrice + 5 )
			setTimer ( onRefillVehicle, 250, 1, theVehicle, theFuel, thePrice )
			setElementData ( theVehicle, "vehicleFuel", theFuel )
		end
	end
end

-- When the player stops pressing space or stop fuel
function onStopRefuelVehicle ( theFuel, thePrice, theVehicle )
	unbindKey ( "space", "up", onStopRefuelVehicle )
	isPumping = false

	if ( theFuel ) and ( thePrice ) and not ( tostring( theFuel ) == "space" ) then
		if ( tonumber( theFuel ) < 100 ) then bindKey ( "space", "down", onRefuelVehicle ) exports.USGmsg:msg ( "Hold spacebar if you want to refuel more.", 225, 0, 0 ) end
		if ( theVehicle ) and ( getElementData( theVehicle, "vehicleOccupation" ) ) then
			exports.USGmsg:msg ( "The company you work for paid your fuel, lucky bastard.", 0, 255, 0 )
		else
			triggerServerEvent ( "CSGFuel:payment", localPlayer, thePrice )
			if ( thePrice ) then exports.USGmsg:msg ( "You paid $" .. thePrice .. " for the refilling!", 0, 255, 0 ) end
		end
	end
end

function toggleEngine()
	local theVehicle = getPedOccupiedVehicle( localPlayer )
	if ( theVehicle ) and ( getVehicleController( theVehicle ) == localPlayer ) then
		local model = getElementModel(theVehicle)
		if model ~= 509 and model ~= 481 and model ~= 510 then -- if vehicle is not a bicycle
			if ( getVehicleEngineState( theVehicle ) ) then
				setVehicleEngineState( theVehicle, false )
				exports.USGmsg:msg ( "Vehicle engine is now turned off!", 0, 255, 0 )
			elseif ( math.floor( getElementHealth( theVehicle ) ) <= 250 ) then
				exports.USGmsg:msg ( "This vehicle is broken, request a mechanic to repair it!", 0, 255, 0 )
			elseif getElementData(theVehicle,"vehicleFuel") <= 0 then
				setVehicleEngineState( theVehicle, false )
				exports.USGmsg:msg ( "*** Engine Shutdown - No Fuel ***", 255, 255, 0 )
			else
				setVehicleEngineState( theVehicle, true )
				exports.USGmsg:msg ( "Vehicle engine is now turned on!", 0, 255, 0 )
			end
		end
	end
end
-- Vehicle engine
addCommandHandler("engine",toggleEngine)
