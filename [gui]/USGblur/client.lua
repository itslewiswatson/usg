


local scx, scy = guiGetScreenSize()

Settings = {}
Settings.var = {}
Settings.var.bloom = 1.1
Settings.var.blendR = 255
Settings.var.blendG = 255
Settings.var.blendB = 255
Settings.var.blendA = 120

function setBlurEnabled ()
	if ( isElement( blurHShader ) ) then return end
 	myScreenSource = dxCreateScreenSource( scx/2, scy/2 )
	blurHShader,tecName = dxCreateShader( "blur.fx" )
	bAllValid = myScreenSource and blurHShader
end

function setBlurDisabled ()
	if ( isElement( blurHShader ) ) then destroyElement(blurHShader) end
	myScreenSource = nil
	blurHShader = nil
	tecName = nil
	bAllValid = nil
end

addEventHandler( "onClientHUDRender", root,
    function()
        if not Settings.var then
            return
        end
        if bAllValid then
            RTPool.frameStart()

            dxUpdateScreenSource( myScreenSource )

            local current = myScreenSource

            current = applyGBlurH( current, Settings.var.bloom )

            dxSetRenderTarget()

            if current then
                dxSetShaderValue( blurHShader, "TEX0", current )
                local col = tocolor(Settings.var.blendR, Settings.var.blendG, Settings.var.blendB, Settings.var.blendA)
                dxDrawImage( 0, 0, scx, scy, blurHShader, 0,0,0, col)
            end
        end
    end
)
 
function applyGBlurH( Src, bloom )
    if not Src then return nil end
    local mx,my = dxGetMaterialSize( Src )
    local newRT = RTPool.GetUnused(mx,my)
    if not newRT then return nil end
    dxSetRenderTarget( newRT, true )
    dxSetShaderValue( blurHShader, "TEX0", Src )
    dxSetShaderValue( blurHShader, "TEX0SIZE", mx,my )
    dxSetShaderValue( blurHShader, "BLOOM", bloom )
    dxDrawImage( 0, 0, mx, my, blurHShader )
    return newRT
end

RTPool = {}
RTPool.list = {}
 
function RTPool.frameStart()
    for rt,info in pairs(RTPool.list) do
        info.bInUse = false
    end
end
 
function RTPool.GetUnused( mx, my )
    for rt,info in pairs(RTPool.list) do
        if not info.bInUse and info.mx == mx and info.my == my then
            info.bInUse = true
            return rt
        end
    end
    local rt = dxCreateRenderTarget( mx, my )
    if rt then
        RTPool.list[rt] = { bInUse = true, mx = mx, my = my }
    end
    return rt
end