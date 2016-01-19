jobDescription = "Enforce the law"
jobMarkers = {
    r=130,g=130,b=255,
    {x = 2303.8046875, y = 2436.73046875, z = 10.8203125},
    -- {x = 1571.7021484375, y = -1635.3623046875, z = 13.546955108643}, old LS pos
    {x = 1564.8134765625, y = -1672.072265625, z = 16.182500839233},
    {x = 617.587890625, y = -585.6689453125, z = 17.2265625},
    {x = -2167.9228515625, y = -2382.4580078125, z = 30.617206573486},
    {x = -1575.1005859375, y = 666.9228515625, z = 7.1901206970215},
    {x = -1390.4736328125, y = 2632.0283203125, z = 55.984375},
    {x = -216.923828125, y = 985.234375, z = 19.398239135742},
}

jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=280, name="City officer"},
    {id=281, name="City officer"},
    {id=282, name="City officer"},
    {id=283, name="County officer"},
    {id=288, name="County officer"},
}
jobLandVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 596},
    {model = 597},
    {model = 598},
    {model = 599},
    {model = 559, r=40,g=130,b=255},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    {x = 2256.08984375, y = 2442.5283203125, z = 10.8203125,vehicles=jobLandVehicles, vehRotation=0},
    {x = 2273.6025390625, y = 2461.0224609375, z = 10.8203125,vehicles=jobLandVehicles, vehRotation=180},
     {x = -1399.353515625, y = 2653.4853515625, z = 55.6875,vehicles=jobLandVehicles, vehRotation=90},
     {x = -1400.0224609375, y = 2643.939453125, z = 55.6875,vehicles=jobLandVehicles, vehRotation=90},
     {x = -227.0869140625, y = 995.171875, z = 19.552570343018,vehicles=jobLandVehicles, vehRotation=270},
     {x = 1559.9892578125, y = -1608.19921875, z = 13.3828125,vehicles=jobLandVehicles, vehRotation=180},
     {x = 1577.9345703125, y = -1608.767578125, z = 13.382812,vehicles=jobLandVehicles, vehRotation=180},
   {x = 1600.65234375, y = -1627.3740234375, z = 13.472529411316,vehicles=jobLandVehicles, vehRotation=90},
    {x = 1600.6796875, y = -1612.33203125, z = 13.47281837463,vehicles=jobLandVehicles, vehRotation=90},
   {x = 626.3359375, y = -603.5390625, z = 16.732929229736,vehicles=jobLandVehicles, vehRotation=270},
    {x = -2180.41015625, y = -2367.62109375, z = 30.625,vehicles=jobLandVehicles, vehRotation=45},
     {x = -1599.958984375, y = 652.0224609375, z = 7.1875,vehicles=jobLandVehicles, vehRotation=0},
    {x = -1615.8525390625, y = 651.82421875, z = 7.1875,vehicles=jobLandVehicles, vehRotation=0},
     {x = -1611.921875, y = 673.3134765625, z = 7.1875,vehicles=jobLandVehicles, vehRotation=180},
    {x = -1600.296875, y = 673.68359375, z = 7.1875,vehicles=jobLandVehicles, vehRotation=180},
}

jobBlip = ":USGcnr_jobs/blips/circle_blue.png"