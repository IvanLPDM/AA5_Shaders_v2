using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[System.Serializable]
[PostProcess(typeof(PulseEffectRenderer), PostProcessEvent.AfterStack, "Custom/PulseEffect")]
public sealed class PulseEffect : PostProcessEffectSettings
{
    [ColorUsage(false, true)]

    public ColorParameter pulseColor = new ColorParameter { value = Color.white };
    public FloatParameter pulseSpeed = new FloatParameter { value = 2f };
    public FloatParameter pulseWidth = new FloatParameter { value = 1f };
}