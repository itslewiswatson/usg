local packetFrozen = false
-- thanks jack
function onNetworkCheck()
	local network = getNetworkStats()
	if (network) and (type(network) == "table") then --check whether we have the data (Since it broke once)
		--Check the current packet loss this second, and handle it.
		if (network["packetlossLastSecond"] >= 45 or getPlayerPing(localPlayer) > 500 and not exports.USGadmin:isPlayerStaff()) then
			toggleControl("fire", false)
			packetFrozen = true
		elseif (packetFrozen) then
			packetFrozen = false
			toggleControl("fire", true)
		end
		
		--Check the overall packet loss, and handle that.
		if (network["packetlossTotal"] >= 50) then
			--[INSERT HANDLE CODE HERE]--
		else
			--[INSERT REVERSE HANDLE CODE HERE]--
		end
	end
end

local networkTimer
function isResourceReady(name)
	return getResourceFromName(name)
	and getResourceState(getResourceFromName(name)) == "running"
end

function startNetworkChecker()
	if(isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr" and not isTimer(networkTimer)) then
		networkTimer = setTimer(onNetworkCheck,1000,0)
	end
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
	function (room)
		if(room == "cnr") then
			startNetworkChecker()
		end
	end
)

addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer, 
	function (room)
		if(isTimer(networkTimer)) then
			killTimer(networkTimer)
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot, startNetworkChecker)