local jobs = {}
local occupationToJob = {}
local markerToJob = {}
local playerJob = {}
local typeTeams = {}
local hasJobSkin = {}

function addJob(ID, jobType, occupation, team)
    local occ = exports.USG:trimString(occupation) -- remove spaces on end/start
    jobType = jobType:lower()
    jobs[ID] = {occupation=occ, type = jobType, team = team or typeTeams[jobType]}
    occupationToJob[occ] = ID
    for i, player in ipairs(getElementsByType("player")) do
        local jobID = getElementData(player, "jobID")
        if(jobID == ID) then
            setPlayerJob(player, jobID, getElementModel(player))
        end
    end 
    return true
end

addEvent("onPlayerAttemptChangeJob")
addEvent("onPlayerChangeJob")
function setPlayerJob(player, jobID, skinID)
    if(isElement(player)) then
        if(triggerEvent("onPlayerAttemptChangeJob", player, jobID, skinID)) then
            if(jobID == false) then -- quit job
                playerJob[player] = false
                setElementData(player,"occupation", "Unemployed")
                removeElementData(player,"jobID")
                setPlayerTeam(player, getTeamFromName("Unemployed"))
                triggerEvent("onPlayerChangeJob", player, false)
                triggerClientEvent(exports.USGrooms:getPlayersInRoom("cnr"), "onPlayerChangeJob", player, jobID)
                exports.USGcnr_skins:restorePlayerSkin(player)
                hasJobSkin[player] = nil
                return true
            elseif(jobs[jobID]) then
                if(type(skinID) == "number") then
                    hasJobSkin[player] = true
                    setElementModel(player, skinID)
                else
                    exports.USGcnr_skins:restorePlayerSkin(player)
                    hasJobSkin[player] = nil
                end
                playerJob[player] = jobID
                setElementData(player,"occupation", jobs[jobID].occupation)
                setElementData(player,"jobID", jobID)
                if(isElement(jobs[jobID].team)) then setPlayerTeam(player, jobs[jobID].team) end
                triggerEvent("onPlayerChangeJob", player, jobID)
                triggerClientEvent(exports.USGrooms:getPlayersInRoom("cnr"), "onPlayerChangeJob", player, jobID)
                return true
            else
                return false
            end
        else
            return false
        end
    end
    return false
end

addEventHandler("onPlayerSpawn", root,  
    function ()
        if(exports.USGrooms:getPlayerRoom(source) ~= "cnr") then return end
        local job = getPlayerJob(client)
        if(job and jobs[job]) then
            job = jobs[job]
            if(isElement(job.team)) then setPlayerTeam(client, job.team) end
        end
    end
)

addEvent("USGcnr_jobs.quitJob", true)
function onPlayerQuitJob()
    if(getElementHealth(client) == 0) then
        exports.USGmsg:msg(client,"You can not quit your job when dead!", 255, 0, 0)
    elseif(setPlayerJob(client,false)) then
        exports.USGmsg:msg(client,"You have quit your job!", 0,255,0)
    end
end
addEventHandler("USGcnr_jobs.quitJob", root, onPlayerQuitJob)

addEvent("USGcnr_jobs.jobPicked", true)
function onPlayerPickJob(jobID, skinID)
    if(setPlayerJob(client, jobID, skinID)) then
        exports.USGmsg:msg(client,"You are now a "..jobs[jobID].occupation..".", 0,255,0)
    end
end
addEventHandler("USGcnr_jobs.jobPicked", root, onPlayerPickJob)

addEvent("onPlayerPostExitRoom", true)
function onPlayerExitRoom(room)
    if(room == "cnr") then
        playerJob[source] = nil
        removeElementData(source, "occupation")
        removeElementData(source, "jobID")
        hasJobSkin[source] = nil
    end
end
addEventHandler("onPlayerPostExitRoom",root,onPlayerExitRoom)

function doesPlayerHaveJobSkin(player)
    return hasJobSkin[player] == true
end

function getPlayerJob(player)
    if(isElement(player)) then
        return playerJob[player]
    end
    return false
end

function getPlayerJobType(player)
    if(isElement(player) and playerJob[player]) then
        return jobs[playerJob[player]].type
    end
    return false
end

function getJobType(job)
    return jobs[job] and jobs[job].type or false
end

function onResourceStart()
    typeTeams.staff = getTeamFromName("Staff") or createTeam("Staff", 220,220,220, 220)
    setTeamFriendlyFire(typeTeams.staff, false)
    typeTeams.criminal = getTeamFromName("Criminals") or createTeam("Criminals", 205,38,38)
    typeTeams.police = getTeamFromName("Police") or createTeam("Police", 120,120,255)
    setTeamFriendlyFire(typeTeams.police, false)
    typeTeams.civil = getTeamFromName("Civilians") or createTeam("Civilians", 255,255,0)
    setTeamFriendlyFire(typeTeams.civil, false)
    typeTeams.unemployed = getTeamFromName("Unemployed") or createTeam("Unemployed", 200,115,0, 220)
    setTimer(loadPlayerJobs, 2000, 1)
end
addEventHandler("onResourceStart",resourceRoot,onResourceStart)

function loadPlayerJobs()
    for i, player in ipairs(getElementsByType("player")) do
        local jobID = getElementData(player, "jobID")
        if(not jobID) then
            setPlayerJob(player, false)
        end
    end
end