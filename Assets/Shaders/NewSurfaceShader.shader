Shader "Transparent/with material" {
  Properties {
    _MainTex ("Base (RGB)", 2D) = "white" {}
	_Color ("Color", Color) = (0.3, 0.4, 0.7, 1.0)
  }
  SubShader {
    Tags { "RenderType"="Opaque" "Queue"="Geometry+1" "ForceNoShadowCasting"="True" }
    LOD 200
    Offset -1, -1
    
    CGPROGRAM
    #pragma surface surf Lambert decal:blend
    
    sampler2D _MainTex;
          fixed4 _Color;

    struct Input {
      float2 uv_MainTex;
    };
    
    void surf (Input IN, inout SurfaceOutput o) {
        half4 c = tex2D (_MainTex, IN.uv_MainTex)* _Color;
        o.Albedo = c.rgb;
        o.Alpha = _Color.a;
      }
    ENDCG
    }
}