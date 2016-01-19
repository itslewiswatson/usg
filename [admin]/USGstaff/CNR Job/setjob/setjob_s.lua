function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function setJob(pSource, cmd, player, job)
	if (exports.USGadmin:isPlayerStaff(pSource)) then
		local player = getPlayerFromPartialName(player)
		if (isElement(player))then
			exports.USGcnr_wanted:setPlayerWantedLevel(player, 0)
			if (exports.USGcnr_jobs:setPlayerJob(player, job)) then
				exports.USGmsg:msg(pSource, "You gave "..getPlayerName(player).." "..job.." job", 255, 255, 255)
				exports.USGmsg:msg(player, "You have been given "..job.." job by "..getPlayerName(player), 255, 255, 255)
			end
		end
	end
end
addCommandHandler("setjob", setJob)
