Me = getLocalPlayer()
Root = getRootElement()
local screenWidth, screenHeight = guiGetScreenSize() -- Get the screen resolution

function Main () 
marker1 = createMarker( 4161, -2720.099609375, 55.5, 'corona', 3, 0, 0, 0, 0 )
addEventHandler ( "onClientMarkerHit", getRootElement(), MainFunction )
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), Main )


function MainFunction ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= Me then return end
	if source == marker1 then
			setVehicleFrozen ( vehicle , true )
			setElementPosition (vehicle , 4025.3000488281, 53.299999237061, 111.30000305176, 'corona', 3, 0, 0, 0, 0  )
			setElementRotation (vehicle , 0, 0, 163.99993896484 )
			setTimer( setVehicleFrozen, 1000, 1, vehicle, false )
	end
end

