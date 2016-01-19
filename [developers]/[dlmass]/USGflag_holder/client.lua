function init()

	local object_txd = engineLoadTXD("flag_holder.txd", true)
	local object_dff = engineLoadDFF("flag_holder.dff")
	local object_col = engineLoadCOL("flag_holder.col")
	
	engineImportTXD(object_txd, 1860)
	engineReplaceModel(object_dff, 1860)
	engineReplaceCOL(object_col, 1860)
	
end
addEventHandler("onClientResourceStart", resourceRoot, init)