function ClientStarted ()
setWaterColor( 0 , 191 , 255 ) -- RGB colors
setSkyGradient( 85 , 26 , 139 , 0 , 0 , 0) -- 1st RGB colors top sky, 2nd RGB colors bottom sky
end 


addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), ClientStarted )