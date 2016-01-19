local gatesTable = {
    --------------------------------------------------------------------
    ------------------- ADD HERE AS MUCH GATES YOU WANT! ---------------
    -- EXAMPLE: {ObjectgateID, closedX, closedY, closedZ, closedRoationX, closedRoationY, closedRoationZ, openX, openY, openZ, openSpeed, colSize, groupName, Team
    -- NOTE: If the base is for a group only just add nil on the place where the team should be
    --------------------------------------------------------------------
    --------------------------------------------------Jail Doors-------------------------------------------------

    --------------------------------------------------Interior Doors---------------------------------------------
    {1537,1369.4,-1281.3,12.6,0,0,270,1369.4,-1283,12.6,500,5,"ALL"},
   
    --------------------------------------------------LAW GROUPS-------------------------------------------------
    
    --NG
    
    {2927,211.9,1875.1,13.9,0,0,0,207.9,1875.1,13.9,500,15,"National Guard"},
    {2927,216,1875.1,13.9,0,0,0,220,1875.1,13.9,500,15,"National Guard"},
    {971,343,1793.5,20.8,0,0,38.996,334.1142578125, 1787.21875,20.8,500,15,"National Guard"},
    {971,349.79999,1799,20.8,0,0,38.996,353.83984375, 1801.2734375,20.8,500,15,"National Guard"},
    {971,139.60001,1941.3,21.9,0,0,0,145, 1941.505859375,21.9,500,15,"National Guard"},
    {971,130.78,1941.3,21.9,0,0,0,124.78, 1941.505859375,21.9,500,15,"National Guard"},
    {971,91.6,1925.6,20.58,0,0,90,91.6,1931.6,20.58,500,15,"National Guard"},
    {971,91.6,1916.79,20.58,0,0,270,91.6,1910.79,20.58,500,15,"National Guard"},
    
    --- C
    {980,2888.5634765625, 1917.33203125, 19.09001159668, 0,0,180,2888.5634765625, 1917.33203125, 13.09001159668,500,10,"The-Cobras"},
    {980,2869, 1917.332031125, 19.092948913574, 0,0,180,2869,  1917.332031125, 13.092948913574,500,10,"The-Cobras"},
    ----H
    {980,2629.01953125, 657.1767578125, 17.629687309,0,0,0,2629.01953125, 657.1767578125, 11.62968730,500,10,"TheHomeless"},
    {980,2635.9952734375, 568.1669921875, 17.1925888,0,0,0,2635.9952734375, 568.1669921875, 11.61925888,500,10,"TheHomeless"},
    --------------------------------------------- CRIMINAL GROUPS------------------------------------------------
    ---------------------------------------------- EVERYONE-------------------------------------------------------
    
    --------------------------------------------------------------------
    -------------- CHANGE ONLY STUFF BETWEEN THIS AND ABOVE ------------
    --------------------------------------------------------------------
}



theGateID = {}
theGateElement = {}
moving = {}
open={}
for i=1,30 do moving[i]=false open[i]=false end
function isLaw(p)
    local name = getTeamName(getPlayerTeam(p))
    if name == "Police" or name == "SWAT" or name == "National Guard" or name == "Staff" then return true end
    return false
end

function gateOpen ( hitElement, matchingDimension,col)
if (col) then source=col end
local theGate = theGateElement[source] -- source is col, in die table zitten cols gelinked aan hun gate object; als je terug ben upload dit en kijk of het werkt
    if (theGate) and (getElementType(hitElement) == "player") and (theGateID[theGate]) then
        local ID = theGateID[theGate]
        if open[ID]==true then return end
        --if moving[ID]==true then return end
        local x,y,z = getElementPosition ( theGate ) -- hoe kom je aan theGate? ik denk dat ie een andere opent. Ik denk dat dit werkt
        if ((getElementType(hitElement) == "player" and matchingDimension) or (col) ) then
            if (gatesTable[ID].mustBeInVeh) then if isPedInVehicle(hitElement) == false then return end end
            if (col) then hitElement=col end
            if (getElementDimension(hitElement) == 0) then
                local x2, y2, z2 = getElementPosition(hitElement)
                if ((col) or ((z2 < gatesTable[ID][4] +5) and (z2 > gatesTable[ID][4] -5)) or (gatesTable[ID].gateColZ ~= nil and (z2 < gatesTable[ID].gateColZ +5) and (z2 > gatesTable[ID].gateColZ -5))) then
                    if ((col) or (exports.USGcnr_groups:getPlayerGroupName(hitElement) and ((exports.USGcnr_groups:getPlayerGroupName(hitElement) == gatesTable[ID][13] or ((gatesTable[ID].secondGroup) and exports.USGcnr_groups:getPlayerGroupName(hitElement) == gatesTable[ID].secondGroup)) or  (getPlayerTeam(hitElement) or checkAllianceAccess(hitElement)) and getTeamName(getPlayerTeam(hitElement)) == "Staff" )) or (getPlayerTeam(hitElement) and getTeamName(getPlayerTeam(hitElement)) == gatesTable[ID][14] )) then
                        if gatesTable[ID][13] ~= nil and gatesTable[ID][13] == "LAW" then
                            if moving[ID]==true then return end
                        end
                        if gatesTable[ID][15] ~= nil then
                            moveObject( theGate, gatesTable[ID][11], gatesTable[ID][8], gatesTable[ID][9], gatesTable[ID][10],gatesTable[ID][15],gatesTable[ID][16],gatesTable[ID][17] )
                            moving[ID]=true
                            open[ID]=true
                            setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                        else
                            moving[ID]=true
                            open[ID]=true
                            setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                            moveObject( theGate, gatesTable[ID][11], gatesTable[ID][8], gatesTable[ID][9], gatesTable[ID][10] ) -- geen errors, geen move, niks, rest allemaal wel
                        end
                    elseif gatesTable[ID][13] == "LAW" then
                        if moving[ID]==true then return end
                        if isLaw(hitElement) == true then
                            moving[ID]=true
                            open[ID]=true
                            setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                            moveObject( theGate, gatesTable[ID][11], gatesTable[ID][8], gatesTable[ID][9], gatesTable[ID][10],gatesTable[ID][15],gatesTable[ID][16],gatesTable[ID][17] )
                        end
                    elseif gatesTable[ID][13] == "ALL" then
                        if moving[ID]==true then return end
                        --if isLaw(hitElement) == true then
                            moving[ID]=true
                            open[ID]=true
                            setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                            moveObject( theGate, gatesTable[ID][11], gatesTable[ID][8], gatesTable[ID][9], gatesTable[ID][10],gatesTable[ID][15],gatesTable[ID][16],gatesTable[ID][17] )
                        --end
                    end
                end
            end
        end
    end
end

function gateClose (hitElement, matchingDimension, col )
if (col) then source=col end
local theGate = theGateElement[source]
    if (theGate) and (getElementType(hitElement) == "player") then
        local ID = theGateID[theGate]
        if open[ID]==false then return end
        --if moving[ID]==true then return end
        local x,y,z = getElementPosition ( theGate )
        if ((getElementType(hitElement) == "player" and matchingDimension) or (col) ) then
        if (gatesTable[ID].mustBeInVeh) then if isPedInVehicle(hitElement) == false then return end end
            if (col) then hitElement=col end
            local x2, y2, z2 = getElementPosition(hitElement)
            if ((z2 < gatesTable[ID][4] +5) and (z2 > gatesTable[ID][4] -5)) or (gatesTable[ID].gateColZ ~= nil and (z2 < gatesTable[ID].gateColZ +5) and (z2 > gatesTable[ID].gateColZ -5)) then
                if ((col) or (exports.USGcnr_groups:getPlayerGroupName(hitElement) and ((exports.USGcnr_groups:getPlayerGroupName(hitElement) == gatesTable[ID][13] or ((gatesTable[ID].secondGroup) and exports.USGcnr_groups:getPlayerGroupName(hitElement) == gatesTable[ID].secondGroup)) or  (getPlayerTeam(hitElement) or checkAllianceAccess(hitElement)) and getTeamName(getPlayerTeam(hitElement)) == "Staff" )) or (getPlayerTeam(hitElement) and getTeamName(getPlayerTeam(hitElement)) == gatesTable[ID][14] )) then
                    if gatesTable[ID][13] ~= nil and gatesTable[ID][13] == "LAW" then
                            if moving[ID]==true then return end
                        end
                    if gatesTable[ID][15] ~= nil then
                        moving[ID]=true
                        open[ID]=false
                        setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                        moveObject( theGate, gatesTable[ID][11], gatesTable[ID][2], gatesTable[ID][3], gatesTable[ID][4], gatesTable[ID][18], gatesTable[ID][19], gatesTable[ID][20] )
                    else
                        moving[ID]=true
                        open[ID]=false
                        setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                        moveObject( theGate, gatesTable[ID][11], gatesTable[ID][2], gatesTable[ID][3], gatesTable[ID][4] )
                    end
                elseif gatesTable[ID][13] == "LAW" then
                    if moving[ID]==true then return end
                    if isLaw(hitElement) == true then
                        moving[ID]=true
                        open[ID]=false
                        setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                        moveObject( theGate, gatesTable[ID][11], gatesTable[ID][2], gatesTable[ID][3], gatesTable[ID][4], gatesTable[ID][18], gatesTable[ID][19], gatesTable[ID][20] )
                    end
                elseif gatesTable[ID][13] == "ALL" then
                    if moving[ID]==true then return end
                    --if isLaw(hitElement) == true then
                        moving[ID]=true
                        open[ID]=false
                        setTimer(function() moving[ID]=false end,gatesTable[ID][11]+500,1)
                        moveObject( theGate, gatesTable[ID][11], gatesTable[ID][2], gatesTable[ID][3], gatesTable[ID][4], gatesTable[ID][18], gatesTable[ID][19], gatesTable[ID][20] )
                    --end
                end
            end
        end
    end
end


for ID, gates in ipairs(gatesTable) do
    local theGateCol = false
    if gates.gateColZ == nil then
        theGateCol=createColSphere ( gates[2], gates[3], gates[4], gates[12] )
    else
        theGateCol= createColSphere ( gates[2], gates[3], gates.gateColZ, gates[12] )

    end
    local theGate = createObject ( gates[1], gates[2], gates[3], gates[4], gates[5], gates[6], gates[7] )
    theGateElement[theGateCol] = theGate
    theGateID[theGate] = ID
    if gates.scale ~= nil then setObjectScale(theGate,gates.scale) end
    if gates.image ~= nil then
        newShaderGate(theGate,gates.image)
    end
    if gates.command ~= nil then
        addCommandHandler(gates.command,function(ps,cmd,state)

            local id = ID
            if open[ID] == true and state == "close" then
                --if gates.command == "togdice" then
                --  setTimer(function() gateClose(ps,true,theGateCol) end,math.random(2500),1)
                --else
                    gateClose(ps,true,theGateCol)
                --end

            elseif open[ID] == false and state == "open" then
                --if gates.command == "togdice" then
                --  setTimer(function() gateOpen(ps,true,theGateCol) end,math.random(2500),1)
                --else
                    gateOpen(ps,true,theGateCol)
                --end

            end
        end,restricted)
    end
    addEventHandler( "onColShapeHit", theGateCol, gateOpen )
    addEventHandler( "onColShapeLeave", theGateCol, gateClose )
end


--
