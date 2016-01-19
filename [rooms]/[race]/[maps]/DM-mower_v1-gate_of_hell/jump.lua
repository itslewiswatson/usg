gMe = getLocalPlayer()
function gravity()
marker1 = createMarker ( 4138.7001953125, 4201.3999023438, 5.9000000953674, "corona", 20, 0, 0, 0, 0)   
end

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker1 then
setElementVelocity ( vehicle, 0.9, 0.7, 0.9)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )