function onResourceStart()
	TXD = engineLoadTXD ( "texture.txd" )

	engineImportTXD ( TXD, 8557 )
	engineImportTXD ( TXD, 8558 )
	engineImportTXD ( TXD, 3458 )
	engineImportTXD ( TXD, 8838 )
	engineImportTXD ( TXD, 3095 )
	engineImportTXD ( TXD, 8661 )
	engineImportTXD ( TXD, 8325 )
	engineImportTXD ( TXD, 17031 )
	engineImportTXD ( TXD, 17030 )
	engineImportTXD ( TXD, 17033 )
	engineImportTXD ( TXD, 16610 )
	engineImportTXD ( TXD, 18228 )
	engineImportTXD ( TXD, 7657 )
	engineImportTXD ( TXD, 2774 )
	engineImportTXD ( TXD, 18332 )
	engineImportTXD ( TXD, 18323 )
	engineImportTXD ( TXD, 18225 )
	
	engineSetModelLODDistance ( 1610, 300 )
	

end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), onResourceStart)