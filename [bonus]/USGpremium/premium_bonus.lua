death = {}

addEvent("onServerPlayerLogin")
function onPlayerLogin(player)
	if (player) then
		if not (isPlayerPremium(player)) then
			return
		end
		
		local account = exports.USGaccounts:getPlayerAccount(player)
		if (account) then
			local lastLoginTime = premiums[account].lastBonus --get the timestamp
			local curTime = getTickCount()
			
			if ((math.floor(curTime - lastLoginTime) / 1000) >= 86400) then
				outputChatBox("PREMIUM: Here's your daily bonus! ($10,000)",player,0,255,0)
				givePlayerMoney(player, 10000)
				premiums[account].lastBonus = getTickCount() --UPDATE!
			end
		end
		
		setElementData(player,"Premium","Yes")
	else
		return false
	end
end
addEventHandler("onServerPlayerLogin",root,onPlayerLogin)

--[[
function onWasted(_,killer)
	if (killer) then
]]