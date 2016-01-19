-- *** initializing and unloading ***

function initJob()
    if(getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
        exports.USGcnr_jobs:addJob(jobID, jobType, occupation, team)
    end
end


addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
        if(res == resource) then
        team = createTeam ( "National Guard",  74, 105, 41 )
        end
        if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
            initJob()
        end
    end
)

local onJob = {}
addEvent("onPlayerAttemptChangeJob")
addEventHandler("onPlayerAttemptChangeJob", root,
    function (id, skin)
        if(id == jobID) then
            if (exports.USgcnr_groups:getPlayerGroup(source) ~= 30) and (getPlayerTeam(source)) and (getTeamName(getPlayerTeam(source)) ~= 'Staff') then
                cancelEvent()
                exports.USGmsg:msg(source, "You have to be an National Guard member to take this job.", 255, 0, 0)
            end
        end
    end
)

local onJob = {}

addEvent("onPlayerChangeJob", true)
function onJobChange(job)
	if(job == jobID) then
		giveWeapon(source, 3, 1)
		onJob[source] = true
	elseif(onJob[source]) then
		takeWeapon(source, 43)
		onJob[source] = false
	end
end
addEventHandler("onPlayerChangeJob", root, onJobChange)