function removeHangar()
removeWorldModel(16771, 99999999999, 404.3408203125, 2476.5537109375, 24.884073257446,0)




end
addEventHandler("onClientPlayerSpawn", root, removeHangar)
addEventHandler("onClientResourceStart", root, removeHangar)


function setLod()
engineSetModelLODDistance(10022,300)
end
addEventHandler("onClientResourceStart", root, setLod)