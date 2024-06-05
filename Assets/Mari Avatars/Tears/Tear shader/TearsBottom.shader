Shader "TearsBottom"
{
    Properties
    {
        _tint ("Tear Color", Color) = (1, 1, 1, 1)
        _speed("Tear Speed", Float) = 1
        _Cutoff( "Mask Clip Value", Float ) = 0.5
        _tears_mask("Tears Mask", 2D) = "white" {}
        _tears_outline("Tears Outline Mask", 2D) = "white" {}
        _tear_size("tear_size", Float) = 1
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
        Blend SrcAlpha OneMinusSrcAlpha , One Zero
        BlendOp Add , Add
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
        uniform sampler2D _tears_mask;
        ASE_DECLARE_SCREENSPACE_TEXTURE(_GrabTexture)
        uniform float _Cutoff;
        uniform float _tear_size;
        uniform float _speed;
        uniform float4 _tint;


        inline float noise_random_value(float2 uv) { return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453); }

        inline float noise_interpolate(float a, float b, float t) { return (1.0 - t) * a + (t * b); }

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
            return noise_interpolate(bottom_of_grid, top_of_grid, f.y);
        }

        float simple_noise(float2 uv)
        {
            float t = 0.0;
            float freq = pow(2.0, float(0));
            float amp = pow(0.5, float(3 - 0));
            t += value_noise(uv / freq) * amp;
            freq = pow(2.0, float(1));
            amp = pow(0.5, float(3 - 1));
            t += value_noise(uv / freq) * amp;
            freq = pow(2.0, float(2));
            amp = pow(0.5, float(3 - 2));
            t += value_noise(uv / freq) * amp;
            return t;
        }

        inline float4 ase_compute_grab_screen_pos(float4 pos)
        {
            #if UNITY_UV_STARTS_AT_TOP
            const float scale = -_tear_size;
            #else
			float scale = _tear_size;
            #endif
            float4 o = pos;
            o.y = pos.w * .5f;
            o.y = (pos.y - o.y) * _ProjectionParams.x * scale + o.y;
            return o;
        }

        void surf(Input i, inout SurfaceOutputStandard o)
        {
            const float2 panner35 = _speed * _Time.y * float2(0, 0.5) + i.uv_texcoord;
            const float clamp_result16 = clamp(
                -1.0 + tex2D(_tears_outline, panner35, float2(0, 0), float2(0, 0)).r * 4.0 * 3.0,
                0.0,
                1.0
            );
            float4 tex_2d_node116 = tex2D(_tears_mask, panner35, float2(0, 0), float2(0, 0));
            const float clamp_result17 = clamp((tex_2d_node116.r * 0.1), 0.0, 1.0);
            const float clamp_result21 = clamp((clamp_result16 + clamp_result17), 0.0, 1.0);
            const float temp_output_130_0 = (i.uv_texcoord).y;
            const float clamp_result136 = clamp(
                temp_output_130_0 * 0.6 * (-1.0 + temp_output_130_0 * 2.3),
                0.0,
                1.0
            );
            const float2 panner62 = (1.0 * _Time.y * float2(0.5, 0.5) + i.uv_texcoord);
            const float simple_noise87 = simple_noise(panner62 * 40.0);
            const float4 ase_screen_pos = float4(i.screenPos.xyz, i.screenPos.w + 0.00000000001);
            const float4 ase_grab_screen_pos = ase_compute_grab_screen_pos(ase_screen_pos);
            const float4 ase_grab_screen_pos_norm = ase_grab_screen_pos / ase_grab_screen_pos.w;
            float4 tear_color = UNITY_SAMPLE_SCREENSPACE_TEXTURE(
                _GrabTexture,
                (tex_2d_node116.r * clamp_result136 * (0.1 + simple_noise87 * -0.2) + ase_grab_screen_pos_norm).xy
            ) * _tint;
            const float3 emission = clamp(
                clamp_result21 * clamp_result136 + tear_color.rgb,
                float3(0, 0, 0),
                float3(1, 1, 1)
            );

            o.Emission = emission;
            o.Alpha = 1;
            clip(tex_2d_node116.r - _Cutoff);
        }
        ENDCG
    }
    Fallback "Diffuse"
    CustomEditor "ASEMaterialInspector"
}