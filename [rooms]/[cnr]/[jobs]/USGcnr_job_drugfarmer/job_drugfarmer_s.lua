-- *** initializing and unloading ***
function initJob()
    if(getResourceFromName("USGcnr_jobs") and getResourceState(getResourceFromName("USGcnr_jobs")) == "running") then
        exports.USGcnr_jobs:addJob(jobID, jobType, occupation)
    end
end

addEventHandler("onResourceStart", root,
    function (res) -- init job if thisResource started, or if USGcnr_jobs (re)started
        if(res == resource or res == getResourceFromName("USGcnr_jobs")) then
            initJob()
        end
    end
)

-- ** giving drugs

addEvent("USGcnr_job_drugfarmer.onDrugHarvested", true)
function onDrugHarvested(drug, amount)
    if(exports.USGcnr_jobs:getPlayerJob(client) ~= jobID) then return end
    exports.USGcnr_drugs:givePlayerMedicines(client, medicine, amount)
    exports.USGcnr_wanted:givePlayerWantedLevel(client, 5)
end
addEventHandler("USGcnr_job_drugfarmer.onDrugHarvested", root, onDrugHarvested)