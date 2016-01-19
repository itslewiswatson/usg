lvtraindoor = createObject (    1537  ,302.5, -76.026171875, 1000.515625)
setElementDimension(lvtraindoor,5)
setElementInterior(lvtraindoor,4)


Objects = {
createObject ( 18038, 2181.1456, 943.989961, 12.32 ),
createObject ( 18032, 2177.4449, 950.98, 11.62, 0, 0, 180 ),
createObject ( 18041, 2173.4449, 930.779, 11.92 ),
createObject ( 18042, 2169.845, 933.98, 10.52 ),
createObject ( 18104, 2166.345, 944.382, 11.22 ),
createObject (    1537  ,2179.05, 939.439453125, 10.093437194824),

}
addEventHandler( "onClientResourceStart", getRootElement( ),
function ()
for index, object in ipairs ( Objects ) do
    setElementDoubleSided ( object, true )
    
end
end

)