jobDescription = "Provide air support to the police using thermal optics and a scanner.\
Helicopter controls: space:toggle thermal left-ctrl:toggle camera arrows:rotate camera left-shift:change camera mode, go to the roof to spawn a heli"
jobMarkers = {
    r=110,g=110,b=255,
    {x = 1603.1630859375, y = -1623.58984375, z = 13.4995012},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=71, name="Air support officer"},
}
jobVehicles = { -- name optional ( if no name, getVehicleNameFromModel )
    {model = 497, name="Police helicopter"},
}

jobVehicleMarkers = {-- you can put different vehicles for each marker, vehRotation is optional and decides spawn rotation
   -- {x = 1550.0791015625, y = -1608.8935546875, z = 13.3828125, vehicles = jobVehicles, vehRotation = 270},
}