marketGUI = {}


function createMarket()
    local screenW, screenH = guiGetScreenSize()
    marketGUI.window = guiCreateWindow((screenW - 576) / 2, (screenH - 448) / 2, 576, 448, "USG - Market", false)
        guiWindowSetSizable(marketGUI.window, false)
    marketGUI.windClose = guiCreateButton(450, 20, 116, 30, "Close", false, marketGUI.window)
        guiSetProperty(marketGUI.windClose, "NormalTextColour", "FFAAAAAA")  
        
    marketGUI.tabpanel = guiCreateTabPanel(9, 31, 557, 407, false, marketGUI.window)
    marketGUI.invTab = guiCreateTab("Inventory", marketGUI.tabpanel)
    marketGUI.invGrid = guiCreateGridList(4, 20, 299, 358, false, marketGUI.invTab)
        guiGridListAddColumn(marketGUI.invGrid, "Items", 0.5)
        guiGridListAddColumn(marketGUI.invGrid, "Amount of hits", 0.5)
    marketGUI.invScrollbar = guiCreateScrollBar(280, 2, 19, 356, false, false, marketGUI.invGrid)
    marketGUI.invLabelItem = guiCreateLabel(5, 0, 298, 20, "Your items:", false, marketGUI.invTab)
        guiLabelSetVerticalAlign(marketGUI.invLabelItem, "center")
    marketGUI.invAmountofHitLabel = guiCreateLabel(313, 42, 147, 18, "Choose an amount of hits:", false, marketGUI.invTab)
    marketGUI.invNumberOfHits = guiCreateEdit(463, 35, 84, 25, "", false, marketGUI.invTab)
    marketGUI.invPriceLabel = guiCreateLabel(313, 77, 147, 18, "Price of one hit:", false, marketGUI.invTab)
    marketGUI.invPrice = guiCreateEdit(408, 70, 84, 25, "", false, marketGUI.invTab)
    marketGUI.invPutItem = guiCreateButton(347, 151, 161, 39, "Put the item in the market", false, marketGUI.invTab)
        guiSetProperty(marketGUI.invPutItem, "NormalTextColour", "FFAAAAAA")

    marketGUI.marketTab = guiCreateTab("Items on sale", marketGUI.tabpanel)
    marketGUI.marketGrid = guiCreateGridList(5, 21, 547, 288, false, marketGUI.marketTab)
        guiGridListAddColumn(marketGUI.marketGrid, "Items", 0.2)
        guiGridListAddColumn(marketGUI.marketGrid, "Amount of hits on sale", 0.2)
        guiGridListAddColumn(marketGUI.marketGrid, "Price of one hit", 0.2)
        guiGridListAddColumn(marketGUI.marketGrid, "Seller Name", 0.2)

    marketGUI.marketGridScrollbar1 = guiCreateScrollBar(530, 0, 17, 15, true, false, marketGUI.marketGrid)
    marketGUI.marketGridScrollbar2 = guiCreateScrollBar(529, 3, 18, 285, false, false, marketGUI.marketGrid)
    marketGUI.marketLabelItems = guiCreateLabel(6, 0, 546, 21, "Available items on the market:", false, marketGUI.marketTab)
        guiLabelSetVerticalAlign(marketGUI.marketLabelItems, "center")
    marketGUI.marketLabelHittoBuy = guiCreateLabel(10, 315, 184, 18, "Number of hits you want to buy:", false, marketGUI.marketTab)
    marketGUI.marketNumberOfHits = guiCreateEdit(194, 311, 110, 22, "", false, marketGUI.marketTab)
    marketGUI.marketTotalPrice = guiCreateLabel(10, 339, 294, 29, "Total price:", false, marketGUI.marketTab)
    marketGUI.marketBuy = guiCreateButton(361, 326, 121, 32, "Buy", false, marketGUI.marketTab)
        guiSetProperty(marketGUI.marketBuy, "NormalTextColour", "FFAAAAAA")

    marketGUI.sellTab = guiCreateTab("Your items on the market", marketGUI.tabpanel)
    marketGUI.sellGrid = guiCreateGridList(6, 23, 546, 317, false, marketGUI.sellTab)
        guiGridListAddColumn(marketGUI.sellGrid, "Items", 0.3)
        guiGridListAddColumn(marketGUI.sellGrid, "Amount of hits", 0.3)
        guiGridListAddColumn(marketGUI.sellGrid, "Price of one hit", 0.3)
   marketGUI.sellItems = guiCreateLabel(6, 6, 272, 17, "The items that you are selling:", false, marketGUI.sellTab)
   marketGUI.sellRemove = guiCreateButton(197, 348, 164, 25, "Remove selected item", false, marketGUI.sellTab)
        guiSetProperty(marketGUI.sellRemove, "NormalTextColour", "FFAAAAAA")
   
  


    addEventHandler("onClientGUIClick", marketGUI.windClose, closeMarket, false)
end

function openMarket()
    if(not isElement(marketGUI.window)) then
        createMarket()
        showCursor( true)
    elseif(not guiGetVisible(marketGUI.window)) then
        showCursor( true)
        guiSetVisible(marketGUI.window, true)
    end
end

function closeMarket()
    if(isElement(marketGUI.window) and guiGetVisible(marketGUI.window)) then
        guiSetVisible(marketGUI.window, false)
        showCursor( false)
    end
end

function toogleMarket()
    if(isElement(marketGUI.window) and guiGetVisible(marketGUI.window)) then
        closeMarket()
    elseif(exports.USGrooms:getPlayerRoom() == "cnr") then
        openMarket()
        updateInv()
    end
end
bindKey("F7", "down", toogleMarket)

medicines = { "Aspirin","Steroid","Adderall" }
medicinesAmount = {exports.USGcnr_medicines:getPlayerMedicineAmount(medicines[1]),
 exports.USGcnr_medicines:getPlayerMedicineAmount(medicines[2]),
 exports.USGcnr_medicines:getPlayerMedicineAmount(medicines[3])}

function updateInv()
guiGridListClear(invGrid)
    for k,medicinesAmount in ipairs(medicines) do
        if medicinesAmout[1] > 0 or medicinesAmout[2] > 0 or medicinesAmout[3] > 0 then
            local row = guiGridListAddRow(invGrid)
            guiGridListSetItemText ( invGrid, row, 1, medicines[k], false, false )
            guiGridListSetItemText ( invGrid, row, 2, medicinesAmount, false, false )    
        end
    end
end
