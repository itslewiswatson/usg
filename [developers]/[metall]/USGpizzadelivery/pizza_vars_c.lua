jobDescription = "Get in a faggio and then drive to the blip to deliver the pizza"
--jobBlip = ":USGcnr_jobs/blips/circle_yellow.png"
jobMarkers = {
    {x=2103.703125,y=-1809.9365234375,z=13.5546875},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=155},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 448, getVehicleNameFromModel(448)},
}
jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    {x=2096.1611328125,y=-1796.8837890625,z=13.388929367065,vehicles=jobVehicles,vehRotation=90},
}