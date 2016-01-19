function startclient()
setWaterColor(0, 255, 255)
setSkyGradient(0, 255, 255, 0, 0, 0)
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), startclient)
