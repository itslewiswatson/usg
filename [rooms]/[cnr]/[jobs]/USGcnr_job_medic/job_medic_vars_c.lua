jobDescription = "Provide medical services to damaged players"
jobMarkers = {
    {x=1615.048828125, y=1818.650390625, z=10.8203125},
    {x = 1177.4013671875, y = -1321.7978515625, z = 14.068869590759},
    {x = 2029.478515625, y = -1406.2998046875, z = 17.212032318115},
    {x = 1253.4033203125, y = 328.4228515625, z = 19.7578125},
    {x = -327.9482421875, y = 1064.04296875, z = 19.7421875},
    {x = -1520.1552734375, y = 2521.0859375, z = 55.867042541504},
    {x = -2643.734375, y = 636.205078125, z = 14.453125},
    {x = -2194.337890625, y = -2291.779296875, z = 30.625},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=274},
    {id=275},
    {id=276},
    {id=70},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model=416},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    { x=1619.03515625, y=1847.671875, z=10.8203125,vehRotation=180,vehicles=jobVehicles},
    { x = 1180.177734375, y = -1308.4013671875, z = 13.707922935486,vehRotation=270,vehicles=jobVehicles},
    { x = 2032.9248046875, y = -1445.115234375, z = 17.243885040283,vehRotation=90,vehicles=jobVehicles},
    { x = 1267.87890625, y = 328.54296875, z = 19.5546875,vehRotation=335,vehicles=jobVehicles},
    { x = -306.5244140625, y = 1058.5625, z = 19.594299316406,vehRotation=0,vehicles=jobVehicles},
    { x = -1526.376953125, y = 2526.5361328125, z = 55.755302429199,vehRotation=0,vehicles=jobVehicles},
    { x = -2643.884765625, y = 616.669921875, z = 14.453125,vehRotation=0,vehicles=jobVehicles},
    { x = -2185.556640625, y = -2305.78125, z = 30.625,vehRotation=320,vehicles=jobVehicles},
}

jobBlip = ":USGcnr_jobs/blips/circle_green.png"