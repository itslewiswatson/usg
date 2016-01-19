houseMenuGUI = {}
local currentHouseID

function loadHouseMenu(houseID)
	currentHouseID = houseID
	triggerServerEvent("USGcnr_houses.requestHouseMenuData", localPlayer, houseID)
	--openHouseMenu()
end

function createHouseMenu()
	exports.USGGUI:setDefaultTextAlignment("left", "center")
	houseMenuGUI.window = exports.USGGUI:createWindow("center","center",300,200,false,"House menu")
	houseMenuGUI.owner = exports.USGGUI:createLabel(5,10,290,25,false,"Owner: ", houseMenuGUI.window)
	houseMenuGUI.forSale = exports.USGGUI:createLabel(5,40,100,25,false,"For sale: ", houseMenuGUI.window)
	houseMenuGUI.price = exports.USGGUI:createLabel(155,40,100,25,false,"Price: ", houseMenuGUI.window)
	houseMenuGUI.buy = exports.USGGUI:createButton(5,70,70,30,false,"Buy", houseMenuGUI.window)
		addEventHandler("onUSGGUISClick", houseMenuGUI.buy, onBuyHouse, false)
	houseMenuGUI.enter = exports.USGGUI:createButton(5,105,70,30,false,"Enter",houseMenuGUI.window)
		addEventHandler("onUSGGUISClick", houseMenuGUI.enter, onEnterHouse, false)
	houseMenuGUI.id = exports.USGGUI:createLabel(5,170,100,25,false,"ID: ",houseMenuGUI.window)
		exports.USGGUI:setTextAlignment(houseMenuGUI.id, "left", "bottom")
end

function isHouseMenuVisible()
	return isElement(houseMenuGUI.window) and exports.USGGUI:getVisible(houseMenuGUI.window)
end

function closeHouseMenu()
	if(isElement(houseMenuGUI.window)) then
		exports.USGGUI:setVisible(houseMenuGUI.window, false)
		showCursor("menu", false)
	end
end

function openHouseMenu()
	if(isElement(houseMenuGUI.window)) then
		if(not exports.USGGUI:getVisible(houseMenuGUI.window)) then
			showCursor("menu", true)
			exports.USGGUI:setVisible(houseMenuGUI.window, true)
		end
	else
		createHouseMenu()
		showCursor("menu", true)
	end
end

addEvent("USGcnr_houses.recieveHouseMenuData", true)
function loadHouseMenuData(data)
	openHouseMenu()
	exports.USGGUI:setText(houseMenuGUI.id, "ID: "..currentHouseID)
	exports.USGGUI:setText(houseMenuGUI.owner, (data.owner and ("Owner: "..data.owner)) or "Not owned")
	exports.USGGUI:setText(houseMenuGUI.forSale, "For sale: ".. (data.forSale and "Yes" or "No"))
	exports.USGGUI:setText(houseMenuGUI.price, "Price: ".. (data.price and exports.USG:formatMoney(data.price) or "N/A"))
	
	exports.USGGUI:setEnabled(houseMenuGUI.buy, data.forSale == true and exports.USGaccounts:getPlayerAccount() ~= data.owner)
	exports.USGGUI:setEnabled(houseMenuGUI.enter, data.canEnter)
end
addEventHandler("USGcnr_houses.recieveHouseMenuData", localPlayer, loadHouseMenuData)

function onBuyHouse()
	if(currentHouseID) then
		triggerServerEvent("USGcnr_houses.buyHouse", localPlayer, currentHouseID)
	end	
end

function onEnterHouse()
	if(currentHouseID) then
		triggerServerEvent("USGcnr_houses.enterHouse", localPlayer, currentHouseID)
	end
end