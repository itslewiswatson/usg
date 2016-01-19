function setBlipDimension(blip,dimension)
    setElementData(blip,"USGblips_dimension",dimension)
end

function setBlipUserInfo(blip,cat,name)
    local data = {cat,name}
    setElementData(blip,"USGblips_blipData",toJSON(data))
end

function setBlipVisibleDistance(blip,distance)
    setElementData(blip,"USGblips_visibleDistance",distance)
end