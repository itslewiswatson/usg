jobDescription = "SWAT Team job"
jobMarkers = { 
    {x = 1562.9365234375, y = -1684.6875, z = 16.182500839, r = 61, g = 89, b = 251},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=285, name="SWAT Skin"},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 596, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 597, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 598, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 599, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 523, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 601, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 427, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 415, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 426, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 428, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 468, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 490, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
}
jobVehicles2 = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 497, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 476, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
    {model = 447, color1 = 53, color2 = 1, color3 = 1, color4 = 1},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    {x = 1495.935,y = -1817.82128,z = 13.546879768,vehicles=jobVehicles,vehRotation=356.99792480469},
    {x = 1486.171875, y = -1817.751953125, z = 13.546879768372,vehicles=jobVehicles,vehRotation=356.99792480469},
    {x = 1476.0771484375, y = -1817.6357421875, z = 13.546879768372,vehicles=jobVehicles,vehRotation=356.99792480469},
    {x = 1465.5361328125, y = -1817.4736328125, z = 13.546879768372,vehicles=jobVehicles,vehRotation=356.99792480469},

    {x = 1476.4892578125, y = -1788.41796875, z = 73.96875,vehicles=jobVehicles2,vehRotation=269.99792480469},
    {x = 1476.451171875, y = -1766.3203125, z = 73.96875,vehicles=jobVehicles2,vehRotation=269.99792480469},
}