gMe = getLocalPlayer()
function gravity()
marker1 = createMarker (4192.12109375, -4965.8544921875, 4.138876914978, "corona", 15, 0, 0, 0, 0)
marker2 = createMarker (4340.7534179688, -4498.67578125, 91.209121704102, "corona", 3, 0, 0, 0, 0)
marker3 = createMarker (4599.302734375, -3696.2958984375, 14.711935997009, "corona", 10, 0, 0, 0, 0)
marker4 = createMarker (5840.4453125, -3974.5280761719, 6.0353240966797, "corona", 5, 0, 0, 0, 0)
marker5 = createMarker (5839.4189453125, -3319.4079589844, 2.6520404815674, "corona", 5, 0, 0, 0, 0)
marker6 = createMarker (8071.873046875, -3906.4123535156, 1, "corona", 5, 0, 0, 0, 0)
end

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker1 then
setElementVelocity ( vehicle, 1.5, 1, 1)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker2 then
setElementVelocity ( vehicle, 0, 1, 1)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker3 then
setElementVelocity ( vehicle, 1.5, 1, 1.6)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker4 then
setElementVelocity ( vehicle, 0, 2, 2)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker5 then
setElementVelocity ( vehicle, 0, -3, 3)
end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )

function MarkerHit ( hitPlayer, matchingDimension )
vehicle = getPedOccupiedVehicle ( hitPlayer )
if hitPlayer ~= gMe then return end
if source == marker6 then
setElementVelocity ( vehicle, 0, -1, 1)
end
end


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), gravity )
addEventHandler ( "onClientMarkerHit", getRootElement(), MarkerHit )