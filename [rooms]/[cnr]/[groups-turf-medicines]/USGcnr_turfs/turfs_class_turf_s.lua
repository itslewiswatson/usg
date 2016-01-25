DEBUG = true

TURF_STATUS_IDLE = 0 
TURF_STATUS_CAPTURING = 1

INFLUENCE_INCREASE_BASE = 1
INFLUENCE_INCREASE_KILL = 2
INFLUENCE_INCREASE_PLAYERBONUS = 0.15
INFLUENCE_UPDATE_INTERVAL = 1500

REWARD_CAPTURE = 3000
REWARD_SCORE_CAPTURE = 1.5
TURF_CAPTUR_WL = 5

class 'Turf'

dataSendID = 0

function Turf:Turf(dbRow)
    self.id = dbRow.id
    self.x = dbRow.x
    self.y = dbRow.y
    self.x2 = dbRow.x2
    self.y2 = dbRow.y2
    self.spawnx = dbRow.spawnx
    self.spawny = dbRow.spawny
    self.spawnz = dbRow.spawnz
    self.spawnrot = dbRow.spawnrot
    self.maxHeight = dbRow.maxHeight
    self.ownerGroup = (dbRow.groupOwnerID ~= 0 and exports.USGcnr_groups:getGroupName(dbRow.groupOwnerID)) and dbRow.groupOwnerID or false
    self.ownerAlliance = (dbRow.allianceOwnerID ~= 0 and exports.USGcnr_groups:getAllianceName(dbRow.allianceOwnerID)) and dbRow.allianceOwnerID or false
    if(self.maxHeight) then
        self.colShape = createColCuboid(self.x, self.y, -50, self.x2-self.x, self.y2-self.y, self.maxHeight+50)
    else
        --self.colShape = createColRectangle(self.x, self.y, self.x2-self.x, self.y2-self.y)
        self.colShape = createColCuboid(self.x, self.y, 3, self.x2-self.x, self.y2-self.y, 16)
    end
    self.radarArea = createRadarArea(self.x, self.y, self.x2-self.x, self.y2-self.y, 255,255,255, 165)
    self:updateColor()
    setElementDimension(self.colShape, exports.USGrooms:getRoomDimension("cnr"))
    setElementDimension(self.radarArea, exports.USGrooms:getRoomDimension("cnr"))
    addEventHandler("onColShapeHit", self.colShape, function (...) self.colHit(self,...) end)
    addEventHandler("onColShapeLeave", self.colShape, function (...) self.colLeave(self,...) end)
    addEventHandler("onGroupColorChange", root, 
        function (id,r,g,b)
            if(id == self.ownerGroup) then 
                setRadarAreaColor(self.radarArea, r,g,b,165)
            end
        end)
    self.players = {}
    self.status = TURF_STATUS_IDLE
	self.blink = false
    if(self:isOwned()) then
        self.influence = 100
    else
        self.influence = 0
    end
    self.clientData = { influence = self.influence, owningTeam = ( self:isOwned() and { name = self:getOwnerName() } or nil ) } 
    table.insert(turfs, self)
    local elements = getElementsWithinColShape(self.colShape, "player")
    for i, element in ipairs(elements) do
        if(getElementDimension(element) == getElementDimension(self.colShape)) then
            if(self:isOwned()) then
                exports.USGmsg:msg(element, "You entered a turf owned by the "..self:getFullOwnerName()..".",0,255,0)
            else
                exports.USGmsg:msg(element, "You entered an unoccupied turf.",0,255,0)
            end
            TurfPlayer(element, self)
        end
    end

    return self
end

function Turf:save()
    return exports.MySQL:execute("UPDATE cnr__turfs SET groupOwnerID=?,allianceOwnerID=? WHERE id=?",self.ownerGroup,self.ownerAlliance,self.id)
end

function Turf:updateColor()
    local r,g,b = 255,255,255
    if(self.ownerGroup) then
        r,g,b = exports.USGcnr_groups:getGroupColor(self.ownerGroup)
    elseif(self.ownerAlliance) then
        r,g,b = exports.USGcnr_groups:getAllianceColor(self.ownerAlliance)
    end
    setRadarAreaColor(self.radarArea, r,g,b,165)
