data = {}

function foo()
	if (not exports.USGaccounts:isPlayerLoggedIn(localPlayer)) then
		return false
	end
	
	playerMoney = getPlayerMoney(localPlayer)
	
	-- Only want one change at a time
	if (#data > 1) then	
		data = {}
	end
end
addEventHandler("onClientPreRender", root, foo)

function hasPlayerMoneyChanged()
	if (not exports.USGaccounts:isPlayerLoggedIn(localPlayer)) then
		return false
	end
	
	-- Check if the money changed
	if (playerMoney ~= getPlayerMoney(localPlayer)) then	
		-- Since their money changed, we need to gather some info
		local newMoney = getPlayerMoney(localPlayer)
		
		-- Determine if the player lost, or gained money (little things like calculating the difference on the client save the server a lot of CPU)
		if (tonumber(newMoney) and tonumber(playerMoney))then
			if (newMoney > playerMoney) then
				local difference = playerMoney - newMoney
				table.insert(data, {newMoney, playerMoney, tick})
			else
				local difference = newMoney - playerMoney
				table.insert(data, {newMoney, playerMoney, tick})
			end
		end
		
		triggerServerEvent("USGeconomy.onPlayerMoneyChange", localPlayer, data)
		
		--[[
		for i, v in ipairs(data) do
			if ((tick - tick_) < 25) then
				table.remove(data, 1)
			else
				triggerServerEvent("USGeconomy.onPlayerMoneyChange", localPlayer, data)
			end
		end
		--]]
	else
		--data = {}
		return
	end
end
addEventHandler("onClientRender", root, hasPlayerMoneyChanged)