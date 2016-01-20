local colLV = createColRectangle(866,480,2300,2800)

function isElementWithinSafeZone(element)
    if (not isElement(element)) then return false end
    if (getElementDimension(element) ~= 0) or (getElementInterior(element) ~= 0) then return false end
    if (isElementWithinColShape(element, colLV )) then return true end
    return false
end

function zoneEntry(element, matchingDimension)
    if (element ~= localPlayer) or (not matchingDimension) then return end
    if (getElementDimension(element) ~= 0) then return end
    setGameSpeed(1.22)
    exports.USGmsg:msg("You just entered LV, the game speed changed to 1.22.")

end
addEventHandler("onClientColShapeHit", colLV , zoneEntry)

function zoneLeave(element, matchingDimension)
    if (element ~= localPlayer) or (not matchingDimension) then return end
    if (getElementDimension(element) ~= 0) then return end
    setGameSpeed(1.05)
    exports.USGmsg:msg("You just left LV, the game speed is normal now.")

end
addEventHandler("onClientColShapeLeave", colLV , zoneLeave)