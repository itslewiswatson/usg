-- *** initializing and unloading ***
function initJob()
    if(getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
        exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
    end
end

addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
        if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
            initJob()
        end
    end
)

--mechanic target
function onMechanicTarget (thePlayer)
local target = getPlayerTarget (thePlayer)
if (exports.USGcnr_jobs:getPlayerJob(thePlayer) == "Mechanic") then
    if getPedWeapon(thePlayer) == 0 and not isPedInVehicle(thePlayer) then
        if isElement (target) and getElementType (target) == "vehicle" then
            local x, y, z = getElementPosition(thePlayer)
            local tx, ty, tz = getElementPosition(target)
            if getDistanceBetweenPoints2D ( x, y, tx,ty ) < 5 then
                vehicleOwner = exports.USGcnr_pvehicles:getVehicleOwner(target)
                if isElement(vehicleOwner) and (getElementType(vehicleOwner) == "player" ) then
                    local sx, sy, sz = getElementVelocity(target)  
                    local speed = (sx^2 + sy^2 + sz^2)^(0.5)*100
                    if speed < 5 then
                        if (( wheel1 == 0 ) and ( wheel2 == 0 ) and ( wheel3 == 0 ) and ( wheel4 == 0 )) and (getElementHealth(target) > 999) then
                            exports.USGmsg:msg(thePlayer,"This vehicle doesn't need a repair!",  225, 0, 0)
                        else    
                            triggerClientEvent(vehicleOwner, "showPanel2", vehicleOwner, thePlayer, target)
                            setElementFrozen(target,true)
                            vehicle = target
                            setElementFrozen(thePlayer,true)
                            exports.USGmsg:msg(thePlayer, "Waiting for response", 0, 255, 0)
                        end
                    end
                else    
                    exports.USGmsg:msg(thePlayer, "This vehicle doesn't have an owner", 0, 255, 0)
                end
            end
        end
    end
end
end
--bind aim
function bindAim()
    bindKey (source,"aim_weapon","down", onMechanicTarget)
end
addEvent("bindAim", true)
addEventHandler ("onPlayerLogin",root,bindAim)
addEventHandler("bindAim", root, bindAim)

--reject msg
function rejectRequest (mechanic,vehicle)
    exports.USGmsg:msg(mechanic, " " .. getPlayerName(source) .. " doesn't want to repair his vehicle", 200, 0, 0)
    if isElement(vehicle) then setElementFrozen(vehicle,false) end
    setElementFrozen(mechanic,false)
    setPedAnimation(mechanic,false)
end
addEvent("rejectRequest", true)
addEventHandler("rejectRequest", root, rejectRequest)


--hood open
function hood(theVehicle)
    if not theVehicle then return end
    openratio = getVehicleDoorOpenRatio( theVehicle,0)
    if openratio < 1 then   
        state =  setVehicleDoorOpenRatio ( theVehicle,0,1,1000)
    else
        state =  setVehicleDoorOpenRatio ( theVehicle,0,0,1000)
    end
end

--wheel repair
function wheelRepair (mechanic, vehicle)
    local wheel1, wheel2, wheel3, wheel4 = getVehicleWheelStates ( vehicle )
    if ( wheel1 == 1 ) or ( wheel2 == 1 ) or ( wheel3 == 1 ) or ( wheel4 == 1 ) then
        setPedAnimation(mechanic, "gangs", "hndshkaa")
        psource = source
        setTimer(function()
        if (mechanic == psource) and (getPlayerMoney(psource) > 200) then 
            setVehicleWheelStates ( vehicle, 0, 0, 0, 0 )
            takePlayerMoney(psource,200)
            setVehicleDamageProof ( vehicle, false )
            setElementFrozen(vehicle,false)
            setElementFrozen(mechanic,false)
            setPedAnimation(mechanic,false)
            exports.USGmsg:msg(mechanic,"You repaired the wheels of your vehicle, you paid $200.", 0, 225, 0)
        elseif (mechanic ~= psource) and (getPlayerMoney(psource) > 300) then
            setVehicleWheelStates ( vehicle, 0, 0, 0, 0 )
            local currentJobRank = exports.USGcnr_jobranks:getPlayerJobRank(client, "Mechanic")
            local rankBonus = exports.USGcnr_jobranks:getPlayerJobBonus(client, "Mechanic", currentJobRank)
            local payment = 300
            takePlayerMoney(psource, payment)
            givePlayerMoney(mechanic, payment + rankBonus)
            local expAmount = payment/3
            exports.USGcnr_jobranks:givePlayerJobExp(client, "Mechanic", expAmount)
            setVehicleDamageProof ( vehicle, false )
            setElementFrozen(vehicle,false)
            setElementFrozen(mechanic,false)
            setPedAnimation(mechanic,false)
            exports.USGmsg:msg(mechanic,"You repaired the wheels of " .. getPlayerName(psource) .. ", you earned $" .. (payment + rankBonus) .. " and " .. expAmount .. " exp.", 0, 225, 0)
            exports.USGmsg:msg(psource,"You have paid $300 for repairing your vehicle wheels.", 0, 225, 0)
        else
            exports.USGmsg:msg(psource,"You don't have enough money to repair your wheels.", 225, 0, 0)
            setElementFrozen(vehicle,false)
            setElementFrozen(mechanic,false)
            setPedAnimation(mechanic,false)
        end
        end,4000,1)
    else
        exports.USGmsg:msg(source,"Your vehicle wheels are not damaged.", 225, 0, 0)
        setElementFrozen(vehicle,false)
        setElementFrozen(mechanic,false)
        setPedAnimation(mechanic,false)
    end
