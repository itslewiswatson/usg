function startclient ()
vgn = createObject ( 3851 , 2976.4873046875 , -1722.833984375 , 326.53942871094 )
vgn1 = createObject ( 3851 , 2976.4873046875 , -1756.5811767578 , 326.53942871094 )
vgn2 = createObject ( 3976 , 2959.72265625 , -1734.0948486328 , 315.80715942383 , 0 , 270 , 0 )

setElementCollisionsEnabled ( vgn , false )
setElementCollisionsEnabled ( vgn1 , false )
setElementCollisionsEnabled ( vgn2 , false )

end 

addEventHandler( "onClientResourceStart", resourceRoot, startclient )