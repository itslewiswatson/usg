jobDescription = "National Guard Job"
jobMarkers = { 
    {x = 125.7607421875, y = 1931.3671875, z = 19.235635757446, r = 0, g = 100, b = 0},
}
jobSkins = { -- set to false to let user have their own skin. name is optional
    {id=287, name="National Guard Soldier"},
    {id=262, name="National Guard Soldier"},
    {id=252, name="National Guard Officer"},
}
jobVehicles = {
}
jobVehicles2 = { 
}
jobVehicles3 = {
}

jobVehicleMarkers = {
 }
 
NGtxd = engineLoadTXD("312.txd")
engineImportTXD(NGtxd,262)
NGdff = engineLoadDFF("312.dff",262)
engineReplaceModel(NGdff,262)

NG2txd = engineLoadTXD("hitler.txd")
engineImportTXD(NG2txd,252)
NG2dff = engineLoadDFF("hitler.dff",252)
engineReplaceModel(NG2dff,252)