_showCursor = showCursor
local cursorStates = {}
function showCursor(k, state)
	cursorStates[k] = state
	for k, cState in pairs(cursorStates) do
		if(cState ~= state and state == false) then
			return 
		end
	end
	_showCursor(state)
end

function isResourceReady(name)
	return getResourceFromName(name)
	and getResourceState(getResourceFromName(name)) == "running"
end

local skins = { [0]="Carl \"CJ\" Johnson (Main Character)", [1]="The Truth", [2]="Maccer", 
[7]="Taxi Driver/Train Driver", [9]="Normal Ped", [10]="Old Woman", [11]="Casino croupier", [12]="Rich Woman", 
[13]="Street Girl", [14]="Normal Ped", [15]="Mr.Whittaker (RS Haul Owner)", [17]="Buisnessman", [18]="Beach Visitor", [19]="DJ", 
[20]="Rich Guy (Madd Dogg's Manager)", [21]="Normal Ped", [22]="Normal Ped", [23]="BMXer", [24]="Madd Dogg Bodyguard", [25]="Madd Dogg Bodyguard", [26]="Backpacker", 
[28]="Drug Dealer", [29]="Drug Dealer", [30]="Drug Dealer", [31]="Farm-Town inhabitant", [32]="Farm-Town inhabitant", [33]="Farm-Town inhabitant", 
[34]="Farm-Town inhabitant", [35]="Gardener", [36]="Golfer", [37]="Golfer", [38]="Normal Ped", [39]="Normal Ped", [40]="Normal Ped", 
[41]="Normal Ped", [43]="Normal Ped", [44]="Normal Ped", [45]="Beach Visitor", [46]="Normal Ped", [47]="Normal Ped", 
[48]="Normal Ped", [49]="Snakehead (Da Nang)", [51]="Mountain Biker", [52]="Mountain Biker", [53]="Unknown", [54]="Normal Ped", 
[55]="Normal Ped", [56]="Normal Ped", [57]="Oriental Ped", [58]="Oriental Ped", [59]="Normal Ped", [60]="Normal Ped",
[62]="Colonel Fuhrberger", [63]="Prostitute", [64]="Prostitute", [66]="Pool Player", [67]="Pool Player", [68]="Priest/Preacher", 
[69]="Normal Ped", [70]="Scientist", [72]="Hippy", [73]="Hippy", [75]="Prostitute", [76]="Normal Ped", 
[77]="Homeless", [78]="Homeless", [79]="Homeless", [80]="Boxer", [81]="Boxer", [82]="Black Elvis", [83]="White Elvis", 
[84]="Blue Elvis", [85]="Prostitute", [87]="Stripper", [88]="Normal Ped", [89]="Normal Ped", [90]="Jogger", 
[91]="Rich Woman", [93]="Normal Ped", [94]="Normal Ped", [95]="Normal Ped", [96]="Jogger", [97]="Lifeguard", 
[98]="Normal Ped", [100]="Biker", [101]="Normal Ped", [102]="Balla", [103]="Balla", [104]="Balla", 
[105]="Grove Street Families", [106]="Grove Street Families", [107]="Grove Street Families", [108]="Los Santos Vagos", [109]="Los Santos Vagos", [110]="Los Santos Vagos", [111]="The Russian Mafia", 
[112]="The Russian Mafia", [113]="The Russian Mafia", [114]="Varios Los Aztecas", [115]="Varios Los Aztecas", [116]="Varios Los Aztecas", [117]="Triad", [118]="Triad", 
[120]="Triad Boss", [121]="Da Nang Boy", [122]="Da Nang Boy", [123]="Da Nang Boy", [124]="The Mafia", [125]="The Mafia", 
[126]="The Mafia", [127]="The Mafia", [128]="Farm Inhabitant", [129]="Farm Inhabitant", [130]="Farm Inhabitant", [131]="Farm Inhabitant", [132]="Farm Inhabitant", 
[133]="Farm Inhabitant", [134]="Homeless", [135]="Homeless", [136]="Normal Ped", [137]="Homeless", [138]="Beach Visitor", [139]="Beach Visitor", 
[140]="Beach Visitor", [141]="Buisnesswoman", [142]="Taxi Driver", [143]="Crack Maker", [144]="Crack Maker", [145]="Crack Maker", [146]="Crack Maker", 
[147]="Buisnessman", [148]="Buisnesswoman", [150]="Buisnesswoman", [151]="Normal Ped", [152]="Prostitute",
[154]="Beach Visitor", [156]="Barber", [157]="Hillbilly", [158]="Farmer", [159]="Hillbilly", [160]="Hillbilly", 
[161]="Farmer", [162]="Hillbilly", [163]="Black Bouncer", [164]="White Bouncer", [165]="White MIB agent", [166]="Black MIB agent",
[168]="Hotdog/Chilli Dog Vendor", [169]="Normal Ped", [170]="Normal Ped", [171]="Blackjack Dealer", [172]="Casino croupier", [173]="San Fierro Rifa", [174]="San Fierro Rifa", 
[175]="San Fierro Rifa", [176]="Barber", [177]="Barber", [178]="Whore", [180]="Tattoo Artist", [181]="Punk", 
[182]="Cab Driver", [183]="Normal Ped", [184]="Normal Ped", [185]="Normal Ped", [186]="Normal Ped", [187]="Buisnessman", [188]="Normal Ped", 
[189]="Valet", [190]="Barbara Schternvart", [191]="Helena Wankstein", [192]="Michelle Cannes", [193]="Katie Zhan", [194]="Millie Perkins", [195]="Denise Robinson", 
[196]="Farm-Town inhabitant", [197]="Hillbilly", [198]="Farm-Town inhabitant", [199]="Farm-Town inhabitant", [200]="Hillbilly", [201]="Farmer", [202]="Farmer", 
[203]="Karate Teacher", [204]="Karate Teacher", [206]="Cab Driver", [207]="Prostitute",
[210]="Oriental Boating School Instructor", [212]="Homeless", [213]="Weird old man", [214]="Waitress (Maria Latore)", [215]="Normal Ped", [216]="Normal Ped", 
[218]="Normal Ped", [219]="Rich Woman", [220]="Cab Driver", [221]="Normal Ped", [222]="Normal Ped", [223]="Normal Ped", 
[224]="Normal Ped", [225]="Normal Ped", [226]="Normal Ped", [227]="Oriental Buisnessman", [228]="Oriental Ped", [229]="Oriental Ped", [230]="Homeless", 
[231]="Normal Ped", [232]="Normal Ped", [233]="Normal Ped", [234]="Cab Driver", [235]="Normal Ped", [236]="Normal Ped", [237]="Prostitute", 
[238]="Prostitute", [239]="Homeless", [240]="The D.A", [241]="Afro-American", [242]="Mexican", [243]="Prostitute", [244]="Stripper", 
[245]="Prostitute", [246]="Stripper", [247]="Biker", [248]="Biker", [249]="Pimp", [250]="Normal Ped", [251]="Lifeguard", 
[252]="Naked Valet", [254]="Biker Drug Dealer", [255]="Chauffeur (Limo Driver)", [256]="Stripper", [257]="Stripper", [258]="Heckler", 
[259]="Heckler", [261]="Cab driver", [262]="Cab driver", [263]="Normal Ped", [264]="Clown (Ice-cream Van Driver)",
[268]="Dwaine/Dwayne", [269]="Melvin \"Big Smoke\" Harris (Mission)", 
[270]="Sean 'Sweet' Johnson", [271]="Lance 'Ryder' Wilson", [272]="Mafia Boss", 
[290]="Ken Rosenberg", [291]="Kent Paul", [292]="Cesar Vialpando", [293]="Jeffery \"OG Loc\" Martin/Cross", 
[294]="Wu Zi Mu (Woozie)", [295]="Michael Toreno", [296]="Jizzy B.", [297]="Madd Dogg", [298]="Catalina", [299]="Claude Speed", }

