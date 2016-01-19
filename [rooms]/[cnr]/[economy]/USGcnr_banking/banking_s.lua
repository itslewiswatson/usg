local bankAccounts = {}
local bankClosed = true --close the bank until bank accounts are loaded.

function onStart()
	if (getResourceState(getResourceFromName("mysql")) == "running") and (exports.mysql:isConnected() == true) then
		local connection = exports.mysql:getConnection()
		if not (connection) then
			setTimer(onStart,3000,1)
			error("[BANKING] Failed to get MySQL connection, retrying in 3 seconds...")
			return false
		end
		dbQuery(bankCallback,connection,"SELECT * FROM cnr__banking")
	else
		setTimer(onStart,3000,1)
		error("[BANKING] Couldn't retrieve connection from MySQL as its offline/not connected. retrying in 3 seconds...")
		return false
	end
end
addEventHandler("onResourceStart",resourceRoot,onStart)

function bankCallback(query)
	if (query) then
		local results = dbPoll(query,-1)
		if (results) then
			for k,v in ipairs(results) do
				--outputDebugString("[Bank username: "..v.username.."] Balance: "..v.balance)
				bankAccounts[v.username] = {balance=v.balance}
			end
			
			bankClosed = false
		else
			setTimer(onStart,3000,1)
			error("[BANKING] Couldn't get results for bank accounts, retrying...")
			return false
		end
	else
		error("[BANKING] Couldn't get query back from callback, retrying...")
		return false
	end
end

function getPlayerBankBalance(player)
	if (isElement(player)) and (getElementType(player) == "player") then
		if not (exports.USGaccounts:isPlayerLoggedIn(player)) then return "ERROR - NLI" end
		
		local account = exports.USGaccounts:getPlayerAccount(player)
		if (bankAccounts[account]) then
			return bankAccounts[account].balance
		else
			createBankAccount(account) --player has no bank account, create new...
			return 0
		end
	else
		return false
	end
end

function takePlayerBankBalance(player, amount)
	if (not isElement(player) or getElementType(player) ~= "player") then return false end
	if not (exports.USGaccounts:isPlayerLoggedIn(player)) then return false end
		
	local account = exports.USGaccounts:getPlayerAccount(player)
	if (bankAccounts[account] and bankAccounts[account].balance >= amount) then
		bankAccounts[account].balance = bankAccounts[account].balance - amount
		exports.MySQL:execute("UPDATE cnr__banking SET balance=? WHERE username=?",bankAccounts[account].balance,account)
		return true
	end
	return false
end

function createBankAccount(element)
	local account
	--run check see whether we've got a player or string
	if (element) then
		if (isElement(element)) then --possibly the player
			if (getElementType(element) == "player") then
				if not (exports.USGaccounts:isPlayerLoggedIn(element)) then return false end
				
				account = exports.USGaccounts:getPlayerAccount(element)
			else
				return false
			end
		elseif (type(element) == "string") then
			account = element
		else
			return false
		end
	else
		return false
	end
		
	if not (account) or (account == "") then return false end
	
	--get the MySQL connection--
	if (getResourceState(getResourceFromName("mysql")) == "running") and (exports.mysql:isConnected() == true) then
		local connection = exports.mysql:getConnection()
		if (connection) then
			dbExec(connection,"INSERT INTO cnr__banking (username,balance) VALUES (?,?)",account,0)
			bankAccounts[account] = {balance = 0}
		else
			error("[BANKING] Failed creating a bank account for "..account.." due to no MySQL connection!")
		end
	else
		error("[BANKING] Failed creating a bank account for "..account.." due to MySQL being off!")
	end
end

function deposit(player, amount)
	if(not isElement(player) or getElementType(player) ~= "player") then return false end
	if( not exports.USGaccounts:isPlayerLoggedIn(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(getPlayerMoney(player) >= amount) then
		takePlayerMoney(player, amount)
		bankAccounts[account].balance = bankAccounts[account].balance +	amount
		exports.MySQL:execute("UPDATE cnr__banking SET balance=? WHERE username=?",bankAccounts[account].balance,account)
		return true
	else
		return false
	end
end

function withdraw(player,amount)
	if(not isElement(player) or getElementType(player) ~= "player") then return false end
	if( not exports.USGaccounts:isPlayerLoggedIn(player) or exports.USGrooms:getPlayerRoom(player) ~= "cnr") then return false end
	local account = exports.USGaccounts:getPlayerAccount(player)
	if(bankAccounts[account].balance >= amount) then
		givePlayerMoney(player, amount)
		bankAccounts[account].balance = bankAccounts[account].balance - amount
		exports.MySQL:execute("UPDATE cnr__banking SET balance=? WHERE username=?",bankAccounts[account].balance,account)
		return true
	else
		return false
	end
end