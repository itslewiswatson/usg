local connection = false
local pass = "qY5uaZCL3ffa93js"
local totalQuerys = 0
local totalQuerysRan = 0
local attempts = 0
local timeout = -1
local queryTool = ""

function connectToDatabase()
	loadQueryTool()
	connection = dbConnect("mysql","dbname=mtasa;host=127.0.0.1;port=3306;unix_socket=/var/run/mysqld/mysqld.sock","mtasa",pass)
	if (connection) then
		outputConsole("Server now connected to MySQL",1)
		return true
	else
		if (attempts == 5) then
			outputConsole("Failed to connect to MySQL, shutting down server...",1)
			shutdown("[MySQL] Failed to connect to db")
			return false
		end
		
		outputConsole("Failed to connect to MySQL",1)
		outputConsole("Retrying... ("..attempts.."/5)",1)
		attempts = attempts + 1
		setTimer(connectToDatabase,3000,1)
	end
end
addEventHandler("onResourceStart",resourceRoot,connectToDatabase)

function loadQueryTool()
	if(fileExists("queryTool.lua")) then
		local file = fileOpen("queryTool.lua")
		queryTool = fileRead(file,fileGetSize(file))
		fileClose(file)
	end
end

function getQueryTool()
	return queryTool
end

function isConnected()
	if (connection) then
		return true
	else
		return false
	end
end

function getConnection()
	return connection
end

function query(...)
	if (connection) then
		local query = dbQuery(connection,...)
		outputDebugString("WARNING: "..getResourceName(sourceResource).." is using query export, use callbacks instead!")
		if(not query) then
			outputDebugString("MySQL error, query coming from: "..getResourceName(sourceResource))
			return false
		end
		local result = dbPoll(query,timeout)
		if (result) then
			return result
		else
			return false
		end
	else
		return false
	end
end

function singleQuery(...)
	if (connection) then
		local query = dbQuery(connection,...)
		local result = dbPoll(query,timeout)
		outputDebugString("WARNING: "..getResourceName(sourceResource).." is using singleQuery export, use callbacks instead!")
		if (result) then
			return result[1]
		else
			return false
		end
	else
		return false
	end
end

function execute(str,...)
	if (connection) then
		local result = dbExec(connection,str,...)
		if(not result) then
			outputDebugString("Error from: "..tostring(getResourceName(sourceResource)))
		end
		return result
	else
		return false
	end
end