rules = {}
reasons = {}

function loadRules()
	rules = {}
	reasons = {}
	local xml
	if ( fileExists("Punishments\\rules.xml") ) then xml = xmlLoadFile("Punishments\\rules.xml") 
		else return false end
	local ruleNodes = xmlNodeGetChildren(xml)
	for id,rule in ipairs(ruleNodes) do
		local ruleText = exports.USG:trimString(xmlNodeGetValue(rule))
		local punishText = xmlNodeGetAttribute(rule,"punish")
		local ruleInfos = {}
		for infoID,info in ipairs(xmlNodeGetChildren(rule)) do
			table.insert(ruleInfos,xmlNodeGetValue(info))
		end
		table.insert(rules,{id = id, text = ruleText, infos = ruleInfos, punish = punishText})
		if ( punishText ) then
			table.insert(reasons,punishText)
		end
	end
	xmlUnloadFile(xml)
end
addEventHandler("onResourceStart", resourceRoot,loadRules)

addEvent("USGadmin.requestRules", true)
function requestRules()
	triggerClientEvent(source,"USGadmin.receiveRules",source,rules,reasons)

end
addEventHandler("USGadmin.requestRules", root, requestRules)

function showPlayerRules(player, timeout)
	if(not isElement(player) or getElementType(player) ~= "player" or not exports.USGAccounts:isPlayerLoggedIn(player)) then return false end
	return triggerClientEvent(player, "USGadmin.showRules", player, timeout)
end