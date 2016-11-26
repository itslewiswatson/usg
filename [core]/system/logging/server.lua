function log(logType,text,player)
	if (type(text) ~= "string" or text == "") then
		error "Missing 'text' or empty"
	else
		--Lower the important things
		local resurce = getResourceName(sourceResource):lower()
		local logType = logType:lower()
		local nick,account,serial = nil,nil,nil
		if (isElement(player)) then
			--Declare the players data.
			nick = getPlayerName(player)
			account = exports.USGaccounts:getPlayerAccount(player)
			serial = getPlayerSerial(player)
		end
		
		--Now, to put everything into the database.
		if (exports.mysql:isConnected()) then
			if (exports.mysql:execute("INSERT INTO logs (resource,logType,nick,account,serial,log,date) VALUES (?,?,?,?,?,?,NOW())",resource,logType,nick,account, serial, text)) then
				return true
			else
				return "ERROR 4" --return "Database Error"
			end
		else
			return "ERROR 0" --return "Connection Error"
		end
	end
end

function logNotice(text)
	if (type(text) ~= "string" or text == "") then
		error "Missing 'text' or empty"
	else
		local resource = getResourceName(sourceResource):lower()
		local logType = "notice"

		if (exports.mysql:isConnected()) then
			if (exports.mysql:execute("INSERT INTO logs (resource,logType,log,date) VALUES (?,?,?,NOW())",resource,logType,text)) then
				return true
			else
				return "ERROR 2"
			end
		else
			return "ERROR 0"
		end
	end
end

function logWarning(text)
	if (type(text) ~= "string" or text == "") then
		error "Missing 'text' or empty"
	else
		local resource = getResourceName(sourceResource):lower()
		local logType = "warning"

		if (exports.mysql:isConnected()) then
			if (exports.mysql:execute("INSERT INTO logs (resource,logType,log,date) VALUES (?,?,?,NOW())",resource,logType,text)) then
				return true
			else
				return "ERROR 2"
			end
		else
			return "ERROR 0"
		end
	end
end

function logError(text)
	if (type(text) ~= "string" or text == "") then
		error "Missing 'text' or empty"
	else
		local resource = getResourceName(sourceResource):lower()
		local logType = "error"
		if (exports.mysql:isConnected()) then
			if (exports.mysql:execute("INSERT INTO logs (resource,logType,log,date) VALUES (?,?,?,NOW())",resource,logType,text)) then
				return true
			else
				return "ERROR 2"
			end
		else
			return "ERROR 0"
		end
	end
end