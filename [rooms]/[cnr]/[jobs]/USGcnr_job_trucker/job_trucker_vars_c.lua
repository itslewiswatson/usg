jobDescription = "Deliver goods all around San Andreas."
jobMarkers = {
    {x = 1473.7705078125, y = 977.78515625, z = 10.8203125},
    {x = -84.587890625, y = -1135.53125, z = 1.078125},
    {x = -1749.123046875, y = 150.794921875, z = 3.5495557785034},
    {x = 2217.91796875, y = -2214.416015625, z = 13.546875},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=34, name=occupation},
    {id=15, name=occupation},
    {id=161, name=occupation},
    {id=158, name=occupation},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 403, zOffset = 1},
    {model = 515, zOffset = 1},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    --{x = 1447.0185546875, y = 975.3828125, z = 10.8203125,vehicles=jobVehicles,vehRotation=0},
   --{x = -75.314453125, y = -1120.677734375, z = 1.078125,vehicles=jobVehicles,vehRotation=145},
    --{x = -1748.4912109375, y = 104.298828125, z = 3.5546875,vehicles=jobVehicles,vehRotation=0},--
   --{x = 2200.9326171875, y = -2237.7919921875, z = 13.546875,vehicles=jobVehicles,vehRotation=217},--
}

jobBlip = ":USGcnr_jobs/blips/circle_yellow.png"