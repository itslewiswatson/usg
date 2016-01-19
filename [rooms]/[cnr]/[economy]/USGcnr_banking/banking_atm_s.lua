addEvent("USGcnr_banking.requestATMData", true)
function requestATMData(player)
	local balance = getPlayerBankBalance(player)
	local transactions = exports.USGcnr_money:getPlayerTransactions(player)
	triggerClientEvent(player, "USGcnr_banking.recieveATMData", player, balance, transactions)
end
addEventHandler("USGcnr_banking.requestATMData", root, function () requestATMData(source) end)

addEvent("USGcnr_banking.deposit", true)
function onPlayerDeposit(amount)
	if(not isElement(client) or getElementType(client) ~= "player") then return false end
	if(not exports.USGaccounts:isPlayerLoggedIn(client) or exports.USGrooms:getPlayerRoom(client) ~= "cnr") then return false end
	if(getPlayerMoney(client) >= amount) then
		 if(deposit(client,amount)) then
			requestATMData(client)
		end
	else
		exports.USGmsg:msg(client, "You do not have $"..amount.." to deposit to the bank!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_banking.deposit", root, onPlayerDeposit)

addEvent("USGcnr_banking.withdraw", true)
function onPlayerWithdraw(amount)
	if(not isElement(client) or getElementType(client) ~= "player") then return false end
	if(not exports.USGaccounts:isPlayerLoggedIn(client) or exports.USGrooms:getPlayerRoom(client) ~= "cnr") then return false end
	if(getPlayerBankBalance(client) >= amount) then
		if(withdraw(client,amount)) then
			requestATMData(client)
		end
	else
		exports.USGmsg:msg(client, "You do not have $"..amount.." on your bank account to withdraw from!", 255, 0, 0)
	end
end
addEventHandler("USGcnr_banking.withdraw", root, onPlayerWithdraw)