

Objects = {
createObject ( 18033, 1381, -1286.53223, 14.549, 0, 0, 179.995 ),
createObject ( 1537, 1369.4004, -1279.7998, 12.6, 0, 0, 270 ),
--createObject ( 1537, 1369.4004, -1281.2998, 12.6, 0, 0, 186.246 ),
createObject ( 18036, 1393.59961, -1286.5293, 14.55, 0, 0, 179.995 ),
createObject ( 18034, 1381.8, -1289.3, 15.4, 0, 0, 270 ),
createObject ( 18035, 1375.7002, -1286.5996, 14.3, 0, 0, 179.995 ),
createObject ( 1584, 1380.2, -1293.9, 12.5, 0, 0, 33.5 ),
createObject ( 2619, 1381.7998, -1280.5, 15.7 ),
createObject ( 2358, 1381.2, -1292.8, 12.7, 0, 0, 218 ),
createObject ( 2358, 1381.2, -1292.8, 12.9, 0, 0, 217.996 ),
createObject ( 2358, 1381.2, -1292.8, 13.1, 0, 0, 217.996 ),
createObject ( 2358, 1381.2, -1292.8, 13.3, 0, 0, 217.996 ),
createObject ( 2359, 1381.3, -1291.7, 12.8, 0, 0, 296 ),
createObject ( 2359, 1381.3, -1290.9, 12.8, 0, 0, 295.999 ),
createObject ( 2359, 1381.3, -1290, 12.8, 0, 0, 295.999 ),
createObject ( 2359, 1381.2998, -1289, 12.8, 0, 0, 295.994 ),
createObject ( 2359, 1381.3, -1288, 12.8, 0, 0, 295.999 ),
createObject ( 2359, 1381.3, -1287.1, 12.8, 0, 0, 295.999 ),
createObject ( 2359, 1381.3, -1286.2, 12.8, 0, 0, 295.999 ),
createObject ( 2359, 1381.3, -1285.3, 12.8, 0, 0, 295.999 ),
createObject ( 2359, 1381.3, -1284.4, 12.8, 0, 0, 295.999 ),
createObject ( 18050, 1386.9, -1288.1, 15.4, 0, 0, 180 ),
createObject ( 18032, 1384.7, -1288.7, 14.1, 0, 0, 180 ),
}

addEventHandler( "onClientResourceStart", getRootElement( ),
function ()
for index, object in ipairs ( Objects ) do
    setElementDoubleSided ( object, true )
    
end
end

)