Shader "Unlit/E4"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
        _CameraWorldPos("Camera World Position", Vector) = (0,0,0,0)
        _TimeSinceStart("Time", Float) = 0
        _PulseSpeed("Pulse Speed", Float) = 5.0
        _PulseWidth("Pulse Width", Float) = 1.0
        _PulseColor("Pulse Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float3 _CameraWorldPos;
            float _TimeSinceStart;
            float _PulseSpeed;
            float _PulseWidth;
            float4 _PulseColor;

            float3 WorldPositionFromUV(float2 uv)
            {
                float2 ndc = uv * 2 - 1;
                float4 clipPos = float4(ndc, 0, 1);

                float4 viewPos = mul(unity_CameraInvProjection, clipPos);
                viewPos /= viewPos.w;

                float4 worldPos = mul(unity_CameraToWorld, viewPos);
                return worldPos.xyz;
            }

            fixed4 frag(v2f_img i) : SV_Target
            {
                float3 worldPos = WorldPositionFromUV(i.uv);

                float distanceToCamera = distance(worldPos.xz, _CameraWorldPos.xz);
                float pulse = abs(frac((_TimeSinceStart * _PulseSpeed - distanceToCamera)) - 0.5) * 2;
                pulse = smoothstep(1.0, 0.0, abs(pulse * _PulseWidth));

                float4 col = tex2D(_MainTex, i.uv);
                col.rgb = lerp(col.rgb, _PulseColor.rgb, pulse * _PulseColor.a);

                return col;
            }
            ENDCG
        }
    }
} 