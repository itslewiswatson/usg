local TimeToStayImMarker = 1000  * 1 * 60 
local NumberOfPlayersInMarkerRequired = 1

local cop = getTeamFromName("Police") and getTeamFromName("National Guard")
local crim = getTeamFromName("Criminals")


local markersLocations = {
--x,y,z,owner
{-2770.75390625, 362.2783203125, 3.4900455474854,cop},
{-2770.0791015625, 388.798828125, 3.46937084198,cop},
{-2706.2353515625, 376.0546875, 3.9686193466187,cop},
{-2772.9833984375, 430.1572265625, 3.5078125,cop},
{-2773.154296875, 320.888671875, 3.5033311843872,cop},
}

local owner = {}
local markers = {}
local PlayersInMarker = {}


local function messageCNR(message,r,g,b)
    for k, player in ipairs(getElementsByType("player")) do
                    if(exports.USGrooms:getPlayerRoom(player) == "cnr")then
                    exports.USGmsg:msg(player, message, r,g,b)
                end
            end
end

function onMarkerOwnerChange(isResourceJustStarting)
    if(not isResourceJustStarting)then
        if(getMarkerOwner(markers[1]) == crim and getMarkerOwner(markers[2]) == crim  and getMarkerOwner(markers[3]) == crim and getMarkerOwner(markers[4]) == crim and getMarkerOwner(markers[5]) == crim)then
        messageCNR("White House has been taken down by Criminals",183 ,0 ,0)
        exports.USGcnr_jail:toggleJailDoor("open")
        end
        if(getMarkerOwner(markers[1]) == cop and getMarkerOwner(markers[2]) == cop  and getMarkerOwner(markers[3]) == cop and getMarkerOwner(markers[4]) == cop and getMarkerOwner(markers[5]) == cop)then
        messageCNR("Cops liberated the White House", 0 ,76 ,253)
        exports.USGcnr_jail:toggleJailDoor("close")
        end
    end
end

function addPlayerOnMarker(marker,team)
PlayersInMarker[marker][team] = PlayersInMarker[marker][team] + 1
end

function removePlayerOnMarker(marker,team)
PlayersInMarker[marker][team] = PlayersInMarker[marker][team] - 1
end

function getNumberOfPlayerInMarker(marker,team)
    return PlayersInMarker[marker][team]
end

function setMarkerOwner(marker,team,isResourceJustStarting)
owner[marker] = team
    if(team == cop)then
    setMarkerColor(marker , 0 ,76 ,253, 255) 
    elseif(team == crim)then
    setMarkerColor(marker , 183 ,0 ,0, 255)
    end
    onMarkerOwnerChange(isResourceJustStarting)
end

function getMarkerOwner(marker)
return owner[marker]
end

addEventHandler ( "onResourceStart", resourceRoot, function()
    for k,v in ipairs(markersLocations)do
    local marker = createMarker(v[1], v[2], v[3],"cylinder", 2,255,255,255,200)
    PlayersInMarker[marker] = {}
    PlayersInMarker[marker][cop] = 0
    PlayersInMarker[marker][crim] = 0
    setMarkerOwner(marker,v[4],true)
    setElementDimension(marker, 0 )
    addEventHandler( "onMarkerHit", marker, onHitMarker )
    addEventHandler( "onMarkerLeave", marker, onLeaveMarker )
    table.insert(markers,marker)
    end
    onMarkerOwnerChange(false)
end)

function onHitMarker( hitElement )
local hitMarker = source
    if (exports.USGrooms:getPlayerRoom(hitElement) == "cnr" ) then
        if (exports.USGcnr_jobs:getPlayerJobType(hitElement) == "criminal") then
        addPlayerOnMarker(hitMarker,crim)
            if(getMarkerOwner(source) == cop)then
                setTimer( function ()
                    if(getNumberOfPlayerInMarker(hitMarker,crim) >= NumberOfPlayersInMarkerRequired)then
                        exports.USGcnr_wanted:givePlayerWantedLevel(hitElement,5)
                        setMarkerOwner(hitMarker,crim,false)
                    end
                end,TimeToStayImMarker,1)
            end
        end 
        if (exports.USGcnr_jobs:getPlayerJobType(hitElement) == "police" ) then
            addPlayerOnMarker(hitMarker,cop)
            if(getMarkerOwner(source) == crim )then
                setTimer( function ()
                    if(getNumberOfPlayerInMarker(hitMarker,cop) >= NumberOfPlayersInMarkerRequired)then
                        setMarkerOwner(hitMarker,cop,false)
                    end
                end,TimeToStayImMarker,1)
            end
        end     
    end    
end

function onLeaveMarker( hitElement )
    if (exports.USGrooms:getPlayerRoom(hitElement) == "cnr" ) then
        if (exports.USGcnr_jobs:getPlayerJobType(hitElement) == "criminal" )then
        removePlayerOnMarker(source,crim)
        end
        if (exports.USGcnr_jobs:getPlayerJobType(hitElement) == "police" )then
        removePlayerOnMarker(source,cop)
        end
    end    
end


