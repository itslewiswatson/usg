

Objects = {
createObject ( 14846, 1570.8301, -1670.9424, 17.62 ),
createObject ( 14843, 1574.7, -1695.1, 13.8 ),
createObject ( 2612, 1563.1, -1686.6, 17.3, 0, 0, 180 ),
createObject ( 2612, 1560.3, -1686.6, 17.3, 0, 0, 179.995 ),
createObject ( 2612, 1557.4, -1686.6, 17.3, 0, 0, 179.995 ),
createObject ( 2614, 1564.8, -1682.8, 17.5, 0, 0, 270 ),
createObject ( 2604, 1564.3, -1681.6, 16, 0, 0, 270 ),
createObject ( 2606, 1562.7, -1679.5, 16.6 ),
createObject ( 2608, 1557, -1686.5, 15.9, 0, 0, 180 ),
createObject ( 2609, 1564.5, -1686.4, 15.9, 0, 0, 180 ),
createObject ( 2608, 1558.9, -1686.5, 15.9, 0, 0, 179.995 ),
createObject ( 2608, 1560.8, -1686.5, 15.9, 0, 0, 179.995 ),
createObject ( 2608, 1562.7, -1686.5, 15.9, 0, 0, 179.995 ),
createObject ( 2609, 1564, -1686.4, 15.9, 0, 0, 179.995 ),
createObject ( 1671, 1563.7, -1682.7, 15.6, 0, 0, 90 ),
createObject ( 2198, 1575.4, -1668.2, 16.6, 0, 0, 180 ),
createObject ( 2198, 1575.4, -1665.7, 16.6, 0, 0, 179.995 ),
createObject ( 2198, 1575.4, -1663.3, 16.6, 0, 0, 179.995 ),
createObject ( 2198, 1575.4, -1661.2, 16.6, 0, 0, 179.995 ),
createObject ( 2198, 1575.4, -1659.2, 16.6, 0, 0, 179.995 ),
createObject ( 2198, 1575.4, -1657.2, 16.6, 0, 0, 179.995 ),
createObject ( 2605, 1565.1, -1668.3, 17 ),
createObject ( 2605, 1565.7, -1666.7, 17, 0, 0, 270 ),
createObject ( 2605, 1565.7, -1664.6, 17, 0, 0, 270 ),
createObject ( 2605, 1565.7, -1662.5, 17, 0, 0, 270 ),
createObject ( 2605, 1565.7, -1660.4, 17, 0, 0, 270 ),
createObject ( 1671, 1564.8, -1666.8, 17, 0, 0, 90 ),
createObject ( 1671, 1564.9, -1664.8, 17, 0, 0, 90 ),
createObject ( 1671, 1564.9, -1662.7, 17, 0, 0, 90 ),
createObject ( 1671, 1564.8, -1660.3, 17, 0, 0, 90 ),
createObject ( 1671, 1564.9, -1669.2, 17, 0, 0, 180 ),
createObject ( 2611, 1574.8, -1670.1, 18.6, 0, 0, 180 ),
createObject ( 2611, 1572, -1670.1, 18.6, 0, 0, 179.995 ),
createObject ( 2611, 1567.1, -1670.1, 18.6, 0, 0, 179.995 ),
createObject ( 2611, 1565, -1670.1, 18.6, 0, 0, 179.995 ),
createObject ( 2608, 1571.3, -1655.4, 17.2 ),
createObject ( 2608, 1567.3, -1655.4, 17.2 ),
createObject ( 971, 1563, -1651.1, 19.3 ),
createObject ( 971, 1572.9, -1650.8, 19.3 ),


}
addEventHandler( "onClientResourceStart", getRootElement( ),
function ()
for index, object in ipairs ( Objects ) do
    setElementDoubleSided ( object, true )
    
end
end

)