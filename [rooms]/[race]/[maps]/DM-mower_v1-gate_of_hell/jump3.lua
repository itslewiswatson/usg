gMe = getLocalPlayer()
function gravity()
marker3 = createMarker ( 4472.7177734375, 4226.16796875, 5.9000000953674, "corona", 20, 0, 0, 0, 0)  
end

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker3 then
setElementVelocity ( vehicle, -1.56, 0.0, 5.0)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )