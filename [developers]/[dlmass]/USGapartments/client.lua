function init(resource)

	object_txd1 = engineLoadTXD("floor.txd", true)
	engineImportTXD(object_txd1, 3781)
	object_col1 = engineLoadCOL("floor.col")
	object_dff1 = engineLoadDFF("floor.dff", 0)
	engineReplaceCOL(object_col1, 3781)
	engineReplaceModel(object_dff1, 3781)
	engineReplaceCOL(object_col1, 3781)
	
	object_txd2 = engineLoadTXD("building.txd", true)
	engineImportTXD(object_txd2, 4587)
	object_col2 = engineLoadCOL("building.col")
	object_dff2 = engineLoadDFF("building.dff", 0)
	engineReplaceCOL(object_col2, 4587)
	engineReplaceModel(object_dff2, 4587)
	engineReplaceCOL(object_col2, 4587)
	
	object_txd3 = engineLoadTXD("building.txd", true)
	engineImportTXD(object_txd3, 4605)
	object_col3 = engineLoadCOL("glass.col")
	object_dff3 = engineLoadDFF("glass.dff", 0)
	engineReplaceCOL(object_col3, 4605)
	engineReplaceModel(object_dff3, 4605)
	engineReplaceCOL(object_col3, 4605)

end
addEventHandler('onClientResourceStart', resourceRoot, init)