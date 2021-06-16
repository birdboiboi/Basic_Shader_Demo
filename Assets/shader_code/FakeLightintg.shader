Shader "Unlit/FakeLightintg"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
			//from unity to vertex part of gpu
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;//0.00000,0.0000,0.00000
            };
			//between vertex and fragment
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				fixed3 worldNormal : NORMAL;
				fixed3 worldPos : TEXCOORD1;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal); 
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				//o.worldNormal = v.normal;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
				// col = col + anything 
				fixed3 lightDirVect = _WorldSpaceLightPos0.xyz - i.worldPos;
				fixed scalarDotProduct = dot(i.worldNormal, lightDirVect);
				col = col * scalarDotProduct;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
