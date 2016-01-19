function init()

	local object_txd1 = engineLoadTXD("garage.txd", true)
	local object_dff1 = engineLoadDFF("garage.dff")
	local object_col1 = engineLoadCOL("garage.col")
	
	engineImportTXD(object_txd1, 5397)
	engineReplaceModel(object_dff1, 5397)
	engineReplaceCOL(object_col1, 5397)

end
addEventHandler("onClientResourceStart", resourceRoot, init)
