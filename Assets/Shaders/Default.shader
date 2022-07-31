Shader "Example/Default"
{
    // https://docs.unity3d.com/Manual/SL-Properties.html
    // https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
    Properties
    {
        [MainTexture] _BaseMap("Base Map", 2D) = "white" 
        _floatProperty("FloatProperty", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            // write other properties here to be SRP Batcher compatible 
            CBUFFER_START(UnityPerMaterial)
                float _floatProperty;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = mul(UNITY_MATRIX_MVP, IN.positionOS); // TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                float4 customColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                return customColor + _floatProperty;
            }
            ENDHLSL
        }
    }
}