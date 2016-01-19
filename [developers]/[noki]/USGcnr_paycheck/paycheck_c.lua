-- We have this client side bit so we give them money every X minutes after they join

local function givePlayerPayCheck()
	-- Wait 5 seconds because sometimes it takes a while to assign a player their team
	local plrTeam = getTeamName(getPlayerTeam(localPlayer))
	-- We can change this later if official groups get teams
	if (plrTeam == "Police") and (exports.USGcnr_wanted:getPlayerWantedLevel(localPlayer) == 0) then
		triggerServerEvent("USGcnr_paycheck:givePlayerPayCheck", localPlayer)
	end
end

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
	function (room)
		if (room == "cnr") then
			if (not isTimer(payCheckTimer)) then
			-- Every 10 minutes
				payCheckTimer = setTimer(givePlayerPayCheck, 600000, 0)
			end
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot, 
	function ()
		if (exports.USGrooms:getPlayerRoom(localPlayer, "cnr")) then
			if (not isTimer(payCheckTimer)) then
				payCheckTimer = setTimer(givePlayerPayCheck, 600000, 0)
			end
		end
	end
)

addEvent("onPlayerLeaveRoom", true)
addEventHandler("onPlayerLeaveRoom", localPlayer,
	function (room)
		if (room == "cnr") then
			if (isTimer(payCheckTimer)) then
				killTimer(payCheckTimer)
			end
		end
	end
)

addCommandHandler("lino", 
	function() 
		remaining, _, _ = getTimerDetails(payCheckTimer)
		outputDebugString("Timer: "..remaining)
	end
)

-- USGrooms is fucking shit so we need this
function foo()
	if (exports.USGrooms:getPlayerRoom(localPlayer) ~= "cnr") and (isTimer(payCheckTimer)) then
		killTimer(payCheckTimer)
	end
end
setTimer(foo, 5000, 0)