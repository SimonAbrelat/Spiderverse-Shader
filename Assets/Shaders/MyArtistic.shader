Shader "Custom/MyArtistic"
{
    Properties
    {
        _Color ("Color", Color) = (0,0,0,1)
        _MainTex ("Texture (RGB)", 2D) = "white" {}
        _RimColor ("Rim Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0,50)) = 15
        _KernelSize ("Kernel Size", Range(0, 50)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        //#pragma surface surf Gooch vertex:vert finalcolor:mycolor
        //#pragma surface surf Gooch finalcolor:mycolor
        #pragma surface surf Gooch
        //#pragma surface surf Standard 
        
        #include "UnityPBSLighting.cginc"

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        float2 _MainTex_TS;
        float2 _MainTex_TexelSize;

        struct Input {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float2 uv_GlossMap;
        };

        fixed4 _Color;

        fixed4 _RimColor;
        float _RimPower;

        float _KernelSize;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        inline half4 LightingGooch (SurfaceOutputStandard s, half3 viewDir, UnityGI gi) {
            half4 c;
            float3 halfVec = normalize(gi.light.dir + viewDir);

            float NL = dot(s.Normal, gi.light.dir);
            float NH = dot(s.Normal, halfVec);
            float NV = dot(s.Normal, viewDir);

            float warmth = (1.0 + NL) / 2;
            float3 shade = lerp(float3(0.0,0.0,1.0), float3(1.0,1.0,0.0), warmth);

            c.rgb = s.Albedo * gi.light.color.rgb * shade; 

            float rim = 1- saturate(NV);
            rim = saturate(pow(rim, _RimPower) * _RimPower);
            rim = max(rim, 0); // Never negative
            c.rgb = lerp(c.rgb, _RimColor.rgb, rim);            
            
            c.a = s.Alpha;
            return c;
        }

		void LightingGooch_GI(SurfaceOutputStandard s, UnityGIInput data, inout UnityGI gi) {
			half3 lightColor = gi.light.color;
			LightingStandard_GI(s, data, gi);

            float NL = dot(s.Normal, gi.light.dir);
            float NV = dot(s.Normal, data.worldViewDir);
			float minnaert = saturate(NL * pow(NL * NV, 1 - data.atten) * data.atten);
			gi.light.color = lightColor * minnaert;
		}

        void surf (Input IN, inout SurfaceOutputStandard o) {
            half2 uv = IN.uv_MainTex;
 
            float3 mean[4] = {
                {0, 0, 0},
                {0, 0, 0},
                {0, 0, 0},
                {0, 0, 0}
            };

            float3 sigma[4] = {
                {0, 0, 0},
                {0, 0, 0},
                {0, 0, 0},
                {0, 0, 0}
            };

            float2 start[4] = {
                {-_KernelSize, -_KernelSize},
                {-_KernelSize, 0},
                {0, -_KernelSize},
                {0, 0}
            };

            for (int k = 0; k < 4; k++) {
                for(int i = 0; i <= _KernelSize; i++) {
                    for(int j = 0; j <= _KernelSize; j++) {
                        float2 pos = float2(i, j) + start[k];
                        float3 c = tex2Dlod(_MainTex, float4(uv + float2(pos.x * _MainTex_TexelSize.x, pos.y * _MainTex_TexelSize.y), 0., 0.)).rgb;
                        mean[k] += c;
                        sigma[k] += c * c;
                    }
                }
            }

            float samples = pow(_KernelSize + 1, 2);
            float4 color = tex2D(_MainTex, uv);
            float min_dist = 100;

            for (int l = 0; l < 4; l++) {
                mean[l] /= samples;
                sigma[l] = abs(sigma[l] / samples - mean[l] * mean[l]);
                float sigma_dist = dot(sigma[l].rgb, float3(1,1,1));

                if (sigma_dist < min_dist) {
                    min_dist = sigma_dist;
                    color.rgb = mean[l].rgb;
                }
            }

            o.Albedo = color.rgb;
            o.Alpha = 1;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
