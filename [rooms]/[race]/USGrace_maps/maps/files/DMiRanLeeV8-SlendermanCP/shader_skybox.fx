// shader_skybox.fx
//
// Author: Ren712/AngerMAN

//-- Declare the texture

texture sSkyBoxTexture1;
float gBrighten = 0;
float gEnAlpha = 0;
float gInvertTimeCycle = 0;

float rotateX=0;
float rotateY=0;
float rotateZ=0;
float animate=0;
float3 sResize={0,0,0};
float3 sStretch=(0,0,0);
//-- Include some common stuff

#include "mta-helper.fx"

//---------------------------------------------------------------------
//-- Sampler for the main texture (needed for pixel shaders)
//---------------------------------------------------------------------

samplerCUBE envMapSampler1 = sampler_state
{
    Texture = (sSkyBoxTexture1);
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
    MIPMAPLODBIAS = 0.000000;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the vertex shader
//--------------------------------------------------------------------- 
 
 struct VSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0;
	float3 Normal : NORMAL0;
};

//---------------------------------------------------------------------
//-- Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------

struct PSInput
{
    float4 Position : POSITION; 
    float3 TexCoord : TEXCOORD0;	
};

//-----------------------------------------------------------------------------
//-- VertexShader
//-----------------------------------------------------------------------------
PSInput VertexShaderSB(VSInput VS)
{
    PSInput PS = (PSInput)0;
 
	// Resize by multiplying vertex position
	VS.Position *=float4(sResize,1);
    // Position in screen space.
    PS.Position = mul(VS.Position, gWorldViewProjection);

    // compute the 4x4 tranform from tangent space to object space
    float4 worldPos = mul(VS.Position, gWorld);
	worldPos.xyz*=sStretch;
    // compute the eye vector 
    float4 eyeVector = worldPos - gViewInverse[3]; 
	
	float time;
	if (animate!=0) {time=gTime;} else {time=1;}
	float cosX,sinX;
	float cosY,sinY;
	float cosZ,sinZ;

	// Rotate the texture
	sincos(rotateX * time,sinX,cosX);
	sincos(rotateY * time,sinY,cosY);
	sincos(rotateZ * time,sinZ,cosZ);

	float3x3 rot = float3x3(
      cosY * cosZ + sinX * sinY * sinZ, -cosX * sinZ,  sinX * cosY * sinZ - sinY * cosZ,
      cosY * sinZ - sinX * sinY * cosZ,  cosX * cosZ, -sinY * sinZ - sinX * cosY * cosZ,
      cosX * sinY,                       sinX,         cosX * cosY
	);


   PS.TexCoord.xyz = mul(rot, eyeVector.xyz);

    return PS;
}
 
//-----------------------------------------------------------------------------
//-- PixelShader
//-----------------------------------------------------------------------------
float4 PixelShaderSB(PSInput PS) : COLOR0
{
    float3 eyevec = normalize(float3(PS.TexCoord.x, PS.TexCoord.z, PS.TexCoord.y));
    float4 outPut = texCUBE(envMapSampler1, eyevec);
	
	 if (gInvertTimeCycle!=0)
	 {
	  outPut.rgba = outPut.rgba -(1+ gBrighten); 
	 }
	 else
	 {
	  outPut.rgba = outPut.rgba + gBrighten; 
	 }
	 if(gEnAlpha==0) {outPut.a=1;}
 
    return outPut;
}


////////////////////////////////////////////////////////////
//////////////////////////////// TECHNIQUES ////////////////
////////////////////////////////////////////////////////////
technique SkyBox_2
{
    pass P0
    {
	    AlphaBlendEnable = TRUE;
		SrcBlend = SRCALPHA;
		DestBlend = INVSRCALPHA;
        VertexShader = compile vs_2_0 VertexShaderSB();
        PixelShader = compile ps_2_0 PixelShaderSB();
    }
}
