function txdClient ()
tekstura = engineLoadTXD("excalibur.txd") 
engineImportTXD(tekstura, 8882 )
end
addEventHandler( "onClientResourceStart", resourceRoot, txdClient )



function txdClient ()
tekstura = engineLoadTXD("sw_bridge01.txd") 
engineImportTXD(tekstura, 12972 )
end
addEventHandler( "onClientResourceStart", resourceRoot, txdClient )



function txdClient ()
tekstura = engineLoadTXD("ballypillar01.txd") 
engineImportTXD(tekstura, 3437 )
end
addEventHandler( "onClientResourceStart", resourceRoot, txdClient )



function txdClient ()
tekstura = engineLoadTXD("luxorpillar1.txd") 
engineImportTXD(tekstura, 8397 )
end
addEventHandler( "onClientResourceStart", resourceRoot, txdClient )




function ClientStarted ()
setWaterColor( 0 , 125 , 255 ) -- RGB colors
setSkyGradient( 0, 0, 0, 0, 125, 255) -- 1st RGB colors top sky, 2nd RGB colors bottom sky
end 





addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), ClientStarted )

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), ClientStarted )