function ClientStarted ()
setWaterColor(89,172,255,255)
SetCloudsEnabled(false)                      
end 

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), ClientStarted )