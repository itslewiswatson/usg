function startclient ()
tekstura = engineLoadTXD("ce_breweryref.txd") 
engineImportTXD(tekstura, 3378 )
end 

addEventHandler( "onClientResourceStart", resourceRoot, startclient )