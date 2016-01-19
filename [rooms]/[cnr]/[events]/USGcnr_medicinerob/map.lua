Objects = {
createObject ( 10841, -1937, -1027.8, 37, 0, 0, 90 ),
createObject ( 10841, -1937, -1050.5, 37, 0, 0, 90 ),
createObject ( 10841, -1937, -1073.2, 37, 0, 0, 90 ),
createObject ( 10841, -1937, -1096.2, 37, 0, 0, 90 ),
--createObject ( 10841, -1949.5996, -1035.5996, 34.9, 0, 0, 179.995 ),
createObject ( 1299, -1944.9, -1086.2, 30.2 ),
createObject ( 1299, -1948.4, -1086.5, 30.2 ),
createObject ( 1299, -1944.9, -1079.5, 30.2 ),
createObject ( 1299, -1952.3, -1088, 30.2 ),
createObject ( 2991, -1951.5, -1081.2, 30.4, 0, 0, 272 ),
createObject ( 2972, -1951.5, -1076.1, 29.8 ),
createObject ( 1230, -1949.9, -1087.9, 30.2 ),
createObject ( 3630, -1940.3, -1079.7, 31.3, 0, 0, 266 ),
createObject ( 3630, -1944.1, -1077.9, 31.4, 0, 0, 265.995 )
}

addEventHandler( "onClientResourceStart", getRootElement( ),
function ()
    for index, object in ipairs ( Objects ) do
        setElementDoubleSided ( object, true )
    
    end
end

)