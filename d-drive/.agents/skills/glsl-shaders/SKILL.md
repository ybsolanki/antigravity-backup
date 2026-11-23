---
name: glsl-shaders
description: >-
  Mastery skill for writing custom OpenGL Shading Language (GLSL) vertex and fragment shaders,
  procedural noise algorithms, raymarching with Signed Distance Fields (SDFs), custom lighting models,
  and post-processing effects. Use when the user asks for GLSL shader code, vertex displacement,
  fragment shaders, noise functions, raymarching, or custom material shaders.
---

# GLSL Shaders Mastery Skill

Use this skill when writing custom **GLSL Vertex Shaders** and **Fragment Shaders** for WebGL engines (Three.js, React Three Fiber, Babylon.js, WebGL2/WebGPU).

---

## 1. Shader Data Types & Variable Qualifiers

| Qualifier | Direction / Source | Usage |
| :--- | :--- | :--- |
| `attribute` (`in` WebGL2) | CPU -> Vertex Shader | Per-vertex data (position, normal, uv, color, custom attributes). |
| `uniform` | CPU -> Vertex & Fragment | Constant per draw-call values (`uTime`, `uResolution`, `uMouse`, matrices). |
| `varying` (`out` Vert, `in` Frag) | Vertex -> Fragment | Interpolated data across rasterized polygon surfaces. |

---

## 2. Production Procedural 2D Simplex Noise Function

```glsl
// Simplex 2D Noise by Ian McEwan, Stefan Gustavson
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                     -0.577350269189626, 0.024390243902439);
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);
  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i, 289.0);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
  + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;
  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}
```

---

## 3. Custom Blinn-Phong Lighting & Fresnel Fragment Shader

```glsl
precision mediump float;

uniform vec3 uLightPosition;
uniform vec3 uCameraPosition;
uniform vec3 uBaseColor;
uniform vec3 uLightColor;

varying vec3 vNormal;
varying vec3 vWorldPosition;
varying vec2 vUv;

void main() {
  vec3 normal = normalize(vNormal);
  vec3 lightDir = normalize(uLightPosition - vWorldPosition);
  vec3 viewDir = normalize(uCameraPosition - vWorldPosition);

  // 1. Ambient
  vec3 ambient = 0.15 * uBaseColor;

  // 2. Diffuse (Lambert)
  float diff = max(dot(normal, lightDir), 0.0);
  vec3 diffuse = diff * uBaseColor * uLightColor;

  // 3. Specular (Blinn-Phong)
  vec3 halfDir = normalize(lightDir + viewDir);
  float spec = pow(max(dot(normal, halfDir), 0.0), 32.0);
  vec3 specular = spec * uLightColor;

  // 4. Fresnel Rim Effect
  float fresnel = pow(1.0 - max(dot(viewDir, normal), 0.0), 3.0);
  vec3 rimColor = vec3(0.2, 0.6, 1.0) * fresnel;

  vec3 finalColor = ambient + diffuse + specular + rimColor;
  gl_FragColor = vec4(finalColor, 1.0);
}
```

---

## 4. Raymarching volumetric shapes with Signed Distance Fields (SDF)

```glsl
precision highp float;

uniform vec2 uResolution;
uniform float uTime;

// Sphere SDF
float sdSphere(vec3 p, float r) {
  return length(p) - r;
}

// Box SDF
float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

// Smooth Union Operator
float opSmoothUnion(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

// Scene SDF evaluation
float map(vec3 p) {
  vec3 p1 = p - vec3(sin(uTime) * 1.5, 0.0, 0.0);
  float sphere = sdSphere(p1, 1.2);
  float box = sdBox(p, vec3(1.0));
  return opSmoothUnion(sphere, box, 0.5);
}

void main() {
  vec2 uv = (gl_FragCoord.xy - 0.5 * uResolution.xy) / uResolution.y;

  vec3 ro = vec3(0.0, 0.0, -4.0); // Ray origin (Camera)
  vec3 rd = normalize(vec3(uv, 1.0)); // Ray direction

  float t = 0.0;
  for (int i = 0; i < 64; i++) {
    vec3 p = ro + rd * t;
    float d = map(p);
    t += d;
    if (d < 0.001 || t > 20.0) break;
  }

  vec3 color = vec3(0.05, 0.08, 0.12);
  if (t < 20.0) {
    vec3 p = ro + rd * t;
    // Calculate normal via gradient finite difference
    vec2 e = vec2(0.001, 0.0);
    vec3 n = normalize(vec3(
      map(p + e.xyy) - map(p - e.xyy),
      map(p + e.yxy) - map(p - e.yxy),
      map(p + e.yyx) - map(p - e.yyx)
    ));
    float diff = max(dot(n, normalize(vec3(1.0, 2.0, -1.0))), 0.0);
    color = vec3(0.2, 0.6, 1.0) * diff + vec3(0.1);
  }

  gl_FragColor = vec4(color, 1.0);
}
```

---

## 5. Screen Space Post-Processing Shader (Vignette + Chromatic Aberration)

```glsl
uniform sampler2D tDiffuse;
uniform vec2 uResolution;
varying vec2 vUv;

void main() {
  vec2 uv = vUv;
  vec2 distFromCenter = uv - 0.5;
  
  // Chromatic Aberration offset based on distance from screen center
  float r = texture2D(tDiffuse, uv + distFromCenter * 0.015).r;
  float g = texture2D(tDiffuse, uv).g;
  float b = texture2D(tDiffuse, uv - distFromCenter * 0.015).b;
  vec3 color = vec3(r, g, b);

  // Radial Vignette
  float vignette = smoothstep(0.8, 0.2, length(distFromCenter));
  color *= vignette;

  gl_FragColor = vec4(color, 1.0);
}
```

---

## Shader Best Practices Checklist

1. **Avoid division by zero**: `clamp(denominator, 0.0001, 1.0)`.
2. **Use smoothstep for smooth masking**: Replaces hard `if (dist < radius)` conditions.
3. **Normalize normal vectors in fragment shaders**: Interpolation across varyings reduces length.
4. **Use fract(sin(dot(...)) * 43758.5453)** for quick pseudo-random hash functions.
