local accountTimeout = {}

local MEDICINES_REWARD = 2

addEvent("USGcnr_robshop.onRobComplete", true)
function onRobComplete(reward)
	local account = exports.USGaccounts:getPlayerAccount(client)
	if(not account or (accountTimeout[account] and getTickCount()-accountTimeout[account] < 180000)) then return end
	accountTimeout[account] = getTickCount()
	givePlayerMoney(client, reward)
	exports.USGcnr_wanted:givePlayerWantedLevel(client, 4)
	exports.USGcnr_medicines:givePlayerMedicines(client, "Steroid", MEDICINES_REWARD)
	exports.USGcnr_medicines:givePlayerMedicines(client, "Aspirin", MEDICINES_REWARD)
end
addEventHandler("USGcnr_robshop.onRobComplete", root, onRobComplete)