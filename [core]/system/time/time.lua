function getCurrentTime()
	local _Time = getRealTime()
	local hour = _Time.hour + 1
	local minute = _Time.minute
	local seconds = _Time.second
	
	return hour..":"..minute..":"..seconds
end

function getDatabaseDate()
	local _Time = getRealTime()
	
	local year = _Time.year+1900
	local month = _Time.month+1
	local day = _Time.monthday
	
	return year.."-"..month.."-"..day
end