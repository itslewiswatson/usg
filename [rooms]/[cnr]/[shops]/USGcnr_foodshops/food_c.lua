local burgerShop = {x = 377.14, y = -67.83, z = 1000.51, int = 10, dims = {0,1,2,3,4,5,6,7,8,9,10,11,12}}
local cluckingShop = {x = 369.38, y = -6.32, z= 1000.85, int = 9, dims = {0,1,2,3,4,5,6,7,8,9,10,11,12}}
local pizzaShop = {x = 375.22, y = -119.66, z= 1000.49, int = 5, dims={1,2,3,4,5,6,7,8,9,10,11,12,13}}

local shops = {
}

for i, dim in ipairs(burgerShop.dims) do
	table.insert(shops, {x=burgerShop.x,y=burgerShop.y,z=burgerShop.z,int=burgerShop.int,dim=dim, type="burger"})
end
for i, dim in ipairs(cluckingShop.dims) do
	table.insert(shops, {x=cluckingShop.x,y=cluckingShop.y,z=cluckingShop.z,int=cluckingShop.int,dim=dim,type="cluckin"})
end
for i, dim in ipairs(pizzaShop.dims) do
	table.insert(shops, {x=pizzaShop.x,y=pizzaShop.y,z=pizzaShop.z,int=pizzaShop.int,dim=dim,type="pizza"})
end

local markerShopType = {}
local shopBlips = {}
_createBlip = createBlip
createBlip = function (...)
	local blip = _createBlip(...)
	exports.USGcnr_blips:setBlipUserInfo(blip,"Shops","Food")
	exports.USGcnr_blips:setBlipDimension(blip,0)
	table.insert(shopBlips, blip)
end

function createShops()
	for i, shop in ipairs(shops) do
		local marker = createMarker(shop.x,shop.y,shop.z, "cylinder",1, 200,255,0,170)
		addEventHandler("onClientMarkerHit", marker, onShopMarkerHit)
		setElementInterior(marker, shop.int)
		setElementDimension(marker, shop.dim)
		markerShopType[marker] = shop.type
	end
	-- burger
	createBlip ( 811.982, -1616.02, 12.618, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 1199.13, -918.071, 42.3243, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -1912.27, 828.025, 34.5615, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -2336.95, -166.646, 34.3573, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -2356.48, 1008.01, 49.9036, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2366.74, 2071.02, 9.8218, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2472.68, 2033.88, 9.822, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2169.86, 2795.79, 9.89528, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 1872.24, 2072.07, 9.82222, 10, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 1158.43, 2072.02, 9.82222, 10, 2, 0, 0, 0, 0, -1, 270 )
	-- clucking
	createBlip ( 172.727, 1176.68, 13.773, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -1213.71, 1830.46, 40.9335, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -2155.03, -2460.28, 29.8484, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2419.95, -1509.8, 23.1568, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2397.83, -1898.65, 12.7131, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 928.525, -1352.77, 12.4344, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -1815.84, 618.678, 34.2989, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -2671.53, 258.344, 3.64932, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2638.58, 1671.18, 10.0231, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2393.18, 2041.66, 9.8472, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2838.43, 2407.26, 10.061, 14, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2102.69, 2228.76, 10.0579, 14, 2, 0, 0, 0, 0, -1, 270 )
	-- pizza
	createBlip ( 1367.27, 248.388, 18.6229, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2333.43, 75.0488, 25.7342, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2333.43, 75.0488, 25.7342, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 203.334, -202.532, 0.600709, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2105.32, -1806.49, 12.6941, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -1808.69, 945.863, 23.8648, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( -1721.13, 1359.01, 6.19634, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2638.58, 1849.97, 10.0231, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2756.01, 2477.05, 10.061, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2351.89, 2532.19, 9.82217, 29, 2, 0, 0, 0, 0, -1, 270 )
	createBlip ( 2083.49, 2224.2, 10.0579, 29, 2, 0, 0, 0, 0, -1, 270 )	
end

function removeShops()
	for marker, _ in pairs(markerShopType) do
		if(isElement(marker)) then
			destroyElement(marker)
		end
	end
	markerShopType = {}
	for i, blip in ipairs(shopBlips) do
		if(isElement(blip)) then
			destroyElement(blip)
		end
	end
end

local shopGUI = {}

addEvent("onPlayerJoinRoom", true)
addEventHandler("onPlayerJoinRoom", localPlayer,
	function (room)
		if(room == "cnr") then
			createShops()
		end
	end
)
addEvent("onPlayerExitRoom", true)
addEventHandler("onPlayerExitRoom", localPlayer,
	function (prevRoom)
		if(prevRoom == "cnr") then
			removeShops()
			closeShop()
			if(isElement(shopGUI.window)) then
				destroyElement(shopGUI.window)
				shopGUI = {}
			end
		end
	end
)
addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
			createShops()
		end
	end
)

