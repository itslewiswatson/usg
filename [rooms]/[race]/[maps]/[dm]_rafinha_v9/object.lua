function ClientStarted ()
billboard = engineLoadTXD("vgsn_billboard.txd")
engineImportTXD(billboard, 7301 )
end
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), ClientStarted )