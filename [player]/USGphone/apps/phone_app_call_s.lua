addEvent("USGcnr_phone.callService", true)
function callService(jobID, service)
	local callCount = 0
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGrooms:getPlayerRoom(player) == "cnr" and exports.USGcnr_jobs:getPlayerJob(player) == jobID) then
			callCount = callCount+1
		end
	end
	if(callCount > 0) then
		exports.USGmsg:msg(client, "You have called the "..service.." service.", 0, 255 ,0)
	else
		exports.USGmsg:msg(client, "The "..service.." service is not available.", 255, 0, 0)
	end
end
addEventHandler("USGcnr_phone.callService", root, callService)