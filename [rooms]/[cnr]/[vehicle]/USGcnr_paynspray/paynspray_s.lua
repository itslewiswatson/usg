local locations = {
    { x = 2065.3740234375, y = -1831.6474609375, z = 12.546875 },
    { x = 487.5439453125, y = -1740.48828125, z = 10.136220932007 },
    { x = 1024.7451171875, y = -1025.220703125, z = 31.1015625 },
    { x = 720.1123046875, y = -457.896484375, z = 15.3359375 },
    { x = -1904.396484375, y = 284.01171875, z = 40.046875 },
    { x = -2425.8349609375, y = 1022.4677734375, z = 49.397659301758 },
    { x = -1420.556640625, y = 2586.7607421875, z = 54.84326171875 },
    { x = -99.85546875, y = 1115.9736328125, z = 18.74169921875 },
    { x = 1973.890625, y = 2162.375, z = 10.0703125 },
    { x = 1865.9, y = -2382.12, z = 12.55 },
    { x = 1582.32, y = 1449.54, z = 9.39 },
    { x = -1261.89, y = -40.52, z = 13.14 },
    { x = 365.4, y = 2536.95, z = 15.66  },
}

addEventHandler("onResourceStart",resourceRoot,
    function ()
        for i, location in ipairs(locations) do
            local marker = createMarker(location.x, location.y, location.z, "cylinder", 4, 200, 0, 0, 255)

            createBlip(location.x,location.y,location.z,63, 2, 255,255,255,255,0,500)
            addEventHandler("onMarkerHit",marker,onSprayMarkerHit)
        end
        setGarageOpen(8, true)
        setGarageOpen(11, true)
        setGarageOpen(12, true)
        setGarageOpen(19, true)
        setGarageOpen(27, true)
        setGarageOpen(32, true)
        setGarageOpen(36, true)
        setGarageOpen(40, true)
        setGarageOpen(41, true)
        setGarageOpen(47, true)
    end
)

function arePanelsDamaged(vehicle)
    for i=0,6 do
        local panel = getVehiclePanelState(vehicle,i)
        if panel > 0 then
            return true
        end
    end
    return false
end

function areWheelsDamaged(vehicle)
    local wheels = {getVehicleWheelStates(vehicle)}
    for i=1,4 do
        if wheels[i] > 0 then
            return true
        end
    end
    return false
end

function onSprayMarkerHit(hitElement, dimensions)
    if(getElementType(hitElement) ~= "vehicle" or not getVehicleController(hitElement) or not dimensions) then return end
    local driver = getVehicleController(hitElement)
    local health = getElementHealth(hitElement)
    local weels = areWheelsDamaged(hitElement)
    local panels = arePanelsDamaged(hitElement)
    if(health < 1000 or wheels or panels) then
        local price = (1000-health)
        if(wheels) then price = price + 50 end
        if(panels) then price = price + 50 end
        if(exports.USGcnr_money:buyItem(driver, price, "a fix for a vehicle")) then
            fixVehicle(hitElement)
            setElementFrozen(hitElement, true)
            fadeCamera(driver, false)
            setTimer(onVehicleFixed, 1500, 1, hitElement, driver)
        end
    else
        exports.USGmsg:msg(driver, "This vehicle does not need to be fixed.", 255,128,0)
    end
end

function onVehicleFixed(vehicle, driver)
    if(isElement(vehicle)) then
        setElementFrozen(vehicle, false)
    end
    if(isElement(driver)) then
        fadeCamera(driver, true)
    end
end