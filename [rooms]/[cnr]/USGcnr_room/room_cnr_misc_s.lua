function suicidePlayer(player)
    if(isElement(player)) then
        killPed(player)
        setElementFrozen(player, false)
    end
end

commandHandlers = {}

function bindPlayerCommands(player)

end

function unbindPlayerCommands(player)

end

suicideTimers = {}

addEvent("onPlayerSuicide")
commandHandlers.suicide = function (pSource, cmd)
    if(exports.USGrooms:getPlayerRoom(pSource) == "cnr" and not isPedDead(pSource)) then
        if(triggerEvent("onPlayerSuicide", pSource) == false) then
            exports.USGmsg:msg(pSource, "You can't commit suicide right now.", 255, 0, 0)
            return
        end
        if(isTimer(suicideTimers[pSource])) then killTimer(suicideTimers[pSource]) end
        setElementFrozen(pSource, true)
        suicideTimers[pSource] = setTimer(suicidePlayer, 10000, 1, pSource)
        exports.USGmsg:msg(pSource, "You will be killed in 10 seconds.", 255, 128, 0)
    end
end
addCommandHandler("suicide", commandHandlers.suicide, false, false)
addCommandHandler("kill", commandHandlers.suicide, false, false)

addEvent( "onPlayerReloadWeapon", true )
addEventHandler( "onPlayerReloadWeapon", root,
    function()
        if ( exports.USGrooms:getPlayerRoom( source ) == "cnr" or exports.USGrooms:getPlayerRoom( source ) == "tct" ) and not ( isPedDead( source ) ) then
            reloadPedWeapon ( source )
        end
    end
)

function destroyBlownVehicle(vehicle)
    if(isElement(vehicle)) then
        destroyElement(vehicle)
    end
end

addEventHandler("onVehicleExplode", root,
    function ()
        if(getElementData(source, "room") == "cnr") then
            setTimer(destroyBlownVehicle, 10000, 1, source)
        end
    end
)

addEventHandler("onPlayerWasted", root,
    function (ammo, killer)
        if(exports.USGrooms:getPlayerRoom(source) ~= "cnr") then return end
        if(isTimer(suicideTimers[source])) then killTimer(suicideTimers[source]) end -- cancel suicide
        exports.USGplayerstats:incrementPlayerStat(source, "cnr_deaths",1)
        if(isElement(killer) and getElementType(killer) == "player" and killer ~= source) then
            exports.USGplayerstats:incrementPlayerStat(killer, "cnr_kills",1)
        end
    end
)

addEventHandler("onPlayerChangeNick", root,
    function (old, new)
        if(exports.USGrooms:getPlayerRoom(source) == "cnr") then
            setPlayerNametagText(source, new.."["..exports.USGcnr_wanted:getPlayerWantedLevel(source).."]")
        end
    end, true, "low"
)