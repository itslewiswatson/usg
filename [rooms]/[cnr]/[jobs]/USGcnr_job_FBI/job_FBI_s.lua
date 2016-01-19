-- *** initializing and unloading ***

function initJob()
    if(getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
        exports.USGcnr_jobs:addJob(jobID, jobType, occupation, team)
    end
end


addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
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
        arrests = exports.USGplayerstats:getStatsPlayer(source,"cnr_arrests") 
            if(arrests < 700) then
                cancelEvent()
                exports.USGmsg:msg(source, "You have to get 700 arrests to use this job.", 255, 0, 0)
            end
        end
    end
)