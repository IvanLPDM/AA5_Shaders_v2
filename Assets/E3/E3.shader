Shader "Unlit/E3"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0,2)) = 1

        _FlowMap ("Flow Map", 2D) = "black" {}
        _FlowStrength ("Flow Strength", Range(0,1)) = 0.1
        _FlowSpeed ("Flow Speed", Range(0,5)) = 1

        _DepthFactor ("Depth Influence", Range(0,1)) = 0.5
        _SlopeFactor ("Slope Influence", Range(0,1)) = 1
        _WaterHeight ("Water Height", Float) = 0.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            sampler2D _FlowMap;
            float4 _FlowMap_ST;

            fixed4 _BaseColor;
            float _NormalStrength;
            float _FlowStrength;
            float _FlowSpeed;

            float _DepthFactor;
            float _SlopeFactor;
            float _WaterHeight;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NormalMap);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 baseUV = i.uv;

                float2 flowUV = TRANSFORM_TEX(baseUV, _FlowMap);
                float2 flowDirection = tex2D(_FlowMap, flowUV).rg * 2 - 1;

                float t = _Time.y;

                // Sample normals
                float2 uv1 = baseUV;
                fixed3 worldNormal = UnpackNormal(tex2D(_NormalMap, uv1));
                worldNormal = normalize(lerp(fixed3(0,0,1), worldNormal, _NormalStrength));

                // Slope-based speed multiplier (vertical = 0, steep = 1)
                float slopeInfluence = saturate(1.0 - abs(worldNormal.z)); // z=1 means flat

                float waterDepth = i.vertex.z - _WaterHeight;
                float depthDarkening = lerp(1.0, 0.3, saturate(waterDepth * 0.6));

                float depth = 1.0 - i.uv.y;
                float depthInfluence = depth;

                float flowSpeedDynamic = _FlowSpeed * (1 + _SlopeFactor * slopeInfluence + _DepthFactor * depthInfluence);

                // Animated flow
                float fracTime = frac(t * flowSpeedDynamic);
                float blendFactor = abs(fracTime * 2 - 1);

                float2 offset1 = flowDirection * _FlowStrength * fracTime;
                float2 offset2 = flowDirection * _FlowStrength * frac(fracTime + 0.5);

                float2 uvOffset1 = baseUV + offset1;
                float2 uvOffset2 = baseUV + offset2;

                fixed3 normal1 = UnpackNormal(tex2D(_NormalMap, uvOffset1));
                fixed3 normal2 = UnpackNormal(tex2D(_NormalMap, uvOffset2));

                fixed3 blendedNormal = normalize(lerp(normal1, normal2, blendFactor));
                blendedNormal = normalize(lerp(fixed3(0,0,1), blendedNormal, _NormalStrength));

                // En lugar de usar iluminación directa, usaremos un cálculo más suave.
                // Usamos un factor ambiental para suavizar el efecto de la luz.
                fixed3 ambientLight = fixed3(0.1, 0.1, 0.1); // Luz ambiental suave
                float diffuseLighting = max(dot(blendedNormal, fixed3(1, 1, 0)), 0.0); // Iluminación difusa
                fixed3 litColor = _BaseColor.rgb * (ambientLight + diffuseLighting);

                // Estimación de profundidad y ajuste del color
                depthDarkening += lerp(0.8, 0.5, depth);
                fixed3 depthTintedColor = litColor * depthDarkening;

                fixed4 col = fixed4(depthTintedColor, _BaseColor.a);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}