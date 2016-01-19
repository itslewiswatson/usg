function setWaterDown_func()
    setWaterLevel(0.5)
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), setWaterDown_func)