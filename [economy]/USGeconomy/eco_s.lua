function onPlayerMoneyChange(data)
	if (client) or (source) then
		for k, v in ipairs(data) do
			newMoney = v[1]
			oldMoney = v[2]
			tick = v[3]
		end
		
		if (newMoney < 0) then
			-- This *should not* be happening, we have to inform developers
			outputDebugString("USGeconomy :: Player "..getPlayerName(client).." has gone into negative funds ($"..oldMoney.." --> $"..newMoney..")")
			outputChatBox("You have gone into negative funds. This is a script mistake. Please contact a developer immediately.", client, 255, 0, 255)
			-- Maybe we should create some sort of logging thing so developers can go back and retrieve this data
		end
		if (newMoney > 90000000) then
			-- Calc the extra money, and put it in the bank, and notify the player
			local diffMoney = newMoney - 90000000
			exports.USGcnr_banking:deposit(client, diffMoney) -- This will automatically take the player's money as well
			
			-- Inform the player
			exports.USGmsg:msg(client, "You have too much money on you. But don't worry, we put the extra $"..diffMoney.." in the bank for you! ;)", 255, 255, 0, 5000)
		end
	else
		return false
	end
end
addEvent("USGeconomy.onPlayerMoneyChange", true)
addEventHandler("USGeconomy.onPlayerMoneyChange", root, onPlayerMoneyChange)

-- It isn't even needed, but it would be good to keep it here just in case we ever need it
--[[
function foo()
	for i, v in ipairs(getElementsByType("player")) do
		-- If it's over the max threshold
		if (getPlayerMoney(v) > 90000000) then
			playerNewMoney = getPlayerMoney(v) - 90000000
			exports.USGcnr_banking:deposit(v, playerNewMoney)
			exports.USGmsg:msg(v, "You have too much money on you. But don't worry, we put the extra $"..playerNewMoney.." in the bank for you! ;)", 255, 255, 0, 5000)
		end
	end
end
setTimer(foo, 120000, 0) -- Every two minutes
--]]
