-- create the mapfix in every dimension
local _createObject = createObject
local dim = 0
local createObject = function (...)
	local obj = _createObject(...)
	setElementInterior(obj, 10)
	setElementDimension(obj, dim)
end

for i=0,8 do
	dim = i
	createObject(2678,365.1000100,-63.2000000,1003.3000000,0.0000000,0.0000000,90.0000000) --object(cj_chris_crate_ld) (1)
	createObject(2679,365.1000100,-61.7000000,1003.3000000,0.0000000,0.0000000,90.0000000) --object(cj_chris_crate_rd) (1)
	createObject(2679,365.0996100,-61.7001900,1005.5000000,0.0000000,0.0000000,92.0000000) --object(cj_chris_crate_rd) (2)
	createObject(2678,365.1000100,-63.2000000,1005.5000000,0.0000000,0.0000000,90.0000000) --object(cj_chris_crate_ld) (2)
	createObject(3798,364.6000100,-62.5000000,1005.2000000,0.0000000,0.0000000,0.0000000) --object(acbox3_sfs) (1)
	createObject(3798,366.0996100,-62.5000000,1005.2000000,0.0000000,0.0000000,0.0000000) --object(acbox3_sfs) (2)
	createObject(3115,372.6000100,-65.8000000,1005.6000000,0.0000000,0.0000000,0.0000000) --object(carrier_lift1_sfse) (1)
end

createObject = _createObject