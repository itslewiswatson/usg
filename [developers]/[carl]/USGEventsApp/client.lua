local eventGUI = {}

function createeventGUI()
    exports.USGGUI:setDefaultTextAlignment("left","center")
    eventGUI.window = exports.USGGUI:createWindow("right","bottom", 300, 300, false,"Events")
	eventGUI.eventgrid = exports.USGGUI:createGridList("center","top",298,299,false,eventGUI.window)
    exports.USGGUI:gridlistAddColumn(eventGUI.eventgrid, "Event", 0.35)
    exports.USGGUI:gridlistAddColumn(eventGUI.eventgrid, "Time Left", 1 - 0.35)
end

function refreshGUI()
exports.USGGUI:gridlistClear(eventGUI.eventgrid)
end

function toggleEventGUI()
if(not exports.USGaccounts:isPlayerLoggedIn()) then return end
    if(isElement(eventGUI.window )) then
        if(exports.USGGUI:getVisible(eventGUI.window )) then
            exports.USGGUI:setVisible(eventGUI.window , false)
        else
            exports.USGGUI:setVisible(eventGUI.window , true)
        end
    else
        createeventGUI()
    end 
end 
addCommandHandler("eventstime",toggleEventGUI)