local shopType

function onShopMarkerHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	if(not exports.USG:validateMarkerZ(source, hitElement)) then return end
	shopType = markerShopType[source]
	openShop()
end


function loadShopImages()
	local pre = shopType
	exports.USGGUI:setProperty(shopGUI.smallMenu, "image", "images/"..pre.."_small.png")
	--exports.USGGUI:setProperty(shopGUI.mediumMenu, "image", "images/"..pre.."_medium.png")
	--exports.USGGUI:setProperty(shopGUI.largeMenu, "image", "images/"..pre.."_large.png")
end

function openShop()
	if(not isElement(shopGUI.window)) then
		shopGUI.window = exports.USGGUI:createWindow("center","center",250,320,false,"Food shop")
		shopGUI.smallMenuImg = exports.USGGUI:createImage(25,10, 70, 60, false, ":USGcnr_foodshops/images/"..shopType.."_small.png", shopGUI.window)
		shopGUI.smallMenu = exports.USGGUI:createButton(100,30, 130, 25, false, "Small Menu ( $"..prices.small.." )", shopGUI.window)
		addEventHandler("onUSGGUISClick", shopGUI.smallMenu, purchaseItem, false)
		shopGUI.mediumMenuImg = exports.USGGUI:createImage(25,75, 70, 60, false, ":USGcnr_foodshops/images/"..shopType.."_medium.png", shopGUI.window)
		shopGUI.mediumMenu = exports.USGGUI:createButton(100,95, 130, 25, false, "Medium Menu ( $"..prices.medium.." )", shopGUI.window)
		addEventHandler("onUSGGUISClick", shopGUI.mediumMenu, purchaseItem, false)
		shopGUI.largeMenuImg = exports.USGGUI:createImage(25,140, 70, 60, false, ":USGcnr_foodshops/images/"..shopType.."_large.png", shopGUI.window)
		shopGUI.largeMenu = exports.USGGUI:createButton(100,160, 130, 25, false, "Large Menu ( $"..prices.large.." )", shopGUI.window)
		addEventHandler("onUSGGUISClick", shopGUI.largeMenu, purchaseItem, false)
		shopGUI.sprunkImg = exports.USGGUI:createImage(25,210, 70, 60, false, ":USGcnr_foodshops/images/sprunk.png", shopGUI.window)
		shopGUI.sprunk = exports.USGGUI:createButton(100,230, 130, 25, false, "Sprunk ( $"..prices.sprunk.." )", shopGUI.window)
		addEventHandler("onUSGGUISClick", shopGUI.sprunk, purchaseItem, false)
		shopGUI.close = exports.USGGUI:createButton("center", 285, 170, 30, false, "Close", shopGUI.window)
		addEventHandler("onUSGGUISClick", shopGUI.close, closeShop, false)
		showCursor(true)
	else
		if(exports.USGGUI:getVisible(shopGUI.window)) then
			exports.USGGUI:setVisible(shopGUI.window, false)
			showCursor(false)
		else
			exports.USGGUI:setVisible(shopGUI.window, true)
			showCursor(true)
			loadShopImages()
		end
	end
end

function purchaseItem()
	local item
	if(source == shopGUI.smallMenu) then item = "small"
	elseif(source == shopGUI.mediumMenu) then item = "medium"
	elseif(source == shopGUI.largeMenu) then item = "large"
	elseif(source == shopGUI.sprunk) then item = "sprunk" end
	triggerServerEvent("USGcnr_foodshops.purchase", localPlayer, item)
end

function closeShop()
	if(isElement(shopGUI.window) and exports.USGGUi:getVisible(shopGUI.window)) then
		exports.USGGUI:setVisible(shopGUI.window, false)
		showCursor(false)
	end
end