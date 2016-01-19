loadstring(exports.MySQL:getQueryTool())()

_setPedWalkingStyle = setPedWalkingStyle
function setPedWalkingStyle(id)
	_setPedWalkingStyle(source, id)
	local account = exports.USGaccounts:getPlayerAccount(source)
	exports.MySQL:execute("UPDATE `cnr__accounts` SET `walks`=? WHERE `username`=?", id, account)
end
addEvent("USGwalkingstyles.setPedWalkingStyle", true)
addEventHandler("USGwalkingstyles.setPedWalkingStyle", root, setPedWalkingStyle)

function loadPlayerWalkStyle(plr)
	local account = exports.USGaccounts:getPlayerAccount(plr)
	foo = exports.MySQL:query("SELECT `walks` FROM `cnr__accounts` WHERE `username`=? LIMIT 1", account)
	if (not foo)then return end
	ws = foo[1].walks
	if (tonumber(ws)) then
		_setPedWalkingStyle(plr, tonumber(ws))
	end
end


addEvent("onPlayerJoinRoom")
function onPlayerJoinRoom(room)
	if (room == "cnr") then
		loadPlayerWalkStyle(source)
	end
end
addEventHandler("onPlayerJoinRoom", root, onPlayerJoinRoom)