local shopTypes = {
	binco = {
		int = 15, dimensions = {0,1,2,3},
		marker = { x = 207.5430, y = -109.0040, z = 1005.1330 },
		clothesMarker = { x = 207.5430, y = -109.0040, z = 1005.1330 },
		skins = skins,
		clothes = clothingTypes,
	},
	zip = { 
		int = 18, dimensions = {0,1,2,3},
		marker = { x = 161.4765625, y = -84.388671875, z = 1001.8046875 },
		skins = skins,
		clothes = clothingTypes,
	},
	prolaps = {
		int = 3, dimensions = {0,1,2,3},
		marker = { x = 207.09765625, y = -129.810546875, z = 1003.5078125 },
		clothesMarker = { x = 199.3193359375, y = -128.22265625, z = 1003.5151977539 },
		skins = skins,
		clothes = clothingTypes,
	},
	victim = {
		int = 5, dimensions = { 0,1,2,3 },
		marker = { x = 208.17, y = -10.22, z = 1001.21 },
		clothesMarker = { x = 201.8046875, y = -4.3408203125, z = 1001.2109375 },
		skins = skins,
		clothes = clothingTypes,
	},
}

local markerShop = {}

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
		end
	end
)
addEventHandler("onClientResourceStart", resourceRoot,
	function ()
		if(isResourceReady("USGrooms") and exports.USGrooms:getPlayerRoom() == "cnr") then
			createShops()
		end
	end
)
local blips = {}

