addEventHandler( "onClientResourceStart", resourceRoot,
    function ()
        local shader = dxCreateShader("overlay.fx")
		local tex = dxCreateTexture("marker.png")
		dxSetShaderValue(shader, "gTexture", tex)
		engineApplyShaderToWorldTexture(shader, "CJ_W_GRAD")
    end
)
 