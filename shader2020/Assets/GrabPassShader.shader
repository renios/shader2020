Shader "Unlit/GrabPassShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HueChange("HueChange", Range(0, 1)) = 0
        _SaturationChange("SaturationChange", Range(0, 1)) = 1
        _ValueChange("ValueChange", Range(0, 2)) = 1
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "Queue" = "Transparent"
        }

        GrabPass {}
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 clipPos : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _GrabTexture;
            float4 _MainTex_ST;
            float _HueChange;
            float _SaturationChange;
            float _ValueChange;

            v2f vert (appdata v)
            {
                v2f o;
                o.clipPos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.clipPos);
                return o;
            }

            float3 rgb2hsv(float3 c) {
              float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
              float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
              float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

              float d = q.x - min(q.w, q.y);
              float e = 1.0e-10;
              return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
            }

            float3 hsv2rgb(float3 c) {
              c = float3(c.x, clamp(c.yz, 0.0, 1.0));
              float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
              float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
              return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2Dproj(_GrabTexture, i.grabPos);
                fixed3 hsv = rgb2hsv(col);
                hsv.x += _HueChange;
                hsv.y *= _SaturationChange;
                hsv.z *= _ValueChange;
                fixed3 result = hsv2rgb(hsv);
                // col.b = 0;
                return fixed4(result.xyz, 1);
            }
            ENDCG
        }
    }
}
