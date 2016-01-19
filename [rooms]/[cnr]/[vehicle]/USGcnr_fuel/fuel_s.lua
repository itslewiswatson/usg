-- Event that let the drive pay for the refueling
addEvent ( "CSGFuel:payment", true )
addEventHandler ( "CSGFuel:payment", root,
	function ( thePrice )
		--if ( exports.CSGgift:getChristmasDay() ~= "Day24" ) then thePrice = 0 end
		takePlayerMoney ( source, thePrice )
	end
)

-- Exports to set vehicle fuel
function setVehicleFuel ( theVehicle, theFuel )
	if ( theVehicle ) and ( isElement( theVehicle ) ) and ( theFuel ) then
		setElementData ( theVehicle, "vehicleFuel", theFuel )
		return true
	else
		return false
	end
end

-- Exports to get vehicle fuel
function getVehicleFuel ( theVehicle )
	if ( theVehicle ) and ( isElement( theVehicle ) ) then
		return getElementData ( theVehicle, "vehicleFuel" )
	else
		return false
	end
end
