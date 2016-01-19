loadstring(exports.mysql:getQueryTool())()

function importHouses(houses)
	for i, house in ipairs(houses) do
		importHouse(house)
	end
end

function importHouse(house)
	local forsale = 1
	local price = house.originalPrice
	local int = house.interiorid
	local name = house.housename
	exports.MySQL:execute("INSERT INTO cnr__houses (forsale,price,originalprice,`name`,x,y,z,`int`) VALUES (?,?,?,?,?,?,?,?)",
		forsale, price, price, name, house.x, house.y, house.z, int)
end

query(importHouses, {}, "SELECT * FROM temphouses")