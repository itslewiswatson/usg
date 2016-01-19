function init()

	local object_txd = engineLoadTXD("flags.txd", true)
	local object_col = engineLoadCOL("flags.col")
	
	---------------------------------------------------
	
	local object_dff1 = engineLoadDFF("us_flag.dff")
	
	engineImportTXD(object_txd, 1859)
	engineReplaceModel(object_dff1, 1859)
	engineReplaceCOL(object_col, 1859)
	
	---------------------------------------------------
	
	local object_dff2 = engineLoadDFF("ru_flag.dff")
	
	engineImportTXD(object_txd, 1858)
	engineReplaceModel(object_dff2, 1858)
	engineReplaceCOL(object_col, 1858)
	
end
addEventHandler("onClientResourceStart", resourceRoot, init)