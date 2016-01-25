addEvent("testing.callServices", true)
function callServices(jobID, service)
    local callCount = 0
	local x,y,z = getElementPosition(source)
    for i, player in ipairs(getElementsByType("player")) do
        if(exports.USGrooms:getPlayerRoom(player) == "cnr" and exports.USGcnr_jobs:getPlayerJob(player) == jobID) then
            callCount = callCount+1
			exports.USGmsg:msg(player, getPlayerName(source).." needs you at: "..getZoneName( x,y,z).."!", 0, 255, 0)
        end
    end
    if(callCount > 0) then
        exports.USGmsg:msg(client, "You have called the "..service.." service.("..callCount.." Total calls)", 0, 255 ,0)
    else
        exports.USGmsg:msg(client, "The "..service.." service is not available.", 255, 0, 0)
    end
end
addEventHandler("testing.callServices", root, callServices)