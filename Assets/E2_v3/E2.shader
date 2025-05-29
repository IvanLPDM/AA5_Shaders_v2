Shader "Custom/E2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _MaskTex("Mask Texture", 2D) = "white" {} 
        _EmissionTex("Emission Texture", 2D) = "black" {} 
        _EmissionColor("Emission Color", Color) = (0,0,0,0) 
        [Toggle]_UseEmission ("Use Emission", Float) = 0             
        _Scale("Triplanar Scale", Float) = 1
        _BlendSharpness("Blend Sharpness", Float) = 4
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma multi_compile _ _USEEMISSION_ON  

        sampler2D _MainTex, _NormalMap, _MaskTex, _EmissionTex;
        float _Scale;
        float _BlendSharpness;
        float4 _Color;
        float4 _EmissionColor;
        float _UseEmission;

        struct Input
        {
            float3 worldPos;
            float3 worldNormal;
            INTERNAL_DATA
        };

        float3 triplanar_blend_weights(float3 normal, float sharpness)
        {
            float3 blend = abs(normal);
            blend = pow(blend, sharpness);
            return blend / (blend.x + blend.y + blend.z);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float3 worldPos = IN.worldPos * _Scale;
            float3 blendWeights = triplanar_blend_weights(IN.worldNormal, _BlendSharpness);

            float2 xUV = worldPos.yz;
            float2 yUV = worldPos.xz;
            float2 zUV = worldPos.xy;

            // --- ALBEDO ---
            float4 texX = tex2D(_MainTex, xUV);
            float4 texY = tex2D(_MainTex, yUV);
            float4 texZ = tex2D(_MainTex, zUV);
            float4 blended = texX * blendWeights.x + texY * blendWeights.y + texZ * blendWeights.z;

            // --- NORMAL MAP ---
            float3 nX = UnpackNormal(tex2D(_NormalMap, xUV));
            float3 nY = UnpackNormal(tex2D(_NormalMap, yUV));
            float3 nZ = UnpackNormal(tex2D(_NormalMap, zUV));

            nX = float3(nX.z, nX.x, nX.y);
            nY = float3(nY.x, nY.z, nY.y);
            nZ = float3(nZ.x, nZ.y, nZ.z);

            float3 blendedNormal = normalize(nX * blendWeights.x + nY * blendWeights.y + nZ * blendWeights.z);
            float3 normalTS = WorldNormalVector(IN, blendedNormal);
            // o.Normal = normalTS; // Uncomment if needed

            // --- MASK ---
            float maskX = tex2D(_MaskTex, xUV).r;
            float maskY = tex2D(_MaskTex, yUV).r;
            float maskZ = tex2D(_MaskTex, zUV).r;
            float mask = maskX * blendWeights.x + maskY * blendWeights.y + maskZ * blendWeights.z;
            float maskFactor = lerp(2.0, mask, 0.5);
            o.Albedo = blended.rgb * _Color.rgb * maskFactor;

            // --- EMISSION ---
            #if defined(_USEEMISSION_ON)
            float4 emitX = tex2D(_EmissionTex, xUV);
            float4 emitY = tex2D(_EmissionTex, yUV);
            float4 emitZ = tex2D(_EmissionTex, zUV);
            float4 emissionBlended = emitX * blendWeights.x + emitY * blendWeights.y + emitZ * blendWeights.z;

            o.Emission = emissionBlended.rgb * _EmissionColor.rgb;
            #endif
        }
        ENDCG
    }

    FallBack "Diffuse"
}
