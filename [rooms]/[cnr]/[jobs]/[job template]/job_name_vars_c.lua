jobDescription = "a description"
jobMarkers = {
	{x=0,y=0,z=0},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
	{id=0, name="aname"},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
	{model = 0, name="a name"},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
	{x=0,y=0,z=0,vehicles=jobVehicles,vehRotation=90},
}