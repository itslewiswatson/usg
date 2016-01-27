local loaded = false
local markers
local blips

function loadATMs()
    if(not loaded) then
        loaded = true
        markers = {}
        blips = {}
        for i, ATM in ipairs(ATMs) do
            local object = createObject(2942, ATM.x, ATM.y, ATM.z, 0,0,ATM.rot)
            setObjectBreakable(object, false)
            local marker = createMarker(ATM.x, ATM.y, ATM.z-0.7, "cylinder", 1, 255,255,0,3)
            setElementParent(object, marker)
            addEventHandler("onClientMarkerHit", marker, onATMMarkerHit)
            table.insert(markers, marker)
            local blip = createBlip(ATM.x, ATM.y, ATM.z, 52, 2, 255, 255, 255, 255, -1, 300) -- ordering -1, since these blips are not very important
            exports.USGcnr_blips:setBlipDimension(blip, 0)
            exports.USGcnr_blips:setBlipUserInfo(blip, "Facilities", "ATMs")
            table.insert(blips, blip)
        end
    end
end

function removeATMs()
    if(loaded) then
        loaded = false  
        for i, marker in ipairs(markers) do
            if(isElement(marker)) then destroyElement(marker) end
        end     
        for i, blip in ipairs(blips) do
            if(isElement(blip)) then destroyElement(blip) end
        end     
        markers = nil
        blips = nil
    end
end

function onPlayerJoinRoom(room)
    if(room == "cnr") then loadATMs() end
end
addEventHandler("onPlayerJoinRoom", localPlayer, onPlayerJoinRoom)

function onPlayerExitRoom(room)
    removeATMs()
end
addEventHandler("onPlayerExitRoom", localPlayer, onPlayerExitRoom)

addEventHandler("onClientResourceStart",resourceRoot,
    function ()
        if ( getResourceFromName("USGaccounts") and getResourceState(getResourceFromName("USGaccounts")) == "running" and exports.USGaccounts:isPlayerLoggedIn()
        and getResourceFromName("USGrooms") and getResourceState(getResourceFromName("USGrooms")) == "running" and exports.USGrooms:getPlayerRoom() == "cnr") then
            loadATMs()
        end
    end
)

