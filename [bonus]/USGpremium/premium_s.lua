premiums = {}

function onResourceStart()
	if (getResourceState(getResourceFromName("mysql")) == "running") then
		local connection = exports.mysql:getConnection()
		if (connection) then
			dbQuery(premiumCallback,connection,"SELECT * FROM premium ORDER BY username ASC")
		else
			error("[PREMIUM] Failed to get database connection")
		end
	else
		error("[PREMIUM] MySQL not running!")
	end
end
addEventHandler("onResourceStart",resourceRoot,onResourceStart)

function onResourceStop()
	if (getResourceState(getResourceFromName("mysql")) == "running") then
		local connection = exports.mysql:getConnection()
		if (connection) then
			for k,v in pairs(premiums) do
				dbExec(connection,"UPDATE premium SET time=?,lastLogin=?,inactive=? WHERE username=?",v.timeLeft,v.lastLogin,v.premiumActive,k)
			end
		else
			error("Failed to update premium time (no DB connection) - Free premium i guess? :P")
		end
	else
		error("Failed to update premium time (no DB connection) - Free premium i guess? :P")
	end
end
addEventHandler("onResourceStop",resourceRoot,onResourceStop)

function premiumCallback(query)
	if (query) then
		local result = dbPoll(query,-1)
		if (result) then
			for k,v in ipairs(result) do
				outputDebugString("[User: "..v.username.."] Time left: "..v.time.." Date: "..v.boughtDate)
				premiums[v.username] = {timeLeft = v.time, latestBoughtDate = v.boughtdate, lastLogin = v.lastLogin, premiumActive = v.inactive}
			end
		else
			error("[PREMIUM] Failed to get result")
		end
	else
		error("[PREMIUM] Query didn't return! restart resource...")
	end
end

function decreasePremiumTime()
	--outputDebugString("decreaseTime")
	for k,v in pairs(premiums) do
		if (v.timeLeft == -5) then
			return false --unlimited premium
		end
		
		if (v.premiumActive == 1) then
			return false --Premium inactive
		end
		
		--outputDebugString("Running...")
		if (v.timeLeft <= 0) then
			removePremium(k)
			return
		end
		
		--outputDebugString("Time left: "..v.timeLeft)
		premiums[k].timeLeft = v.timeLeft - 1
		--outputDebugString("Time now: "..premiums[k].timeLeft)
	end
end
setTimer(decreasePremiumTime,60000,0)

function removePremium(account)
	if (account) then
		if (exports.mysql:isConnected()) then
			local connection = exports.mysql:getConnection()
			if (connection) then
				dbExec(connection,"DELETE FROM premium WHERE username=?",k)
			else
				error("Failed to remove - No DB connection")
			end
		else
			error("Failed to remove - No DB connection")
		end
	else
		return false
	end
end

function autoSave()
	--outputDebugString("Saving...")
	local connection = exports.mysql:getConnection()
	if (connection) then
		for k,v in pairs(premiums) do
			dbExec(connection,"UPDATE premium SET time=? WHERE username=?",premiums[k].timeLeft,k)
		end
	else
		error("[PREMIUM] Unable to save premium time (Connection could not be established)")
	end
end
setTimer(autoSave,60000*5,0)

function isPlayerPremium(player)
	if (not player) then
		return false
	end
	if (isElement(player)) and (getElementType(player) == "player") and (exports.USGaccounts:isPlayerLoggedIn(player)) then
		local account = exports.USGaccounts:getPlayerAccount(player)
		if (account) then
			if (premiums[account]) then return true else return false end
		else
			return false
		end
	else
		return false
	end
end

function getPlayerPremiumTime(player)
	if (isPlayerPremium(player)) then
		local account = exports.USGaccounts:getPlayerAccount(player)
		if (account) then
			if (premiums[account]) then
				return premiums[account].timeLeft
			else
				return false
			end
		else
			return nil
		end
	else
		return nil
	end
end

function setAccountPremiumActive(account,active)
	if not (type(account) == "string") then return nil end
	if not (type(active) == "boolean") then return nil end
	
	if (active == true) then
		state = 1
	else
		state = 0
	end
	
	if (premiums[account]) then
		premiums[account].premiumActive = state
	else
		return false
	end
end

addEvent("onServerPlayerLogin")
addEventHandler("onServerPlayerLogin",root,
function(player)
	local account = exports.USGaccounts:getPlayerAccount(player)
	if (account) then
		setAccountPremiumActive(account,false)
	end
end)