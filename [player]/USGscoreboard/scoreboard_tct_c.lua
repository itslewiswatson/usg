tct = {}

function cnr.getPlayerTeam(player)
    return getElementData(player,"Team") or ""
end


roomColumns["tct"] = {
    { "Team", cnr.getPlayerTeam },

}
