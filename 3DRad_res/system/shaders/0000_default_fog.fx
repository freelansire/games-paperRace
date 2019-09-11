#define MATRIX_PALETTE_SIZE_DEFAULT 26

const int MATRIX_PALETTE_SIZE = MATRIX_PALETTE_SIZE_DEFAULT;
float4x3 amPalette[MATRIX_PALETTE_SIZE_DEFAULT];

float4x4 mxWorld : WORLD;
float4x4 mxWorldIT : amPalette; //to transform normals (note: we can re-use bone matrices registers as this will only be set for non-skinned meshes)
float4x4 mxViewProj : VIEWPROJECTION;

float4 lightDir : DIRECTION = {0.0f,0.0f,-1.0f,1.0f};
float4 lightColor : DIFFUSE = {1.0f,1.0f,1.0f,1.0f};
float4 lightAmbient : AMBIENT = {0.1f,0.1f,0.1f,1.0f};

float4 materialDiffuse : DIFFUSE = {0.8f,0.8f,0.8f,1.0f};
float4 materialSpecular : SPECULAR = {1.0f,1.0f,1.0f,1.0f};
float materialSpecularPower : SPECULARPOWER = 30.0f;

float3 worldEyePos;

texture diffuseMap;

int boneCount = 2;

float3 fogColor = {1.0f,1.0f,1.0f};
float fogStart = 1;
float fogEnd = 25;

struct VS_SKIN_INPUT
{
   float4 vPos;
   float3 vBlendWeights;
   float4 vBlendIndices;
   float3 vNor;
};

struct VS_SKIN_OUTPUT
{
   float4 vPos;
   float3 vNor;
};

VS_SKIN_OUTPUT VS_Skin( const VS_SKIN_INPUT vInput, int iNumBones )
{
   //This function is called by VertSkinning(), the main
   //vertex shader function for skinned meshes
   //It applies bone matrices to vertex coordinates and normal,
   //which also transforms from model-space to world space

   VS_SKIN_OUTPUT vOutput = (VS_SKIN_OUTPUT) 0;

   float fLastWeight = 1.0;
   float fWeight;
   float afBlendWeights[3] = (float[3])vInput.vBlendWeights;
   int aiIndices[4] = (int[4])D3DCOLORtoUBYTE4(vInput.vBlendIndices);

   for (int iBone=0;(iBone<3) && (iBone<(iNumBones-1));iBone++)
   {
      fWeight = afBlendWeights[iBone];
      fLastWeight -= fWeight;
      vOutput.vPos.xyz += mul(vInput.vPos,amPalette[aiIndices[iBone]])*fWeight;
      vOutput.vNor += mul(vInput.vNor,amPalette[aiIndices[iBone]])*fWeight;
   }

   vOutput.vPos.xyz += mul(vInput.vPos,amPalette[aiIndices[iNumBones-1]])*fLastWeight;
   vOutput.vNor += mul(vInput.vNor,amPalette[aiIndices[iNumBones-1]])*fLastWeight;

   return vOutput;
}

sampler TextureSampler = sampler_state
{
   Texture = <diffuseMap>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Point;
};

struct VS_INPUT
{
   float4 Pos : POSITION;
   float3 BlendWeights : BLENDWEIGHT;
   float4 BlendIndices : BLENDINDICES;
   float3 Normal : NORMAL;
   float4 Tex0 : TEXCOORD0;
};

struct VS_INPUT_NOSKIN
{
   float4 Pos : POSITION;
   float3 Normal : NORMAL;
   float4 Tex0 : TEXCOORD0;
};

struct VS_OUTPUT
{
   float4 Pos : POSITION;
   float4 Tex0 : TEXCOORD0;
   float4 Diffuse : COLOR0;
   float FogIntensity : FOG;
};

VS_OUTPUT VertSkinning(VS_INPUT IN, uniform int iNumBones)
{
   //Vertex shader used for skinned meshes

   VS_OUTPUT   OUT;

   VS_SKIN_INPUT vsi = { IN.Pos, IN.BlendWeights, IN.BlendIndices, IN.Normal };
   VS_SKIN_OUTPUT vso = VS_Skin( vsi, iNumBones );

   OUT.Pos = mul(float4(vso.vPos.xyz,1.0f),mxViewProj);
   OUT.FogIntensity = saturate((fogEnd - OUT.Pos.z)/(fogEnd - fogStart));
   OUT.Tex0  = IN.Tex0;

   //Calculate vectors N, L,
   float3 N = normalize(vso.vNor);
   float3 L = normalize(-lightDir.xyz);
   //Calculate diffuse
   float  diff = max(0,dot(N,L));
   //Output diffuse
   OUT.Diffuse = ((diff * lightColor) + lightAmbient) * materialDiffuse;

   return OUT;
}

VS_OUTPUT VertNoSkinning(VS_INPUT_NOSKIN IN)
{
   //Vertex shader used for static meshes

   VS_OUTPUT   OUT;

   OUT.Pos = mul(float4(IN.Pos.xyz,1.0f),mxViewProj);
   OUT.FogIntensity = saturate((fogEnd - OUT.Pos.z)/(fogEnd - fogStart));
   OUT.Tex0  = IN.Tex0;
   //Calculate vectors N, L
   float3 N = normalize(mul(IN.Normal,mxWorldIT).xyz);
   float3 L = normalize(-lightDir.xyz);
   //Calculate diffuse
   float  diff = max(0,dot(N,L));
   //Output diffuse
   OUT.Diffuse = ((diff * lightColor) + lightAmbient) * materialDiffuse;

   return OUT;
}

VertexShader vsArray20[4] = { compile vs_2_0 VertSkinning(1),
                              compile vs_2_0 VertSkinning(2),
                              compile vs_2_0 VertSkinning(3),
                              compile vs_2_0 VertSkinning(4) };

VertexShader vsArray11[4] = { compile vs_1_1 VertSkinning(1),
                              compile vs_1_1 VertSkinning(2),
                              compile vs_1_1 VertSkinning(3),
                              compile vs_1_1 VertSkinning(4) };

technique Skinning20
{
   pass p0
   {
      VertexShader = (vsArray20[boneCount]);
      PixelShader = NULL;
      Texture[0] = (diffuseMap);
      FogEnable = TRUE;
      FogColor = (float4(fogColor,0.0f));
   }
}
technique Skinning11
{
   pass p0
   {
      VertexShader = (vsArray11[boneCount]);
      PixelShader = NULL;
      Texture[0] = (diffuseMap);
      FogEnable = TRUE;
      FogColor = (float4(fogColor,0.0f));
   }
}
technique NoSkinning20
{
   pass p0
   {
      VertexShader = compile vs_2_0 VertNoSkinning();
      PixelShader = NULL;
      Texture[0] = (diffuseMap);
      FogEnable = TRUE;
      FogColor = (float4(fogColor,0.0f));
   }
}
technique NoSkinning11
{
   pass p0
   {
      VertexShader = compile vs_1_1 VertNoSkinning();
      PixelShader = NULL;
      Texture[0] = (diffuseMap);
      FogEnable = TRUE;
      FogColor = (float4(fogColor,0.0f));
   }
}

