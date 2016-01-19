jobDescription = "Fly cargo and players all around SA to make a living."
jobMarkers = {
    { x = 1714.5634765625, y = 1614.291015625, z = 10.015625 },
    { x = -1545.201171875, y = -440.041015625, z = 6 },
    { x = 1958.3681640625, y = -2183.67578125, z = 13.546875 },
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=255, name="Pilot #1"},
    {id=61, name="Pilot #2"},
}
jobAircraft = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 511},
    {model = 487},
    {model = 519, zOffset = 1},
    {model = 553},
}
jobLandVehicles = {
    {model = 583},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    --LV
    {x = 1702.58203125, y = 1626.4951171875, z = 10.591444969177,vehicles=jobLandVehicles,vehRotation=100},
     {x = 1606.13671875, y = 1620.62890625, z = 10.8203125,vehicles=jobAircraft,vehRotation=180},
    --SF
    {x = -1537.07421875, y = -432.0751953125, z = 5.8515625, vehicles=jobLandVehicles, vehRotation=230},
    {x = -1293.296875, y = -463.2431640625, z = 14.1484375, vehicles=jobAircraft, vehRotation=280},
    --LS
     {x = 1977.11328125, y = -2185.5390625, z = 13.546875, vehicles=jobLandVehicles, vehRotation = 180},
    {x = 1991.283203125, y = -2387.310546875, z = 13.54687, vehicles=jobAircraft, vehRotation = 90},
}

jobBlip = ":USGcnr_jobs/blips/circle_yellow.png"