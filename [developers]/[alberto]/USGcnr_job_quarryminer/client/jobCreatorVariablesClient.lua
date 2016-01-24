jobDescription = "Plant C4, blow up parts of the quarry, collect the rocks that spawn with the Dozer and process them."
jobMarkers = {
    {x = 809, y = 851, z = 10},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id = 27, name = "Worker"},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 486, name = "Dozer"},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
    {x = 824, y = 830, z = 11, vehicles = jobVehicles},
}
jobBlip = ":USGcnr_jobs/blips/circle_yellow.png"