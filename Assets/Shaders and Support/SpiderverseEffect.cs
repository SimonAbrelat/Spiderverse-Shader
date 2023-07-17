// Aaron Lanterman, July 22, 2021
// Modified example from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects

using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

// Warning from https://github.com/Unity-Technologies/PostProcessing/wiki/Writing-Custom-Effects 
// Because of how serialization works in Unity, you have to make sure that the file is named 
// after your settings class name or it won't be serialized properly.

// This is the settings class
[Serializable]
[PostProcess(typeof(SpiderverseEffectRenderer), PostProcessEvent.AfterStack, "Custom/SpiderverseEffectShader")]
public sealed class SpiderverseEffect : PostProcessEffectSettings {
    [Tooltip("Outline Factors")]
    public FloatParameter depth_bias  = new FloatParameter { value = 3f };
    public FloatParameter depth_scale = new FloatParameter { value = 3f };
    public FloatParameter normal_bias  = new FloatParameter { value = 3f };
    public FloatParameter normal_scale = new FloatParameter { value = 3f };
    public FloatParameter outline_thickness = new FloatParameter { value = .5f };
    [Tooltip("Aberration Scale")]
    public FloatParameter a_scale = new FloatParameter { value = 10f };
    [Tooltip("Halftone dot intensity")]
    public FloatParameter d_intensity = new FloatParameter { value = .66f };
    [Tooltip("Halftone dot size")]
    public FloatParameter d_scale = new FloatParameter { value = 3f };
    [Tooltip ("Halftone dot texture lookup")]
    public TextureParameter ditherTex = new TextureParameter();
}

public sealed class SpiderverseEffectRenderer : PostProcessEffectRenderer<SpiderverseEffect> {
    public override void Render(PostProcessRenderContext context) {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/SpiderverseEffectShader"));
        sheet.properties.SetFloat("_AberrationScale", settings.a_scale);
        sheet.properties.SetFloat("_HalftoneIntensity", settings.d_intensity);
        sheet.properties.SetFloat("_HalftoneScale", settings.d_scale);
        sheet.properties.SetFloat("_DepthScale", settings.depth_scale);
        sheet.properties.SetFloat("_DepthBias", settings.depth_bias);
        sheet.properties.SetFloat("_NormalScale", settings.normal_scale);
        sheet.properties.SetFloat("_NormalBias", settings.normal_bias);
        sheet.properties.SetFloat("_OutlineThickness", settings.outline_thickness);
        sheet.properties.SetTexture("_Dither", settings.ditherTex);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}