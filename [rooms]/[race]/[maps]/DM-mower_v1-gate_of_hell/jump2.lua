gMe = getLocalPlayer()
function gravity()
marker2 = createMarker ( 4329.2001953125, 4345.2001953125, 5.9000000953674, "corona", 20, 0, 0, 0, 0)  
end

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker2 then
setElementVelocity ( vehicle, 0.66, -0.47, 0.9)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )