-- easy mysql querying
local queryCallbacks = {}
local queryID = 0

function insert(callback,callbackArgs, queryStr,...)
	local connection = exports.mysql:getConnection()
	if not connection then return false end
	queryID = queryID + 1
	queryCallbacks[queryID] = {callback,callbackArgs}
	return dbQuery(insertCallback,{queryID},connection,queryStr,...)
end

function insertCallback(handle,id)
	local result, rows, insertID = dbPoll(handle,-1)
	if(result == nil) then dbFree(handle) end
	queryCallbacks[id][1](insertID, unpack(queryCallbacks[id][2]))
	queryCallbacks[id] = nil
end

function multiQuery(callback,callbackArgs,queries)
	local connection = exports.mysql:getConnection()
	if not connection then return false end
	queryID = queryID + 1
	cbs = {}
	for multiID,query in ipairs(queries) do
		table.insert(cbs, {callback, callbackArgs, false, nil}) -- boolean is for ready-state, nil for result
		dbQuery(multiQueryCallback,{queryID,multiID},connection,query[1], unpack(query, 2))
	end	
	queryCallbacks[queryID] = {callback,callbackArgs,cbs}
	return true
end

function multiQueryCallback(handle,id,multiID)
	queryCallbacks[id][3][multiID][3] = true
	queryCallbacks[id][3][multiID][4] = dbPoll(handle,-1)
	if(queryCallbacks[id][3][multiID][4] == nil) then dbFree(handle) end
	local ready = true
	local results = {}
	for i,cb in ipairs(queryCallbacks[id][3]) do
		if(cb[3] == false) then
			ready = false
			break
		else
			results[i] = cb[4]
		end
	end
	if(ready) then
		local callback = queryCallbacks[id][1]
		local args = results
		args[#args+1] = queryCallbacks[id][2]
		callback(unpack(args))
	end
end

function query(callback,callbackArgs,queryStr,...)
	local connection = exports.mysql:getConnection()
	if not connection then return false end
	queryID = queryID +1
	queryCallbacks[queryID] = {callback,callbackArgs}
	return dbQuery(queryCallback,{queryID},connection,queryStr,...)
end

function queryCallback(handle,id)
	local result = dbPoll(handle,-1)
	if(result == nil) then dbFree(handle) end
	queryCallbacks[id][1](result, unpack(queryCallbacks[id][2]))
	queryCallbacks[id] = nil
end

function singleQuery(callback,callbackArgs,queryStr,...)
	local connection = exports.mysql:getConnection()
	if not connection then return false end
	queryID = queryID +1
	queryCallbacks[queryID] = {callback,callbackArgs}
	return dbQuery(singleQueryCallback,{queryID},connection,queryStr,...)
end

function singleQueryCallback(handle,id)
	local result = dbPoll(handle,-1)
	if(result == nil) then dbFree(handle) end
	local row = false
	if(result[1]) then row = result[1] end
	queryCallbacks[id][1](row, unpack(queryCallbacks[id][2]))
	queryCallbacks[id] = nil
end

function __onMySqlStart()
	loadstring(exports.mysql:getQueryTool())()
	addEventHandler("onResourceStop", getResourceRootElement(getResourceFromName("mysql")), __onMySqlStop)
end
function __onMySqlStop()
	removeEventHandler("onResourceStart", getResourceRootElement(getResourceFromName("mysql")), __onMySqlStart)
	removeEventHandler("onResourceStop", getResourceRootElement(getResourceFromName("mysql")), __onMySqlStop)
end

addEventHandler("onResourceStart", getResourceRootElement(getResourceFromName("mysql")), __onMySqlStart)

