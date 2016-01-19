addEvent("USGrace_common.freezeCamera", true)
function freezeCamera()
    local x,y,z,lx,ly,lz,roll,fov = getCameraMatrix()
    setCameraMatrix(x,y,z,lx,ly,lz,roll,fov)
end
addEventHandler("USGrace_common.freezeCamera", localPlayer, freezeCamera)