ATMs = 
{
    { x = 562.8000, y = -1254.6000, z = 16.9000, rot = 284.0000 },
    { x = 1001.7000, y = -929.4000, z = 41.8000, rot = 278.7466 },
    { x = 1019.4000, y = -1030.0000, z = 31.7000, rot = 358.4951 },
    { x = 926.8000, y = -1359.3000, z = 13.0000, rot = 272.4949 },
    { x = 1193.3994, y = -916.5996, z = 42.8000, rot = 6.4929 },
    { x = 485.4000, y = -1733.6000, z = 10.8000, rot = 172.4939 },
    { x = 812.3994, y = -1618.7998, z = 13.2000, rot = 90.4889 },
    { x = 1366.6390, y = -1274.2590, z = 13.2469, rot = 270.0000 },
    { x = 1742.2000, y = -2284.3999, z = 13.2000, rot = 270.0000 },
    { x = 2105.5000, y = -1804.3000, z = 13.2000, rot = 270.0000 },
    { x = 1760.0996, y = -1940.0996, z = 13.2000, rot = 91.9995 },
    { x = 2404.2000, y = -1934.6000, z = 13.2000, rot = 90.0000 },
    { x = 1928.5996, y = -1767.0996, z = 13.2000, rot = 91.9995 },
    { x = 2419.8999, y = -1506.0000, z = 23.6000, rot = 90.0000 },
    { x = 2758.2998, y = -1824.3994, z = 11.5000, rot = 19.9951 },
    { x = 2404.3999, y = -1237.5000, z = 23.5000, rot = 90.0000 },
    { x = 2136.3000, y = -1154.2000, z = 23.6000, rot = 152.0000 },
    { x = 1212.9300, y = -1816.1100, z = 16.0900, rot = 84.6757 },
    { x = 2027.1992, y = -1401.8994, z = 16.9000, rot = 359.9945 },
    { x = 1498.4799, y = -1581.0864, z = 13.1498, rot = 359.9950 },
    { x = -2330.3000, y = -163.9000, z = 35.2000, rot = 359.9945 },
    { x = -1410.2998, y = -296.7998, z = 13.8000, rot = 307.9907 },
    { x = -2121.1992, y = -451.2998, z = 35.1800, rot = 279.9921 },
    { x = -2708.5000, y = -308.1000, z = 6.8000, rot = 225.9890 },
    { x = -2695.5000, y = 260.1000, z = 4.3000, rot = 179.9888 },
    { x = -2672.0000, y = 634.6500, z = 14.1000, rot = 359.9835 },
    { x = -2767.6001, y = 790.3000, z = 52.4000, rot = 89.9780 },
    { x = -2636.3000, y = 1399.2000, z = 6.7000, rot = 13.9725 },
    { x = -2417.8999, y = 1028.8000, z = 50.0000, rot = 179.9691 },
    { x = -2414.8999, y = 352.9000, z = 34.8000, rot = 51.9670 },
    { x = -1962.0000, y = 123.4000, z = 27.3000, rot = 269.9653 },
    { x = -2024.7998, y = -102.0000, z = 34.8000, rot = 177.9620 },
    { x = -1675.8000, y = 434.0000, z = 6.8000, rot = 136.0000 },
    { x = -1967.1992, y = 291.5000, z = 34.8000, rot = 269.9615 },
    { x = -1813.8000, y = 618.4000, z = 34.8000, rot = 357.9998 },
    { x = -1911.2000, y = 824.4000, z = 34.8000, rot = 87.9950 },
    { x = -1571.1000, y = 697.3000, z = 6.8000, rot = 89.9895 },
    { x = -1648.2998, y = 1214.1992, z = 6.8000, rot = 135.9888 },
    { x = -1872.1000, y = 1137.9000, z = 45.1000, rot = 270.0000 },
    { x = -1806.1992, y = 955.7998, z = 24.5000, rot = 89.9890 },
    { x = 2841.6001, y = 1270.0000, z = 11.0000, rot = 269.7500 },
    { x = 1437.5996, y = 2647.7998, z = 11.0000, rot = 270.0000 },
    { x = 2159.5000, y = 939.3000, z = 10.5000, rot = 269.7473 },
    { x = 2020.2000, y = 999.2000, z = 10.5000, rot = 90.0000 },
    { x = 2227.7998, y = 1402.7998, z = 10.7000, rot = 90.0000 },
    { x = 1590.8000, y = 703.3000, z = 10.5000, rot = 270.0000 },
    { x = 1075.6000, y = 1596.7000, z = 12.2000, rot = 212.0000 },
    { x = 1591.7000, y = 2217.8999, z = 10.7000, rot = 1.0000 },
    { x = 997.8994, y = 2175.7998, z = 10.5000, rot = 87.9950 },
    { x = 1146.0996, y = 2075.0000, z = 10.7000, rot = 0.9998 },
    { x = 1464.5996, y = 2251.6992, z = 10.7000, rot = 178.9948 },
    { x = 1671.4238, y = 1806.6412, z = 10.5203, rot = 268.9998 },
    { x = 1948.8000, y = 2062.1001, z = 10.7000, rot = 268.9910 },
    { x = 2187.8000, y = 2464.1001, z = 10.9000, rot = 88.9893 },
    { x = 2833.3000, y = 2402.8000, z = 10.7000, rot = 44.9893 },
    { x = 2539.3999, y = 2080.2000, z = 10.5000, rot = 270.9890 },
    { x = 2179.5000, y = 1702.8000, z = 10.7000, rot = 272.0000 },
    { x = 2102.2998, y = 2232.0996, z = 10.7000, rot = 90.0000 },
    { x = 2638.3999, y = 1675.4000, z = 10.7000, rot = 269.9995 },
    { x = 1381.0000, y = 259.7000, z = 19.2000, rot = 153.9945 },
    { x = 2334.2998, y = 67.6992, z = 26.1000, rot = 87.9895 },
    { x = 196.3000, y = -202.0000, z = 1.2000, rot = 359.9899 },
    { x = -2090.0000, y = -2467.8000, z = 30.3000, rot = 141.9890 },
    { x = 693.5996, y = -520.3994, z = 16.0000, rot = 359.9890 },
    { x = -2256.3999, y = 2376.3999, z = 4.6000, rot = 311.9873 },
    { x = -2206.0996, y = -2291.5996, z = 30.3000, rot = 139.9823 },
    { x = -1511.4000, y = 2610.2000, z = 55.5000, rot = 359.9843 },
    { x = -259.9000, y = 2605.8999, z = 62.5000, rot = 179.9835 },
    { x = -1212.1000, y = 1833.5000, z = 41.6000, rot = 45.9835 },
    { x = -856.3000, y = 1529.0000, z = 22.2000, rot = 89.9833 },
    { x = -306.4000, y = 1054.0000, z = 19.4000, rot = 181.9781 },
    { x = 178.6000, y = 1173.2000, z = 14.4000, rot = 323.9775 },
    { x = -95.3000, y = 1110.7000, z = 19.4000, rot = 359.9758 },
    { x = 776.736328125, y = 1867.611328125, z = 4.3, rot = 90 },
    { x = -1943.1109, y = 2385.9529, z = 49.3753, rot = 112.0000 },
    { x = 2090.0833, y = -2409.0425, z = 13.2569, rot = 270.6000 },
    { x = 2281.1843, y = -2367.7922, z = 13.1469, rot = 400.6000 },
}