_createBlip = createBlip
createBlip = function (...)
	local blip = _createBlip(...)
	exports.USGcnr_blips:setBlipUserInfo(blip,"Shops","Skins & clothes")
	exports.USGcnr_blips:setBlipDimension(blip,0)
	table.insert(blips, blip)
end		

function createShops()
	for shopType, shop in pairs(shopTypes) do
		local int, dimensions = shop.int, shop.dimensions
		for i, dimension in ipairs(dimensions) do
			local element = createMarker(shop.marker.x, shop.marker.y, shop.marker.z-1, "cylinder", 1.2, 255,255,0 )
			addEventHandler("onClientMarkerHit", element, onShopMarkerHit)
			markerShop[element] = shop
			setElementDimension(element, dimension)
			setElementInterior(element, int)
			if(shop.clothesMarker) then
				local clothesMarker = createMarker(shop.clothesMarker.x, shop.clothesMarker.y, shop.clothesMarker.z-1, "cylinder", 1.2, 255,128,0 )
				addEventHandler("onClientMarkerHit", clothesMarker, onClothesMarkerHit)
				markerShop[clothesMarker] = shop
				setElementDimension(clothesMarker, dimension)
				setElementInterior(clothesMarker, int)
			end	
		end
	end
	createBlip ( 459.64, -1500.65, 31.04, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 1457.75, -1140, 24.06, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 2244.98, -1662.71, 15.46, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( -1884.71, 864.23, 35.17, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( -2494, -29.24, 25.76, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( -2377.44, 910.02, 45.44, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 2572.01, 1901.95, 11.02, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 2105.18, 2257.22, 11.02, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 1654.28, 1734.43, 10.82, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 2809.04, 2418.27, 10.82, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 500.5, -1358.53, 16.18, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( -1696.14, 950.22, 24.89, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 2090.68, 2222.65, 10.82, 45, 2, 0, 0, 0, 0, 0, 270 )
	createBlip ( 2779.12, 2453.54, 11.06, 45, 2, 0, 0, 0, 0, 0, 270 )	
end

function removeShops()
	for i, blip in ipairs(blips) do
		if(isElement(blip)) then
			destroyElement(blip)
		end
	end
	for marker, shop in pairs(markerShop) do
		if(isElement(marker)) then
			destroyElement(marker)
		end
	end
	blips = {}
	markerShop = {}
	closeSkinShop()
end

local currentShop
local playerSkin = getElementModel(localPlayer)
local markerTimeout = false

function onShopMarkerHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	if(not exports.USG:validateMarkerZ(source, hitElement)) then return end
	currentShop = markerShop[source]
	toggleSkinShop()
end

--- shop & gui
local skinShopGUI = {}
function createSkinShopGUI()
	skinShopGUI.window = exports.USGGUI:createWindow("right","center",300,400,false,"Skins")
	skinShopGUI.list = exports.USGGUI:createGridList("center",5,290,355,false,skinShopGUI.window)
	exports.USGGUI:gridlistAddColumn(skinShopGUI.list, "Description", 0.7)
	exports.USGGUI:gridlistAddColumn(skinShopGUI.list, "ID", 0.3)
	addEventHandler("onUSGGUISClick", skinShopGUI.list, onSelectSkin, false)
	skinShopGUI.cancel = exports.USGGUI:createButton(5,365,70,30,false,"Cancel",skinShopGUI.window)
	skinShopGUI.buy = exports.USGGUI:createButton(225,365,70,30,false,"Buy",skinShopGUI.window)
	addEventHandler("onUSGGUISClick", skinShopGUI.cancel, toggleSkinShop, false)
	addEventHandler("onUSGGUISClick", skinShopGUI.buy, onBuySkin, false)
end

function loadCurrentShop()
	local skins = currentShop.skins or {}
	for id, desc in pairs(skins) do
		local row = exports.USGGUI:gridlistAddRow(skinShopGUI.list)
		exports.USGGUI:gridlistSetItemText(skinShopGUI.list, row, 1, desc)
		exports.USGGUI:gridlistSetItemText(skinShopGUI.list, row, 2, tostring(id))
	end
	playerSkin = getElementModel(localPlayer)
end

function closeSkinShop(keepSkin)
	if(isElement(skinShopGUI.window)) then
		if(exports.USGGUI:getVisible(skinShopGUI.window)) then
			showCursor("skins",false)
			exports.USGGUI:setVisible(skinShopGUI.window, false)
			exports.USGGUI:gridlistClear(skinShopGUI.list)
			if(not keepSkin) then
				setElementModel(localPlayer, playerSkin)
			end
		end
	end
end

function toggleSkinShop()
	if(isElement(skinShopGUI.window)) then
		if(exports.USGGUI:getVisible(skinShopGUI.window)) then
			closeSkinShop(false)
		else
			showCursor("skins",true)
			exports.USGGUI:setVisible(skinShopGUI.window, true)
			loadCurrentShop()
		end
	else
		createSkinShopGUI()
		showCursor("skins",true)
		loadCurrentShop()
	end
end

function onSelectSkin()
	local selected = exports.USGGUI:gridlistGetSelectedItem(skinShopGUI.list)
	if(selected) then
		local skin = tonumber(exports.USGGUI:gridlistGetItemText(skinShopGUI.list, selected, 2))
		setElementModel(localPlayer, skin)
	else
		setElementModel(localPlayer, playerSkin)
	end
end

function onBuySkin()
	local selected = exports.USGGUI:gridlistGetSelectedItem(skinShopGUI.list)
	if(selected) then
		local skin = tonumber(exports.USGGUI:gridlistGetItemText(skinShopGUI.list, selected, 2))
		triggerServerEvent("USGcnr_skins.buySkin",localPlayer,skin)
		setElementModel(localPlayer, playerSkin)
	end
end

addEvent("USGcnr_skins.onSkinBought", true)
function onSkinBought()
	closeSkinShop(true)
	playerSkin = nil
end
addEventHandler("USGcnr_skins.onSkinBought", localPlayer, onSkinBought)

-- clothes shops
local categoryNames = { [0]="Shirt", [1]="Haircuts", [2]="Trousers", [3]="Shoes", [4]="Tattoos: Left Upper Arm", [5]="Tattoos: Left Lower Arm", [6]="Tattoos: Right Upper Arm", 
	[7]="Tattoos: Right Lower Arm", [8]="Tattoos: Back", [9]="Tattoos: Left Chest", [10]="Tattoos: Right Chest", [11]="Tattoos: Stomach", 
	[12]="Tattoos: Lower Back", [13]="Necklaces", [14]="Watches", [15]="Glasses", [16]="Hats", [17]="Extras",
}


local categorySelectedClothes = {}
local categoryClothesCart = {}
local preShopClothes
local selectedCategory
local totalCartPrice = 0

local clothesShopGUI = {}

function onClothesMarkerHit(hitElement, dimensions)
	if(hitElement ~= localPlayer or not dimensions) then return end
	if(not exports.USG:validateMarkerZ(source,hitElement)) then return end
	if(getElementModel(hitElement) ~= 0) then
		exports.USGmsg:msg("You need to have the CJ skin to change clothing!", 255, 0, 0)
		return
	end
	currentShop = markerShop[source]
	toggleClothesShop()
end

function createClothesShopGUI()
	clothesShopGUI.window = exports.USGGUI:createWindow("right","center",300,430,false,"Clothing")
	clothesShopGUI.info = exports.USGGGUI:createLabel(0,0,300,30,false,"Use left mouse to preview item, use right mouse to add to cart.",clothesShopGUI.window)
	clothesShopGUI.categories = exports.USGGUI:createGridList(5,35,140,355,false,clothesShopGUI.window)
	exports.USGGUI:gridlistAddColumn(clothesShopGUI.categories, "Type", 1.0)
	addEventHandler("onUSGGUISClick", clothesShopGUI.categories, onSelectClothingCategory, false)
	clothesShopGUI.clothes = exports.USGGUI:createGridList(150,35,140,355,false,clothesShopGUI.window)
	exports.USGGUI:gridlistAddColumn(clothesShopGUI.clothes, "Name", 1.0)
	addEventHandler("onUSGGUIClick", clothesShopGUI.clothes, onClothingClick, false)
	clothesShopGUI.cancel = exports.USGGUI:createButton(5,395,70,30,false,"Cancel",clothesShopGUI.window)
	clothesShopGUI.buy = exports.USGGUI:createButton(125,395,170,30,false,"Buy clothes ( $0 )",clothesShopGUI.window)
	addEventHandler("onUSGGUISClick", clothesShopGUI.cancel, toggleClothesShop, false)
	addEventHandler("onUSGGUIClick", clothesShopGUI.buy, onBuyClothes, false)
end

function loadCurrentShopClothes()
	local categories = currentShop.clothes
	for i=0,17 do
		local category = categories[i]
		if(category) then
			local row = exports.USGGUI:gridlistAddRow(clothesShopGUI.categories)
			exports.USGGUI:gridlistSetItemText(clothesShopGUI.categories, row, 1, tostring(categoryNames[i]))
			exports.USGGUI:gridlistSetItemData(clothesShopGUI.categories, row, 1, i)
		end
	end
	preShopClothes = {}
	for type=0,17 do 
		local tex, mod = getPedClothes(localPlayer, type)
		if(tex and mod) then
			preShopClothes[type] = {tex=tex,mod=mod}
			addClothingToCart(type, tex, mod, 0)
		end
	end
end

function onCloseClothesShop()
	showCursor("clothes",false)
	exports.USGGUI:setVisible(clothesShopGUI.window, false)
	exports.USGGUI:setText(clothesShopGUI.buy, "Buy clothes ( $0 )")
	exports.USGGUI:gridlistClear(clothesShopGUI.categories)
	exports.USGGUI:gridlistClear(clothesShopGUI.clothes)
	selectedCategory = false
	categoryClothesCart = {}
	categorySelectedClothes = {}
	totalCartPrice = 0
	preShopClothes = nil
end

function closeClothesShop(keepClothes)
	if(isElement(clothesShopGUI.window)) then
		if(exports.USGGUI:getVisible(clothesShopGUI.window)) then
			if(not keepClothes) then
				for slot=0,17 do
					local pre = preShopClothes[slot]
					if(pre) then
						addPedClothes(localPlayer, pre.tex, pre.mod, slot)
					end
				end
			end
			onCloseClothesShop()
		end
	end
end

function toggleClothesShop()
	if(isElement(clothesShopGUI.window)) then
		if(exports.USGGUI:getVisible(clothesShopGUI.window)) then
			onCloseClothesShop()
		else
			showCursor("clothes",true)
			exports.USGGUI:setVisible(clothesShopGUI.window, true)
			loadCurrentShopClothes()
		end
	else
		createClothesShopGUI()
		showCursor("clothes",true)
		loadCurrentShopClothes()
	end
end

addEvent("USGcnr_skins.onClothesBought", true)
function onClothesBought()
	closeClothesShop(true)
end
addEventHandler("USGcnr_skins.onClothesBought", localPlayer, onClothesBought)

function onBuyClothes(btn, state)
	if(state ~= "down") then return end
	local changed = false
	for slot=0,17 do
		local cart = categoryClothesCart[slot]
		local pre = preShopClothes[slot]
		if(cart and pre.tex ~= cart.tex and pre.mod ~= cart.mod) then
			changed = true
			break
		end
	end
	if(not changed) then
		exports.USGmsg:msg("You didn't change anything!", 255, 0, 0)
		return
	end
	triggerServerEvent("USGcnr_skins.buyClothes",localPlayer, categoryClothesCart)
end

function onSelectClothingCategory()
	exports.USGGUI:gridlistClear(clothesShopGUI.clothes)
	local selected = exports.USGGUI:gridlistGetSelectedItem(clothesShopGUI.categories)
	if(selected) then
		local id = exports.USGGUI:gridlistGetItemData(clothesShopGUI.categories, selected, 1)
		selectedCategory = id
		local clothes = currentShop.clothes[id]
		if(clothes) then
			for i, price in pairs(clothes) do
				local tex, mod
				if(i ~= CODE_REMOVE) then
					tex, mod = getClothesByTypeIndex(id, i)
				else
					tex, mod = "None", "Remove"
				end
				local row = exports.USGGUI:gridlistAddRow(clothesShopGUI.clothes)
				exports.USGGUI:gridlistSetItemText(clothesShopGUI.clothes, row, 1, tostring(tex).." - "..tostring(mod))
				exports.USGGUI:gridlistSetItemData(clothesShopGUI.clothes, row, 1, {i=i,tex=tex,mod=mod,price=price})
				if(categoryClothesCart[id] and categoryClothesCart[id].tex == tex and categoryClothesCart[id].mod == mod) then
					exports.USGGUI:gridlistSetItemColor(clothesShopGUI.clothes, row, false, tocolor(0,255,0))
				end
			end
		end
	end
end

function addClothingToCart(slot, tex, mod, price, row)
	if(categoryClothesCart[slot]) then
		removeClothingFromCart(slot)
	end
	categoryClothesCart[slot] = {tex=tex,mod=mod,price=price}
	totalCartPrice = totalCartPrice + price
	exports.USGGUI:setText(clothesShopGUI.buy, "Buy clothes ( "..exports.USG:formatMoney(totalCartPrice).." )")
	if(row) then
		exports.USGGUI:gridlistSetItemColor(clothesShopGUI.clothes, row, false, tocolor(0,255,0))
	end
end

function removeClothingFromCart(slot)
	local clothes = categoryClothesCart[slot]
	totalCartPrice = math.max(0, totalCartPrice - clothes.price)
	exports.USGGUI:setText(clothesShopGUI.buy, "Buy clothes ( "..exports.USG:formatMoney(totalCartPrice).." )")
	categoryClothesCart[slot] = false
	local color = exports.USGGUI:getSkinColor("text")
	for row = 1, exports.USGGUI:gridlistGetRowCount(clothesShopGUI.clothes) do
		exports.USGGUI:gridlistSetItemColor(clothesShopGUI.clothes, row, false, color)
	end
end

function onClothingClick(btn, state)
	if(state ~= "up") then return end
	local selected = exports.USGGUI:gridlistGetSelectedItem(clothesShopGUI.clothes)
	if(selected) then
		local info = exports.USGGUI:gridlistGetItemData(clothesShopGUI.clothes, selected, 1)
		local cartClothes, selectedClothes = categoryClothesCart[selectedCategory], categorySelectedClothes[selectedCategory]
		if(btn == 2) then
			if(cartClothes and cartClothes.tex == info.tex and cartClothes.mod == info.mod) then -- already in cart, remove
				removeClothingFromCart(selectedCategory)
			else
				addClothingToCart(selectedCategory, info.tex, info.mod, info.price,selected) -- add to cart
			end
		end
		cartClothes = categoryClothesCart[selectedCategory]
		if(selectedClothes and selectedClothes.tex == info.tex and selectedClothes.mod == info.mod) then -- previously selected for preview
			if(not cartClothes or (cartClothes.tex ~= info.tex and cartClothes.mod ~= info.mod)) then -- if not selected for purchase, remove clothes
				removePedClothes(localPlayer, selectedCategory)
				categorySelectedClothes[selectedCategory] = false
				if(preShopClothes[selectedCategory]) then
					addPedClothes(localPlayer, preShopClothes[selectedCategory].tex, preShopClothes[selectedCategory].mod, selectedCategory)
				end
			end
		else
			if(info.i ~= CODE_REMOVE) then
				addPedClothes(localPlayer, info.tex, info.mod, selectedCategory)
			else
				removePedClothes(localPlayer, selectedCategory)
			end
			categorySelectedClothes[selectedCategory] = info
		end
	end
end
