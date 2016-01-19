jobDescription = "Rob stores and fight the law"
jobMarkers = {
    r=170,g=60,b=60,
    { x = 1821.7109375, y = 814.845703125, z = 10.8203125 },
    { x = 1960.8447265625, y = 2197.1396484375, z = 10.8203125 },
    { x = 1299.162109375, y = -1068.7099609375, z = 29.272327423096 },
    { x = 383.4951171875, y = -1731.8994140625, z = 8.6704235076904 },
    { x = -1895.0966796875, y = -557.7109375, z = 24.59375, },
    { x = -2498.076171875, y = 1202.8232421875, z = 37.428329467773 },
}

jobSkins = false

jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
}

jobVehicleMarkers = {
-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation

    r = 255, g = 0, b = 0, a = 150,
    { x = -1895.7265625, y = -550.3994140625, z = 24.5937,vehRotation=90,vehicles=jobVehicles},
    { x = -2491.18359375, y = 1214.7353515625, z = 37.421875,vehRotation=150,vehicles=jobVehicles},
    { x = -2491.18359375, y = 1214.7353515625, z = 37.421875,vehRotation=150,vehicles=jobVehicles},
    { x = 1968.44921875, y = 2199.1669921875, z = 10.8203125,vehRotation=270,vehicles=jobVehicles},
    { x = 1822.7255859375, y = 808.3125, z = 10.8203125,vehRotation=305,vehicles=jobVehicles},
    { x = 1307.0810546875, y = -1067.533203125, z = 29.225914001465,vehRotation=0,vehicles=jobVehicles},
    { x = 389.1025390625, y = -1725.119140625, z = 7.9620251655579,vehRotation=90,vehicles=jobVehicles},
}


jobBlip = ":USGcnr_jobs/blips/circle_red.png"