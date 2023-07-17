// Aaron Lanterman, July 22, 2021
// Modified example from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects

Shader "Hidden/Custom/SpiderverseEffectShader"
{
    HLSLINCLUDE

        #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"

        TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
        float4 _MainTex_TexelSize;
        TEXTURE2D_SAMPLER2D(_CameraDepthTexture, sampler_CameraDepthTexture);
		//TEXTURE2D_SAMPLER2D(_CameraDepthNormalsTexture, sampler_CameraDepthNormalsTexture);
        TEXTURE2D_SAMPLER2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2);
        float4 _CameraDepthNormalsTexture_TexelSize;

        // Dithering Variables
        float _HalftoneScale;
        float _HalftoneIntensity;
        
        // Dithering Pattern
        sampler2D _Dither;
        float4 _Dither_TexelSize;

        // Aberration Variables
        float _AberrationScale;

        // Outline Variables
        float _DepthScale;
        float _DepthBias;
        float _NormalScale;
        float _NormalBias;
        float _OutlineThickness;

        //---------------------------------------------------------------------------------------------------------------------------
        // Utility Functions 
        //---------------------------------------------------------------------------------------------------------------------------
        float Luma(float3 c) {
        #if LINEAR_COLOR
            c = LinearToGammaSpace(c);
        #endif
            return dot(c, half3(0.2126, 0.7152, 0.0722));
        }

        //---------------------------------------------------------------------------------------------------------------------------
        // Sobel Functions
        //---------------------------------------------------------------------------------------------------------------------------
        float SobelNormal(float2 uv, float3 offset) {
            float4 c = SAMPLE_TEXTURE2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, uv);
            float4 l = SAMPLE_TEXTURE2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, uv - offset.xz);
            float4 r = SAMPLE_TEXTURE2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, uv + offset.xz);
            float4 u = SAMPLE_TEXTURE2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, uv + offset.zy);
            float4 d = SAMPLE_TEXTURE2D(_CameraGBufferTexture2, sampler_CameraGBufferTexture2, uv - offset.zy);
 
            return dot(abs(l - c) + abs(r - c) + abs(u - c) + abs(d - c), float4(1,1,1,0));
        }

        float SobelDepth(float2 uv, float3 offset) {
            float c = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv));
            float l = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv - offset.xz));
            float r = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv + offset.xz));
            float u = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv + offset.zy));
            float d = LinearEyeDepth(SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, uv - offset.zy));

            return dot(abs(float4(l, r, u, d) - float4(c,c,c,c)), float4(1,1,1,1));
        }

        float Sobel(float2 texcoord){
            float3 offset = float3(1 / _ScreenParams.x, 1 / _ScreenParams.y, 0.0) * .5;

            float sobelDepth = SobelDepth(texcoord, offset);
            sobelDepth = pow(saturate(sobelDepth) * _DepthScale, _DepthBias);

            float sobelNormal = SobelNormal(texcoord, offset);
            sobelNormal = pow(sobelNormal * _NormalScale, _NormalBias);

            return saturate(max(sobelDepth, sobelNormal));
        }

        //---------------------------------------------------------------------------------------------------------------------------
        // Spiderverse Functions
        //---------------------------------------------------------------------------------------------------------------------------
        float dither(float2 texcoord) {
            float2 ditherCoords = texcoord * _Dither_TexelSize.xy * _ScreenParams.xy * _HalftoneScale;
            return tex2D(_Dither, ditherCoords);       
        }

        void aberration(out float4 color, out float lum, float2 texcoord) {
            float4 original = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, texcoord);
            lum = saturate(Luma(original.rgb));

            float d_enc = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, texcoord).r;            
            float depth = Linear01Depth(d_enc);

            float depth_offset = _ScreenParams.z * _AberrationScale * (depth * depth); 
            color.r = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, texcoord + depth_offset).r;
            color.g = original.g;
            color.b = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, texcoord - depth_offset).b;
            color.a = original.a;
        }

        float4 Frag(VaryingsDefault i) : SV_Target {
            float4 color;
            float lum;

            // Generates chromatic aberration based on depth
            aberration(color, lum, i.texcoord);

            float prev_a = color.a; // Saves old alpha

            // Determines color of Halftone dots
            float4 dot_color = lerp(color, float4(0,0,0,0), (dither(i.texcoord) * _HalftoneIntensity * lum));

            // Adds halftone dots to scene
            color = lerp(color, dot_color, (lum * lum));
            // Adds outlines to scene
            color = lerp(color, float4(0,0,0,1), Sobel(i.texcoord));

            return float4(color.rgb, prev_a);
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
