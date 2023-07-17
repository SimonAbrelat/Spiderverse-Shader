// Aaron Lanterman, July 22, 2021
// Modified example from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects

Shader "Hidden/Custom/GPU21OutlinerStackShader"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        float _Speed;

        float4 Frag(VaryingsDefault i) : SV_Target
        {
            float4 original = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

            float4 original_left = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(1.0 / _ScreenParams.x,0));
            float4 original_right = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(1.0 / _ScreenParams.x,0));
            float4 original_up = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord - float2(0,1.0 / _ScreenParams.y));
            float4 original_down = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord + float2(0,1.0 / _ScreenParams.y));
            float3 horiz_diff = original_left.rgb - original_right.rgb;
            float3 vert_diff = original_up.rgb - original_down.rgb;
            float3 outline = abs(horiz_diff) + abs(vert_diff);
            return(float4(lerp(outline,original,0.5*(sin(_Speed * _Time.y) + 1)),1));
        }

    ENDHLSL

    SubShader {
        Cull Off ZWrite Off ZTest Always

        Pass {
            HLSLPROGRAM

                #pragma vertex VertDefault
                #pragma fragment Frag

            ENDHLSL
        }
    }
}
