speed = createMarker(4511.2998046875, -1894.6999511719, 50.200000762939, "corona", 10, 0, 255, 255, 0)

function boost(player)
 if getElementType(player)=="player" then
     local vehicle = getPedOccupiedVehicle(player)
        if source == speed then
           setElementVelocity(vehicle, 1, 0, 0.6) 
        end
  end
end
addEventHandler("onClientMarkerHit", resourceRoot, boost)


speed1 = createMarker(4654.1000976563, -1894.69921875, 49.200000762939, "corona", 10, 1, 1, 1, 1)

function boost(player)
 if getElementType(player)=="player" then
     local vehicle = getPedOccupiedVehicle(player)
        if source == speed1 then
            setElementVelocity(vehicle, 0, -3, 0.2)
        end
  end
end
addEventHandler("onClientMarkerHit", resourceRoot, boost)

speed2 = createMarker(4654.1000976563, -2069.6000976563, 50.200000762939, "corona", 10, 1, 1, 1, 1)

function boost(player)
 if getElementType(player)=="player" then
     local vehicle = getPedOccupiedVehicle(player)
        if source == speed2 then
            setElementVelocity(vehicle, -1, 0, 0.403)
        end
  end
end
addEventHandler("onClientMarkerHit", resourceRoot, boost)

speed3 = createMarker(3421.1000976563, -2063.19921875, 20.60000038147, "ring", 2, 1, 1, 1, 1)

function boost(player)
 if getElementType(player)=="player" then
     local vehicle = getPedOccupiedVehicle(player)
        if source == speed3 then
            setElementVelocity(vehicle, 2, 0, 1.91)
        end
  end
end
addEventHandler("onClientMarkerHit", resourceRoot, boost)