end
addEvent("wheelRepair", true)
addEventHandler("wheelRepair", root, wheelRepair)


--vehicle repair
function vehicleRepair(mechanic, vehicle)
    if (getElementHealth(vehicle) < 999) then
        local price = round(math.floor((1000-getElementHealth(vehicle))+((getElementHealth(vehicle)+1)/10)) * 2)
        if (getElementHealth(vehicle) < 500) then price = price + 400 end
        setPedAnimation(mechanic, "gangs", "hndshkaa")
        if isTimer(tmt) then killTimer(tmt) end
        setVehicleDoorState(vehicle, 0, 2)
        hood(vehicle)
        psource = source
        setTimer(function()
        if getPlayerMoney(psource) > price then
            fixVehicle ( vehicle )
            if isTimer(tmt) then killTimer(tmt) end
            setVehicleDoorState(vehicle,0,0)
            local rx, ry, rz = getVehicleRotation ( vehicle )
            if ( rx > 110 ) and ( rx < 250 ) then
                local x, y, z = getElementPosition ( vehicle )
                setVehicleRotation(vehicle, rx + 180, ry, rz )
                setElementPosition(vehicle, x, y, z + 2 )
            end
            if psource == mechanic then
                takePlayerMoney(psource, price/2)
                exports.USGmsg:msg(psource,"You have paid $" ..(round(price/2)).. " for repairing your vehicle", 0, 225, 0)
            else
                takePlayerMoney(psource, price)
                givePlayerMoney(mechanic, price)
                exports.USGmsg:msg(psource,"You have paid $" ..price.. " for repairing your vehicle", 0, 225, 0)
                exports.USGmsg:msg(mechanic,"You repaired the vehicle of ".. getPlayerName(psource) ..", you earned $".. price .."", 0, 225, 0)
            end
            setVehicleDamageProof ( vehicle, false )
            setElementFrozen(vehicle,false)
            setElementFrozen(mechanic,false)
            setPedAnimation(mechanic,false)
        else
            exports.USGmsg:msg(psource,"You don't have enough money to repair your vehicle",  225, 0, 0)
            setElementFrozen(vehicle,false)
            setElementFrozen(mechanic,false)
            setPedAnimation(mechanic,false)
        end
        end,4000,1)
    else
        exports.USGmsg:msg(mechanic,"This vehicle doesn't need a repair!",  225, 0, 0)
        setElementFrozen(vehicle,false)
        setElementFrozen(mechanic,false)
        setPedAnimation(mechanic,false)
    end
end 
addEvent("vehicleRepair", true)
addEventHandler("vehicleRepair", root, vehicleRepair)

function isOwner(vehicle) 
    if isElement(vehicle) and getElementDimension(vehicle) == 0 then 
        player = exports.USGcnr_pvehicles:getVehicleOwner(vehicle)
        if isElement(player) then
            setElementData(vehicle, "Owner", player)
        else
            return false
        end
    end 
end
addEvent("isOwner",true)
addEventHandler("isOwner", root, isOwner)

function round(number, digits)
  local mult = 10^(digits or 0)
  return math.floor(number * mult) / mult
end