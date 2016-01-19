jobDescription = "Drive around with your Reefer in the ocean to catch alot of\ndifferent types of fish. Check your net with /net, when it's full return to base to sell."
jobBlip = ":USGcnr_jobs/blips/circle_yellow.png"
jobMarkers = {
	{x=724.9,y=-1479,z=5.46},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
	{id=35,36,37},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
	{model = 453, name="Reefer"},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
	{x=728.9,y=-1500.6,z=0.55,vehicles=jobVehicles,vehRotation=180},
}