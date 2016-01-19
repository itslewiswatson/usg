	

    -- DDC OMG generated script, PLACE IT SERVER-SIDE
     
    function omg_server()
      southwall = createObject(8411, 4294.5, -2323.3994140625, -36.099998474121, 0, 0, 0)
      southwallAttach1 = createObject(8411, 4232.1000976563, -2323.3999023438, -36.099998474121, 0, 0, 0)
      attachElements(southwallAttach1, southwall, -62.39990234375, -0.00048828125, -9.2370555648813e-014, 0, 0, 0)
      southwallAttach2 = createObject(8411, 4357, -2323.3994140625, -36.099998474121, 0, 0, 0)
      attachElements(southwallAttach2, southwall, 62.5, 0, -9.2370555648813e-014, 0, 0, 0)
      southwallAttach3 = createObject(8411, 4419.5, -2323.3994140625, -36.099998474121, 0, 0, 0)
      attachElements(southwallAttach3, southwall, 125, 0, -9.2370555648813e-014, 0, 0, 0)
      setTimer( omgMovesouthwall(1), 20000, 1 )
      westwall = createObject(8411, 4187.599609375, -2179.5, -36.099998474121, 0, 0, 90)
      westwallAttach1 = createObject(8411, 4187.599609375, -2117, -36.099998474121, 0, 0, 90)
      attachElements(westwallAttach1, westwall, 62.5, -2.7319617856847e-006, -9.2370555648813e-014, 0, 0, 0)
      westwallAttach2 = createObject(8411, 4187.599609375, -2054.5, -36.099998474121, 0, 0, 90)
      attachElements(westwallAttach2, westwall, 125, -5.4639235713694e-006, -9.2370555648813e-014, 0, 0, 0)
      westwallAttach3 = createObject(8411, 4187.599609375, -2242, -36.099998474121, 0, 0, 90)
      attachElements(westwallAttach3, westwall, -62.5, 2.7319617856847e-006, -9.2370555648813e-014, 0, 0, 0)
      westwallAttach4 = createObject(8411, 4187.599609375, -2304.5, -36.099998474121, 0, 0, 90)
      attachElements(westwallAttach4, westwall, -125, 5.4639235713694e-006, -9.2370555648813e-014, 0, 0, 0)
      setTimer( omgMovewestwall(1), 20000, 1 )
      northwall = createObject(8411, 4294.5, -2036.19921875, -36.099998474121, 0, 0, 0)
      northwallAttach1 = createObject(8411, 4232, -2036.19921875, -36.099998474121, 0, 0, 0)
      attachElements(northwallAttach1, northwall, -62.5, 0, -9.2370555648813e-014, 0, 0, 0)
      northwallAttach2 = createObject(8411, 4357, -2036.19921875, -36.099998474121, 0, 0, 0)
      attachElements(northwallAttach2, northwall, 62.5, 0, -9.2370555648813e-014, 0, 0, 0)
      northwallAttach3 = createObject(8411, 4419.5, -2036.19921875, -36.099998474121, 0, 0, 0)
      attachElements(northwallAttach3, northwall, 125, 0, -9.2370555648813e-014, 0, 0, 0)
      setTimer( omgMovenorthwall(1), 20000, 1 )
      eastwall = createObject(8411, 4462.3994140625, -2179.5, -36.099998474121, 0, 0, 90)
      eastwallAttach1 = createObject(8411, 4462.3994140625, -2242, -36.099998474121, 0, 0, 90)
      attachElements(eastwallAttach1, eastwall, -62.5, 2.7319617856847e-006, -9.2370555648813e-014, 0, 0, 0)
      eastwallAttach2 = createObject(8411, 4462.3994140625, -2304.5, -36.099998474121, 0, 0, 90)
      attachElements(eastwallAttach2, eastwall, -125, 5.4639235713694e-006, -9.2370555648813e-014, 0, 0, 0)
      eastwallAttach3 = createObject(8411, 4462.3994140625, -2117, -36.099998474121, 0, 0, 90)
      attachElements(eastwallAttach3, eastwall, 62.5, -2.7319617856847e-006, -9.2370555648813e-014, 0, 0, 0)
      eastwallAttach4 = createObject(8411, 4462.3994140625, -2054.5, -36.099998474121, 0, 0, 90)
      attachElements(eastwallAttach4, eastwall, 125, -5.4639235713694e-006, -9.2370555648813e-014, 0, 0, 0)
      setTimer( omgMoveeastwall(1), 20000, 1 )
    end
     
    function omgMovesouthwall(point)
      if point == 1 then
        moveObject(southwall, 30000, 4294.5, -2228.5, -36.099998474121, 0, 0, 0)
        setTimer(omgMovesouthwall, 30000+5000, 1, 2)
      elseif point == 2 then
        moveObject(southwall, 30000, 4294.5, -2323.3994140625, -36.099998474121, 0, 0, 0)
        setTimer(omgMovesouthwall, 30000, 1, 1)
      end
    end
     
    function omgMovewestwall(point)
      if point == 1 then
        moveObject(westwall, 30000, 4259.5, -2179.5, -36.099998474121, 0, 0, 0)
        setTimer(omgMovewestwall, 30000+5000, 1, 2)
      elseif point == 2 then
        moveObject(westwall, 30000, 4187.599609375, -2179.5, -36.099998474121, 0, 0, 0)
        setTimer(omgMovewestwall, 30000, 1, 1)
      end
    end
     
    function omgMovenorthwall(point)
      if point == 1 then
        moveObject(northwall, 30000, 4294.5, -2121.6000976563, -36.099998474121, 0, 0, 0)
        setTimer(omgMovenorthwall, 30000+5000, 1, 2)
      elseif point == 2 then
        moveObject(northwall, 30000, 4294.5, -2036.19921875, -36.099998474121, 0, 0, 0)
        setTimer(omgMovenorthwall, 30000, 1, 1)
      end
    end
     
    function omgMoveeastwall(point)
      if point == 1 then
        moveObject(eastwall, 30000, 4391.6000976563, -2179.5, -36.099998474121, 0, 0, 0)
        setTimer(omgMoveeastwall, 30000+5000, 1, 2)
      elseif point == 2 then
        moveObject(eastwall, 30000, 4462.3994140625, -2179.5, -36.099998474121, 0, 0, 0)
        setTimer(omgMoveeastwall, 30000, 1, 1)
      end
    end
     
    function omgMoveeastwall(point)
      if point == 1 then
        moveObject(eastwall, 30000, 4391.6000976563, -2179.5, -36.099998474121, 0, 0, 0)
        setTimer(omgMoveeastwall, 30000+5000, 1, 2)
      elseif point == 2 then
        moveObject(eastwall, 30000, 4462.3994140625, -2179.5, -36.099998474121, 0, 0, 0)
        setTimer(omgMoveeastwall, 30000, 1, 1)
      end
    end
     
    setTimer( omg_server, 20000, 1 )
    --addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), omg_server)

