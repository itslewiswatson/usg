addEventHandler('onClientResourceStart', resourceRoot, 
function()

txd = engineLoadTXD ( "Files/road.txd" )
engineImportTXD ( txd, 16209 )
dff = engineLoadDFF ( "Files/road.dff", 16209 )
engineReplaceModel ( dff, 16209 )
col = engineLoadCOL ( "Files/road.col" )
engineReplaceCOL ( col, 16209 )
	end 
)
