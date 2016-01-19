local tabACL = 
{
	["playeractions"] = { tab = 1; giveMoney = 4; giveWeapon = 2; };
	["playerinfo"] = { tab = 1 };
	["playerlookup"] = { tab = 3 };
	["punishing"] = { tab = 1 };
	["accounts"] = { tab = 4 };
	["server"] = { tab = 5 };
	["bans"] = { tab = 3, removeBan = 5, addBan = 5 };
}

function applyACL(guiTable,valueTable)
	if not ( guiTable ) then
		guiTable = panelGUI
		valueTable = tabACL
	end
	local pLevel = exports.USGadmin:getPlayerStaffLevel()
	for key, val in pairs(valueTable) do
		if ( guiTable[key] ) then
			if ( type(val) ~= "table" ) then
				exports.USGGUI:setEnabled(guiTable[key], pLevel >= val)
			else
				applyACL(guiTable[key],val)
			end
		end
	end
end