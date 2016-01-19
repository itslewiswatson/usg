function stuff()
engineSetModelLODDistance(12990, 300)
engineSetModelLODDistance(8661, 300)
engineSetModelLODDistance(7017, 300)
engineSetModelLODDistance(7584, 300)
engineSetModelLODDistance(8355, 300)
engineSetModelLODDistance(8421, 300)
engineSetModelLODDistance(8489, 300)
engineSetModelLODDistance(8394, 300)
--setWaterColor ( 136, 255, 136, 255 )
setWaterColor ( 255, 136, 255, 255 )
end
addEventHandler("onClientResourceStart", getRootElement(), stuff)

function getCoord(thePlayer)
 local x, y, z = getElementPosition(thePlayer)
 outputChatBox("Coordinates: ".."#FFFFFF"..x..", "..y..", "..z, getRootElement(), 255, 0, 0, true)
 end
 addCommandHandler("c", getCoord)