end
local lastmemory = 0
function printmemory(comment, id)
    if(id == 1) then
        local count = collectgarbage( "count" )
        local change = count - lastmemory
        lastmemory = count
        outputDebugString(comment .. " || usage: "..collectgarbage( "count" ).. " ( +"..change.." )")
    end
end

function Turf:updateInfluence()
    local leftTeam, rightTeam = nil, nil
    if(self.status ~= TURF_STATUS_IDLE or self:isOwned()) then
        leftTeam, rightTeam = self:getActiveTeams()
        if((rightTeam and rightTeam.count >= 0) or (leftTeam and leftTeam.count >= 0)) then               
            rightCount = rightTeam and rightTeam.count or 0
            leftCount = leftTeam and leftTeam.count or 0
            local countDifference = math.min(5,math.max(0,math.abs(rightCount-leftCount)-1))
            if(leftCount > rightCount) then -- attackers are winning
                self.influence = math.max(self.influence - INFLUENCE_INCREASE_BASE - math.ceil(INFLUENCE_INCREASE_PLAYERBONUS * countDifference),-100)
            elseif(rightCount > leftCount) then -- owners are winning
                self.influence = math.min(self.influence + INFLUENCE_INCREASE_BASE + math.ceil(INFLUENCE_INCREASE_PLAYERBONUS * countDifference),100)
            end
            self:checkInfluence(leftTeam, rightTeam)
            return
        end
    end
    local data = self:getClientData(leftTeam, rightTeam)
    for i, player in ipairs(self.players) do
        if(getPlayerIdleTime(player.element) < 120000) then
            player:sendClientData(data)
        end
    end
end

function Turf:checkInfluence(leftTeam, rightTeam)
    if(self.influence > 50 and not self:isOwned()) then
        self:setOwner(rightTeam.id, rightTeam.isAlliance)
    elseif(self.influence <= -50 and self:isOwned()) then
        self:setUnoccupied()
    elseif(self.influence <= -100) then
    self:setOwner(leftTeam.id, leftTeam.isAlliance)
    local nRightTeam = {id = self.ownerGroup or self.ownerAlliance, isAlliance = self.ownerAlliance ~= false, count = rightTeam and rightTeam.count or 0}
    leftTeam = rightTeam
	rightTeam = nRightTeam
	end 
	
	if(self.influence <= 0 and self.influence >= -50)then
	self.blink = true
	else self.blink = false end
	
    local data = self:getClientData(leftTeam, rightTeam)
    for i, player in ipairs(self.players) do
        if(getPlayerIdleTime(player.element) < 120000) then
            player:sendClientData(data)
        end
    end
end

function Turf:onTurferKilled(turfer, killedBy)
    local leftTeam, rightTeam = nil, nil
    if(self.status ~= TURF_STATUS_IDLE or self:isOwned()) then
        local leftTeam, rightTeam = self:getActiveTeams()
        for i,player in ipairs(self.players) do
            if(player.element == killedBy) then
                local groupID = exports.USGcnr_groups:getPlayerGroup(player.element)
                local asAlliance = exports.USGcnr_groups:isGroupTurfingAsAlliance(groupID)
                local allianceID = exports.USGcnr_groups:getGroupAlliance(groupID)					
				if(leftTeam)then
					local inLeftTeam = (asAlliance and leftTeam.isAlliance and leftTeam.id == allianceID) or
                    (not asAlliance and not leftTeam.isAlliance and leftTeam.id == groupID)
				end
					
                local inRightTeam = (asAlliance and rightTeam.isAlliance and rightTeam.id == allianceID) or
                    (not asAlliance and not rightTeam.isAlliance and rightTeam.id == groupID)
                if(inLeftTeam) then
                    self.influence = math.max(self.influence - INFLUENCE_INCREASE_KILL, -100)
                elseif(inRightTeam) then
                    self.influence = math.max(self.influence + INFLUENCE_INCREASE_KILL, 100)
                end
                self:checkInfluence(leftTeam, rightTeam)
                break
            end
        end
    end
