function onResourceStart()
	TXD = engineLoadTXD ( "texture2.txd" )
	engineImportTXD ( TXD, 7301 )
	engineImportTXD ( TXD, 8394 )
	engineImportTXD ( TXD, 9132 )
	engineImportTXD ( TXD, 7910 )
	engineImportTXD ( TXD, 360 )
	engineImportTXD ( TXD, 8322 )
	
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), onResourceStart)