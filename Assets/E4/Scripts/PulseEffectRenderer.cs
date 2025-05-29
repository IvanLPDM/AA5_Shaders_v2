using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public sealed class PulseEffectRenderer : PostProcessEffectRenderer<PulseEffect>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Unlit/E4"));


        sheet.properties.SetColor("_PulseColor", settings.pulseColor);
        sheet.properties.SetFloat("_PulseSpeed", settings.pulseSpeed);
        sheet.properties.SetFloat("_PulseWidth", settings.pulseWidth);
        sheet.properties.SetFloat("_TimeSinceStart", Time.time);
        sheet.properties.SetVector("_CameraWorldPos", context.camera.transform.position);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}