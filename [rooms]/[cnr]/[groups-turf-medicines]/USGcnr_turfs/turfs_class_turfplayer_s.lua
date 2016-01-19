PLAYER_STATUS_IDLE = 0 
PLAYER_STATUS_CAPTURING = 1
PLAYER_STATUS_DEFENDING = 2

PLAYER_CAPTURE_DELAY = 4300

class 'TurfPlayer'

function TurfPlayer:TurfPlayer(element, turf)
    if(not turf) then return false end
    
    self.turf = turf
    self.element = element
    if(not self:canTurf()) then return false end
    self.inProgress = false
    self:updateStatus()
    if(self.inProgress == false and self.status == PLAYER_STATUS_CAPTURING) then
        setTimer(function (...) self.startCapture(self,...) end, PLAYER_CAPTURE_DELAY, 1)
    end
    local id = table.insert(self.turf.players, self)
    addEventHandler("onColShapeLeave", self.turf.colShape, function (...) self.colLeave(self,...) end)
    addEventHandler("onPlayerExitRoom", self.element, function () self:kill() end)
    addEventHandler("onPlayerQuit", self.element, function () self:kill() end)
    addEventHandler("onPlayerWasted", self.element, 
        function (ammo, killer) 
            self.turf:onTurferKilled(self, killer) 
            self:kill() 
        end
    )
    self:sendClientData(self.turf.clientData)
    return self
end

function TurfPlayer:colLeave(hitElement)
    if(hitElement == self.element) then
        self:kill()
    end 
end

function TurfPlayer:kill()
    if(isElement(self.element)) then
        self:sendClientData(false)
    end
    self.turf:removePlayer(self)
    self = nil
end

function TurfPlayer:canTurf()
    return isElement(self.element) and exports.USGrooms:getPlayerRoom(self.element) == "cnr"
    and isElementWithinColShape(self.element, self.turf.colShape)
    and exports.USGcnr_jobs:getPlayerJobType(self.element) == "criminal"
    and exports.USGcnr_groups:getPlayerGroup(self.element)
    and not exports.USGcnr_job_police:isPlayerArrested(self.element)
end

function TurfPlayer:startCapture()
    self:updateStatus()
    if(self.inProgress == false and self.status == PLAYER_STATUS_CAPTURING) then
        self.inProgress = true
        if(self.turf:isOwned()) then
            exports.USGmsg:msg(self.element, "You are now capturing a turf from the "..self.turf:getFullOwnerName().."!", 0, 255,0)
        else
            exports.USGmsg:msg(self.element, "You are now capturing an unoccupied turf!", 0, 255,0)
        end
    end
end

function TurfPlayer:sendClientData(data)
    dataSendID = dataSendID+1
    if(dataSendID > 10000) then dataSendID = 0 end
    triggerClientEvent(self.element, "USGcnr_turfs.recieveTurfData", self.element, data, dataSendID)
end

function TurfPlayer:updateStatus()
    if(not self:canTurf()) then self:kill() return end
    if(self.turf:isPlayerOwner(self.element)) then
        self.status = PLAYER_STATUS_DEFENDING
    else
        self.status = PLAYER_STATUS_CAPTURING
    end
    return self.status
end