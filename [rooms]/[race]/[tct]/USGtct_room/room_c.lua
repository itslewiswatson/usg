
addEvent("USGtct_room.open",true)


addEvent("USGtct_room.prepareRound", true)
function prepareRound()
    -- init countdown
    exports.USGrace_countdown:startCountdown(4, true)
    -- spawn protection

end
addEventHandler("USGtct_room.prepareRound", root, prepareRound)

local roundWinner = false
local startAnnounceTick = 0

addEvent("USGtct.announceWinner", true)
function announceWinner(winner)
    if(exports.USGrooms:getPlayerRoom() ~= "tct") then return false end

    if(not roundWinner) then
        addEventHandler("onClientRender", root, renderWinner)
    end
    roundWinner = winner
    startAnnounceTick = getTickCount()  
end
addEventHandler("USGtct.announceWinner", root, announceWinner)

addEvent("onPlayerExitRoom", true)
function stopAnnouncingWinner()
    if(roundWinner) then
        roundWinner = false
        removeEventHandler("onClientRender", root, renderWinner)
    end
end
addEventHandler("onPlayerExitRoom", localPlayer, 
    function (prevRoom)
        if(prevRoom == "tct") then
            setPedCanBeKnockedOffBike(localPlayer, true)
        end
        stopAnnouncingWinner()
    end
)

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer, 
    function (room)
        if(room == "tct") then
            setPedCanBeKnockedOffBike(localPlayer, false)
        end
    end
)

addEvent("USGtct.roundEnd", true)
function onRoundEnd()
    exports.USGrace_ranklist:clear()
    stopAnnouncingWinner()
end
addEventHandler("USGtct.roundEnd", root, onRoundEnd)

local screenWidth, screenHeight = guiGetScreenSize()
function renderWinner()
    if(getTickCount() - startAnnounceTick < 5000) then
        dxDrawText("Winner:\n\n"..roundWinner, 0, 0, screenWidth, screenHeight, tocolor(180,255,180),4,"default-bold","center","center")
    else
        stopAnnouncingWinner()
    end
end

addEvent("USGtct_room.playerWasted", true)
function onPlayerWasted(rank, time, nick)
    exports.USGrace_ranklist:add(source, rank, time, nick)
end
addEventHandler("USGtct_room.playerWasted", root, onPlayerWasted)
