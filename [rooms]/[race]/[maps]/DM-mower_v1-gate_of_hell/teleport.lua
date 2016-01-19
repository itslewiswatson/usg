marker = createMarker(8125, -3071.69921875, 1581.1999511719, 'corona', 5, 0, 0, 255, 255)

function MarkerHit(player)
if getElementType(player) == 'player' then
local vehicle = getPedOccupiedVehicle(player)
if source == marker then
setElementPosition(vehicle, 4010.69921875, 90.298828125, 454.29998779297)
setElementRotation(vehicle, 0, 0, 0)
setElementFrozen(vehicle, true)
setTimer(setElementFrozen, 1000, 1, vehicle, false)
end
end
end
addEventHandler('onClientMarkerHit', getRootElement(), MarkerHit)