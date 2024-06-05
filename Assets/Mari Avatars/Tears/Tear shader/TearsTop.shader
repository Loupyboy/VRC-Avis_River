Shader "TearsTop"
{
    Properties
    {
        _tint ("Tear Color", Color) = (1, 1, 1, 1)
        _speed("Tear Speed", Float) = 1
        _Cutoff( "Mask Clip Value", Float ) = 0.5
        _tears_outline("tears_outline", 2D) = "white" {}
        _tears_mask("tears_mask", 2D) = "white" {}
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
        [HideInInspector] __dirty( "", Int ) = 1
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "TransparentCutout" "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"
        }
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass {}
        CGPROGRAM
        #include "UnityShaderVariables.cginc"
        #pragma target 3.0
        #if defined(UNITY_STEREO_INSTANCING_ENABLED) || defined(UNITY_STEREO_MULTIVIEW_ENABLED)
		#define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex);
        #else
        #define ASE_DECLARE_SCREENSPACE_TEXTURE(tex) UNITY_DECLARE_SCREENSPACE_TEXTURE(tex)
        #endif
        #pragma surface surf Standard keepalpha addshadow fullforwardshadows
        struct Input
        {
            float2 uv_texcoord;
            float4 screenPos;
        };

        uniform sampler2D _tears_outline;
        ASE_DECLARE_SCREENSPACE_TEXTURE(_GrabTexture)
        uniform sampler2D _tears_mask;
        uniform float4 _tears_mask_ST;
        uniform float _Cutoff = 0.5;
        uniform float _speed;
        uniform float4 _tint;

        inline float noise_random_value(float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453); }

        inline float noise_interpolate(float a, float b, float t) { return (1.0 - t) * a + t * b; }

        inline float value_noise(float2 uv)
        {
            const float2 i = floor(uv);
            const float2 f_frac = frac(uv);
            const float2 f = f_frac * f_frac * (3.0 - 2.0 * f_frac);
            const float2 c0 = i + float2(0.0, 0.0);
            const float2 c1 = i + float2(1.0, 0.0);
            const float2 c2 = i + float2(0.0, 1.0);
            const float2 c3 = i + float2(1.0, 1.0);
            const float r0 = noise_random_value(c0);
            const float r1 = noise_random_value(c1);
            const float r2 = noise_random_value(c2);
            const float r3 = noise_random_value(c3);
            const float bottom_of_grid = noise_interpolate(r0, r1, f.x);
            const float top_of_grid = noise_interpolate(r2, r3, f.x);
            const float t = noise_interpolate(bottom_of_grid, top_of_grid, f.y);
            return t;
        }


        float simple_noise(float2 UV)
        {
            float t = 0.0;
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3 - 0));
            t += value_noise(UV / freq) * amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3 - 1));
            t += value_noise(UV / freq) * amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3 - 2));
            t += value_noise(UV / freq) * amp;
            return t;
        }


        inline float4 ase_compute_grab_screen_pos(float4 pos)
        {
            #if UNITY_UV_STARTS_AT_TOP
            const float scale = -1.0;
            #else
			const float scale = 1.0;
            #endif
            float4 o = pos;
            o.y = pos.w * 0.5f;
            o.y = (pos.y - o.y) * _ProjectionParams.x * scale + o.y;
            return o;
        }


        void surf(Input i, inout SurfaceOutputStandard o)
        {
            const float2 panner38 = (_speed * _Time.y * float2(1, 1) + i.uv_texcoord);
            const float simple_noise63 = simple_noise(panner38 * 30.0);
            const float temp_output_51_0 = (0.52 * tex2D(_tears_outline,
                                                         i.uv_texcoord + (-0.01 + simple_noise63 * 0.02), float2(0, 0),
                                                         float2(0, 0)).r);
            const float4 ase_screen_pos = float4(i.screenPos.xyz, i.screenPos.w + 0.00000000001);
            const float4 ase_grab_screen_pos = ase_compute_grab_screen_pos(ase_screen_pos);
            const float4 ase_grab_screen_pos_norm = ase_grab_screen_pos / ase_grab_screen_pos.w;
            const float4 tear_color = UNITY_SAMPLE_SCREENSPACE_TEXTURE(
                _GrabTexture,
                temp_output_51_0 * (0.2 + simple_noise63 * -0.4) + ase_grab_screen_pos_norm.xy
            ) * _tint;
            o.Emission = temp_output_51_0 + tear_color.rgb;
            o.Alpha = 1;
            const float2 uv_tears_mask = i.uv_texcoord * _tears_mask_ST.xy + _tears_mask_ST.zw;
            clip(tex2D(_tears_mask, uv_tears_mask, float2(0, 0), float2(0, 0)).r - _Cutoff);
        }
        ENDCG
    }
    Fallback "Diffuse"
    CustomEditor "ASEMaterialInspector"
}