function addStaffJob()
	if(getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
		exports.USGcnr_jobs:addJob(jobID,jobType,occupation)
	end
end

addEventHandler("onResourceStart", root, 
	function (res)
		if(source == resourceRoot or res == getResourceFromName("USGcnr_jobs")) then
			addStaffJob()
		end
	end
)

addCommandHandler("staff",
	function (pSource, ...)
		if(exports.USGadmin:isPlayerStaff(pSource)) then
			local stafflevel, wantedlevel = exports.USGadmin:getPlayerStaffLevel(pSource), exports.USGcnr_wanted:getPlayerWantedLevel(pSource)
			if(wantedlevel == 0 or stafflevel > 1) then
				local account = getPlayerAccount(pSource)
				if (getAccountName(account) == "noki") then
					exports.USGcnr_jobs:setPlayerJob(pSource, jobID, 211)
					exports.USGcnr_wanted:setPlayerWantedLevel(pSource, 0)
					exports.USGmsg:msg(pSource, "Hello Metall, have an enjoyful day!", 0, 225, 0)
				else
					exports.USGcnr_jobs:setPlayerJob(pSource, jobID, 217)
					exports.USGcnr_wanted:setPlayerWantedLevel(pSource, 0)
					exports.USGmsg:msg(pSource, "You have entered the staff job.", 0, 255, 0)
				end
			else
				exports.USGmsg:msg(pSource, "You can't take staff job with stars when trial staff.",255,0,0)
			end
		end
	end
)

addCommandHandler("dmgproof",
	function (pSource, ...)
		if(exports.USGadmin:isPlayerStaff(pSource) and exports.USGcnr_jobs:getPlayerJob(pSource) == jobID) then
			local vehicle = getPedOccupiedVehicle(pSource)
			if(isElement(vehicle)) then
				local state = not isVehicleDamageProof(vehicle)
				setVehicleDamageProof(vehicle, state)
				exports.USGmsg:msg(pSource, "Your vehicle is "..(state and "now" or "no longer").." damage proof",0, 255,0)
			else
				exports.USGmsg:msg(pSource, "You are not in a vehicle.", 255, 0, 0)
			end
		end
	end
)

addEventHandler("onPlayerWasted", root,
	function (ammo, killer)
		if(not killer or exports.USGrooms:getPlayerRoom(source) ~= "cnr" or killer == source) then return end
		if(getElementType(killer) == "vehicle") then
			if(getVehicleController(killer)) then
				killer = getVehicleController(killer)
			else
				return
			end
		elseif(getElementType(killer) ~= "player") then
			return
		end
		local chatZone = exports.USG:getPlayerChatZone(source)
		if(chatZone == "LV" and getElementInterior(source) == 0) then return end -- if in LV and not in interior, stop
		local WLVL = exports.USGcnr_wanted:getPlayerWantedLevel(source)
		local kWLVL = exports.USGcnr_wanted:getPlayerWantedLevel(killer)
		local jobType = exports.USGcnr_jobs:getPlayerJobType(source)
		local kJobType = exports.USGcnr_jobs:getPlayerJobType(killer)
		if(kJobType == "police" and WLVL > 0) then
			return
		elseif(kWLVL > 0 and jobType == "police") then
			return
		end
		outputDMMessage(source, killer)
	end
)

function outputDMMessage(victim, killer)
	local message = getPlayerName(victim).." has possibly been DMed by "..getPlayerName(killer)
	for i, player in ipairs(getElementsByType("player")) do
		if(exports.USGadmin:isPlayerStaff(player)) then
			exports.USGcnr_killmessages:outputMessage ( message, player, 0, 180, 0 )
		end
	end
end

local function getPlayerFromPartialName(name)
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

addCommandHandler("setjob",
	function (pSource,cmd,player,job)
		if(exports.USGadmin:isPlayerStaff(pSource)) then
		local player = getPlayerFromPartialName(player)
			if(isElement(player))then
			exports.USGcnr_wanted:setPlayerWantedLevel(player, 0)
				if(exports.USGcnr_jobs:setPlayerJob(player, job))then
					exports.USGmsg:msg(pSource, "You gave "..getPlayerName(player).." "..job.." job",255,255,255)
					exports.USGmsg:msg(player, "You have been given "..job.." job by "..getPlayerName(player),255,255,255)
				end
			end
		end
	end
)