end

function Turf:getActiveTeams()
    local teams = {}
    local owningTeam
    local leftTeam, rightTeam = false, false
    if(self.status ~= TURF_STATUS_IDLE or self:isOwned()) then
        if(self:isOwned()) then
            owningTeam = {id = self.ownerGroup or self.ownerAlliance, isAlliance = self.ownerAlliance ~= false, count = 0}
            table.insert(teams, owningTeam)
        end
        
        local groupTeam = {}
        local allianceTeam = {}
        
        for i,player in ipairs(self.players) do
            player:updateStatus()
            if(player.status == PLAYER_STATUS_CAPTURING and self.status ~= TURF_STATUS_IDLE) then
                local group = exports.USGcnr_groups:getPlayerGroup(player.element)
                local asAlliance = exports.USGcnr_groups:isGroupTurfingAsAlliance(group)
                if(asAlliance) then
                    local alliance = exports.USGcnr_groups:getGroupAlliance(group)
                    if(allianceTeam[alliance]) then
                        allianceTeam[alliance].count = allianceTeam[alliance].count+1
                    else
                        allianceTeam[alliance] = { count = 1, isAlliance = true, id = alliance }
                        table.insert(teams, allianceTeam[alliance]) 
                    end
                else
                    if(groupTeam[group]) then
                        groupTeam[group].count = groupTeam[group].count+1
                    else
                        groupTeam[group] = { count = 1, isAlliance = false, id = group }
                        table.insert(teams, groupTeam[group])   
                    end
                end
            elseif(player.status == PLAYER_STATUS_DEFENDING and owningTeam) then
                owningTeam.count = owningTeam.count+1
            end
        end
        rightTeam = owningTeam -- for if no others found
        local leftCount, rightCount = 0, 0
        for i, team in ipairs(teams) do
            if(team.count > leftCount) then
                leftTeam = team
                leftCount = team.count
            elseif(team.count > rightCount) then
                rightTeam = team
                rightCount = team.count
            end
        end
            --outputDebugString("id : "..self.id.." players: "..#self.players.." r: "..rightCount.." l: "..leftCount.. " teams: "..#teams)
        if((rightTeam and rightTeam.count ~= 0) or (leftTeam and leftTeam.count ~= 0)) then             
            if(owningTeam == leftTeam) then
                if(rightTeam == owningTeam) then -- owners are already right
                    leftTeam = false
                else
                    leftTeam = rightTeam
                    rightTeam = owningTeam -- show owners right
                end
            end
            if(rightTeam and not leftTeam and rightTeam ~= owningTeam) then
                leftTeam = rightTeam
            end
        end
        groupTeam, allianceTeam = nil,nil
    end
    teams, owningTeam = nil, nil
    return leftTeam, rightTeam
end

function Turf:getClientData(leftTeam,rightTeam)
    if(leftTeam == nil or rightTeam == nil) then
        leftTeam, rightTeam = self:getActiveTeams()
    end
    local data = { influence = self.influence }
    if(rightTeam) then
        data.rightTeam = {count = rightTeam.count or 0, alliance = rightTeam.isAlliance}
        data.rightTeam.name = rightTeam.isAlliance and exports.USGcnr_groups:getAllianceName(rightTeam.id) or exports.USGcnr_groups:getGroupName(rightTeam.id)
    end
    if(leftTeam) then
        data.leftTeam = {count = leftTeam.count or 0, alliance = leftTeam.isAlliance}
        data.leftTeam.name = leftTeam.isAlliance and exports.USGcnr_groups:getAllianceName(leftTeam.id) or exports.USGcnr_groups:getGroupName(leftTeam.id)  
    end
    return data 
end

local CopDetectionRange = 50

function checkForCopNearby(player)
	for k,cop in ipairs(exports.USGrooms:getPlayersInRoom("cnr"))do
		if(exports.USGcnr_jobs:getPlayerJobType(cop) == "police" and getPedWeapon(cop) == 43)then
		local px,py,pz = getElementPosition(player)
		local cx,cy,cz = getElementPosition(cop)
			if(getDistanceBetweenPoints3D ( px,py,pz, cx,cy,cz) <= CopDetectionRange)then
			exports.USGmsg:msg(player, getPlayerName(cop).." saw you turfing. You are now wanted!", 0, 255,0)
			exports.USGmsg:msg(cop,"You saw "..getPlayerName(player).." turfing and he is now wanted!", 0, 255,0)
			return true
			end
		end
	end
	return false
end

function Turf:setOwner(id, isAlliance)
    if(isAlliance) then
        self.ownerAlliance = id
    else
        self.ownerGroup = id
    end
    self.influence = 50
    for i,player in ipairs(self.players) do
        if(isElement(player.element)) then
            local group = exports.USGcnr_groups:getPlayerGroup(player.element)
            if(group and ( ( not isAlliance and id == group ) or ( isAlliance and id == exports.USGcnr_groups:getGroupAlliance(group) ) ) ) then
                exports.USGplayerstats:incrementPlayerStat(player.element, "cnr_turfstaken",1)
                givePlayerMoney(player.element, REWARD_CAPTURE)
                exports.USGcnr_score:givePlayerScore(player.element, REWARD_SCORE_CAPTURE)
                exports.USGmsg:msg(player.element, "You have recieved "..exports.USG:formatMoney(REWARD_CAPTURE).." and "..REWARD_SCORE_CAPTURE.." score for capturing a turf.", 0, 255,0)
				if(checkForCopNearby(player.element))then
				exports.USGcnr_wanted:givePlayerWantedLevel(player.element,TURF_CAPTUR_WL)
				end
			end
        end
    end
    self:updateColor()
end

function Turf:isPlayerOwner(player)
    local groupid = exports.USGcnr_groups:getPlayerGroup(player)
    local allianceid = exports.USGcnr_groups:getGroupAlliance(groupid)
    return self:isOwned() and ( ( type(groupid) == "number" and self.ownerGroup == groupid  ) or ( type(allianceid) == "number" and self.ownerAlliance == allianceid ) )
end

function Turf:setUnoccupied(influence)
    self.ownerGroup = false
    self.ownerAlliance = false
    --self.influence = influence or 20
    self:updateColor()
end

function Turf:updateStatus()
    for i,player in ipairs(self.players) do
        if(player:updateStatus() == PLAYER_STATUS_CAPTURING) then
            self.status = TURF_STATUS_CAPTURING
				if(self.blink)then
				setRadarAreaFlashing(self.radarArea, true)
				end
            return self.status
        end
    end
    self.status = TURF_STATUS_IDLE
    setRadarAreaFlashing(self.radarArea, false)
    return self.status
end

function Turf:colHit(hitElement, matchingDimension)
    if(not matchingDimension) then return end
    if(getElementType(hitElement) ~= "player") then return end
    if(self:isOwned()) then
        exports.USGmsg:msg(hitElement, "You entered a turf owned by the "..self:getFullOwnerName()..".",0,255,0)
    else
        exports.USGmsg:msg(hitElement, "You entered an unoccupied turf.",0,255,0)
    end
    TurfPlayer(hitElement, self)
end

function Turf:colLeave(leaveElement, matchingDimension)
    if(not matchingDimension) then return end
    if(getElementType(leaveElement) ~= "player") then return end
end

function Turf:isOwned()
    return type(self.ownerGroup) == "number" or type(self.ownerAlliance) == "number"
end

function Turf:getOwnerName()
    if(self.ownerGroup) then
        return exports.USGcnr_groups:getGroupName(self.ownerGroup)
    elseif(self.ownerAlliance) then
        return exports.USGcnr_groups:getAllianceName(self.ownerAlliance)
    end
    return false
end

function Turf:getFullOwnerName()
    if(self:isOwned()) then
        local pre = self.ownerGroup and "group" or "alliance"
        local name = self:getOwnerName()
        return pre.." "..name
    else
        return "Unoccupied"
    end
end

function Turf:removePlayer(player)
    for i, p in ipairs(self.players) do
        if(player == p) then
            table.remove(self.players,i)
            break
        end
    end
end