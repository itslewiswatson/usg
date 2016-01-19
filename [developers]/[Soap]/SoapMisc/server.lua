function teamColors ()
    setTeamColor(getTeamFromName("Staff"),0,128,128)
    setTeamColor(getTeamFromName("Criminals"),183, 0,0)
    setTeamColor(getTeamFromName("Police"), 0 ,76 ,253)
    setTeamColor(getTeamFromName("Unemployed"),204 ,102 ,0)
    setTeamColor(getTeamFromName("Civilians"),255,255,0)
    
end
addEventHandler ( "onResourceStart", root, teamColors )

rootElement = getRootElement()
 
function removeHEXColor(oldNick,newNick)
    local name = getPlayerName(source)
    if newNick then
        name = newNick
    end
    if (string.find(name,"#%x%x%x%x%x%x")) then
        local name = string.gsub(name,"#%x%x%x%x%x%x","")
        setPlayerName(source,name)
        if (newNick) then
        cancelEvent()
        end
    end 
end
addEventHandler("onPlayerJoin",rootElement,removeHEXColor)
addEventHandler("onPlayerChangeNick",rootElement,removeHEXColor)