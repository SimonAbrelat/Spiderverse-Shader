Shader "Custom/KuwaharaFilter"
{
    Properties
    {
        [HideInEditor] _MainTex("Texture", 2D) = "white" {}
        _KernelSize ("Kernel Size", Range(0, 10)) = 0
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "UnityCG.cginc"
 
            struct v2f {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
 
            v2f vert(appdata_base v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }
 
            int _KernelSize;
 
            float4 frag (v2f i) : SV_Target {
                half2 uv = i.uv;
 
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

                return color;
            }
            ENDCG
        }
    }
}