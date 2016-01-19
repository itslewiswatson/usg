function ClientStarted ()
setWaterColor(89,172,255,255)
setSkyGradient(89,172,255,255,128,0)
SetCloudsEnabled(false)                      
end 

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), ClientStarted )