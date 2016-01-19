jobDescription = "As mechanic, you need to repair damaged vehicles and you will get money for each repair"
jobMarkers = {
    {x=1013.06,y= -1028.97,z= 32.1},
    {x=2070.31, y=-1865.53,z=13.54},
    {x=708.79,y= -474.49,z= 16.33},
    {x=-1895.93,y= 276.32, z=41.04},
    {x=-89.71, y=1115.7, z=19.74},
    {x=1966.14, y=2143.93, z=10.82},
    {x=2380.36, y=1041.44, z=10.82},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=268, name="Mechanic 1"},
    {id=305, name="Mechanic 2"},
    {id=309, name="Mechanic 3"}
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 525, name="Towtruck"},
    {model = 554, name="Yosemite"},
    {model = 422, name="Bobcat"},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    {x=1036.44, y=-1029.38,z= 32.1,vehicles=jobVehicles},
     {x=2061.17, y=-1877.93, z=13.54,vehicles=jobVehicles},
     {x=-1917.28, y=283.7, z=41.04,vehicles=jobVehicles},
     {x=708.32, y=-461.6, z=16.33,vehicles=jobVehicles},
     {x=1958.26, y=2170.14, z=10.82,vehicles=jobVehicles},
     {x=-81.78, y=1133.29, z=19.74,vehicles=jobVehicles},
     {x=2380.16, y=1033.67, z=10.82,vehicles=jobVehicles},
}
jobBlip = ":USGcnr_jobs/blips/circle_yellow.png"