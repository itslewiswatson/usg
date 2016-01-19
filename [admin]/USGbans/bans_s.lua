loadstring(exports.mysql:getQueryTool())()

-- type 0 = serial type 1 = account
idBan = {}
serialBans = {} -- type 0
accountBans = {} -- type 1
addEventHandler("onResourceStart", resourceRoot,
	function ()
		query(loadBans, {}, "SELECT * FROM bans")
	end
)

function loadBans(dbBans)
	for i, ban in ipairs(dbBans) do
		if(ban.endtimestamp < getRealTime().timestamp) then
			exports.MySQL:execute("DELETE FROM bans WHERE id=?", ban.id) -- expired
		else
			if(ban.type == "serial") then
				serialBans[ban.target] = ban
			elseif(ban.type == "account") then
				accountBans[ban.target] = ban
			end
			idBan[ban.id] = ban
		end
	end
end

function addBan(banType, target, reason, bannedby, duration)
	if(banType ~= "serial" and banType ~= "account") then error("banType must be 'serial' or 'account'") end
	if(type(target) ~= "string") then error("target must be a string containing account or serial") end
	if(type(reason) ~= "string") then error("reason must be a string") end
	if(type(bannedby) ~= "string") then bannedby = "Unknown" end
	if(type(duration) ~= "number") then error("duration must be a number") end
	local banEnd = getRealTime().timestamp+duration
	local success = true
	local ban = {type=banType,target=target,reason=reason,bannedby=bannedby,endtimestamp = banEnd}
	if(banType == "serial") then
		if(serialBans[ban.target] and serialBans[ban.target].endtimestamp < getRealTime().timestamp) then
			outputDebugString("this serial already has a ban, extending it instead")
			ban.reason = serialBans[ban.target].reason..ban.reason
			ban.bannedby = serialBans[ban.target].bannedby.."\\"..ban.bannedby
			ban.endtimestamp = serialBans[ban.target].endtimestamp+duration
			serialBans[ban.target] = ban
			idBan[serialBans[ban.target].id] = ban
		else
			success = insert(onBanInserted, {ban}, "INSERT INTO bans (type, target, reason, bannedby, endtimestamp) VALUES (?,?,?,?,?)",banType,target,reason,bannedby,banEnd)
		end
	elseif(banType == "account") then
		if(accountBans[ban.target] and accountBans[ban.target].endtimestamp < getRealTime().timestamp) then
			outputDebugString("this account already has a ban, extending it instead")
			ban.reason = accountBans[ban.target].reason..ban.reason
			ban.bannedby = accountBans[ban.target].bannedby.."\\"..ban.bannedby
			ban.endtimestamp = accountBans[ban.target].endtimestamp+duration
			accountBans[ban.target] = ban
			idBan[accountBans[ban.target].id] = ban
		else
			success = insert(onBanInserted, {ban}, "INSERT INTO bans (type, target, reason, bannedby, endtimestamp) VALUES (?,?,?,?,?)",banType,target,reason,bannedby,banEnd)
		end
	end
	return success
end

function onBanInserted(insertid, ban)
	ban.id = insertid
	if(ban.type == "serial") then
		serialBans[ban.target] = ban
	elseif(ban.type == "account") then
		accountBans[ban.target] = ban
	end
	idBan[ban.id] = ban
end

function removeBan(banID)
	if(type(banID) ~= "number") then error("banid must be a number") end
	local ban = idBan[banID]
	if(ban and ban.type == "serial") then
		serialBans[ban.target] = nil
	elseif(ban and ban.type == "account") then
		accountBans[ban.target] = nil
	end
	idBan[banID] = nil
	return exports.MySQL:execute("DELETE FROM bans WHERE id=?", banID)
end

function getSerialBan(serial)
	if(serialBans[serial]) then
		return serialBans[serial]
	else
		return false
	end
end

function getAccountBan(account)
	if(accountBans[account]) then
		return accountBans[account]
	else
		return false
	end
end

function isSerialBanned(serial)
	return serialBans[serial] ~= nil and serialBans[serial].endtimestamp < getRealTime().timestamp
end

function isAccountBanned(account)
	return accountBans[account] ~= nil and accountBans[account].endtimestamp < getRealTime().timestamp
end

function getBans()
	local bans = {}
	for id, ban in pairs(idBan) do
		table.insert(bans, ban)
	end
	return bans
end

function getSerialBans()
	local bans = {}
	for serial, ban in pairs(serialBans) do
		table.insert(bans, ban)
	end
	return bans
end

function getAccountBans()
	local bans = {}
	for account, ban in pairs(accountBans) do
		table.insert(bans, ban)
	end
	return bans
end