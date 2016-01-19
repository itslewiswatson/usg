local maxMoneyOnHand = 200000
local moneyLostOnHandAfterDeath = 0.025

function buyItem(player, price, name)
	if(not isElement(player) or not exports.USGaccounts:isPlayerLoggedIn(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	local bankBalance = exports.USGcnr_banking:getPlayerBankBalance(player)
	local inHand = getPlayerMoney(player)
	local success = false
	if(inHand >= price) then
		takePlayerMoney(player, price)
		success = true
	elseif(bankBalance+inHand >= price) then
		local amountLeft = price - inHand
		local fromBank = exports.USGcnr_banking:takePlayerBankBalance(player, amountLeft)
		if(fromBank) then -- take the rest
			takePlayerMoney(player, inHand)
			success = true
		end
	end
	if(success) then
		exports.USGmsg:msg(player, "You have successfully bought "..name.."!", 0, 255, 0)
	else
		exports.USGmsg:msg(player, "You do not have enough money to buy "..name.." ( "..exports.USG:formatMoney(bankBalance+inHand).."/"..exports.USG:formatMoney(price).." )!", 255, 0, 0)
	end
	return success
end

-- transactions
loadstring(exports.mysql:getQueryTool())()
local playerTransactions = {}

function logTransaction(player, text)
	if(not isElement(player) or not exports.USGaccounts:isPlayerLoggedIn(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	if(type(text) ~= "string") then return false end
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(type(account) ~= "string") then return false end
	local datetime = exports.USG:getDateTimeString()
	if(playerTransactions[player]) then
		table.remove(playerTransactions[player], 1)	
		table.insert(playerTransactions[player], {text=text,datetime=datetime})
	end
	exports.mysql:execute("INSERT INTO cnr__transactions ( username, text, datetime ) VALUES (?, ?, ?)",account,text,datetime)
end

function loadPlayerTransactions(player)
	if(not isElement(player) or not exports.USGaccounts:isPlayerLoggedIn(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(type(account) ~= "string") then return false end	
	return query(loadTransactionsCallback, {player}, "SELECT text,datetime FROM cnr__transactions WHERE username=? ORDER BY id ASC LIMIT 30",account) -- load most recent 30 transactions
end

function loadTransactionsCallback(transactions, player)
	if(not isElement(player) or not exports.USGaccounts:isPlayerLoggedIn(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	playerTransactions[player] = transactions
end

function clearPlayerTransactions(player)
	if(player) then
		playerTransactions[player] = nil
	end
end

addEventHandler("onPlayerJoinRoom", root, 
	function (room)
		if(room == "cnr") then
			loadPlayerTransactions(source)
		end
	end
)

addEventHandler("onResourceStart", resourceRoot, 
	function ()
		local players = exports.USGrooms:getPlayersInRoom("cnr")
		for i, player in ipairs(players) do
			loadPlayerTransactions(player)
		end
	end
)
addEventHandler("onPlayerExitRoom", root, 
	function (prevRoom)
		if(prevRoom == "cnr") then
			clearPlayerTransactions(source)
		end
	end
)

addEventHandler("onPlayerQuit", root, 
	function ()
		clearPlayerTransactions(source)
	end
)

addEventHandler ( "onPlayerWasted", root,function()
if(not isElement(source) or not exports.USGaccounts:isPlayerLoggedIn(source) or exports.USGrooms:getPlayerRoom(source) ~= "cnr") then return false end
	if(getPlayerMoney(source) > maxMoneyOnHand)then
	local moneyToLoose = math.floor(getPlayerMoney(source) * moneyLostOnHandAfterDeath)
	takePlayerMoney(source,moneyToLoose)
	exports.USGmsg:msg(source, "You where caying too much money on hand and lost "..tostring(moneyToLoose).."$!", 0, 255, 0)
	end
end )

function getPlayerTransactions(player)
	if(not isElement(player) or not exports.USGaccounts:isPlayerLoggedIn(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	return playerTransactions[player] or {}
end