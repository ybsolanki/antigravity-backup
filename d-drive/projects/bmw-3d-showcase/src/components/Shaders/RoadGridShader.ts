import * as THREE from 'three';

export const RoadGridShaderMaterial = {
  uniforms: {
    uTime: { value: 0 },
    uSpeed: { value: 1.0 },
    uColor: { value: new THREE.Color(0x1c69d2) },
    uMode: { value: 0 }, // 0: Comfort, 1: Sport, 2: M Track
  },
  vertexShader: /* glsl */ `
    varying vec2 vUv;
    varying vec3 vWorldPosition;

    void main() {
      vUv = uv;
      vec4 worldPos = modelMatrix * vec4(position, 1.0);
      vWorldPosition = worldPos.xyz;
      gl_Position = projectionMatrix * viewMatrix * worldPos;
    }
  `,
  fragmentShader: /* glsl */ `
    uniform float uTime;
    uniform float uSpeed;
    uniform vec3 uColor;
    uniform int uMode;

    varying vec2 vUv;
    varying vec3 vWorldPosition;

    void main() {
      vec2 uv = vWorldPosition.xz * 0.5;
      
      // Animate grid motion along Z axis
      uv.y += uTime * uSpeed * 3.0;

      // Anti-aliased Grid Lines
      vec2 gridUv = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
      float line = 1.0 - min(min(gridUv.x, gridUv.y), 1.0);

      // Speed streak lines along Z axis
      float streak = sin(vWorldPosition.z * 2.0 + uTime * uSpeed * 10.0) * 0.5 + 0.5;
      streak = pow(streak, 8.0) * step(0.95, fract(vWorldPosition.x * 0.8));

      // Distance radial fadeout (fade into horizon)
      float dist = length(vWorldPosition.xz);
      float fade = smoothstep(30.0, 5.0, dist);

      vec3 gridColor = uColor;
      if (uMode == 1) { // Sport
        gridColor = mix(vec3(0.9, 0.1, 0.1), vec3(1.0, 0.3, 0.0), sin(uTime * 4.0) * 0.5 + 0.5);
      } else if (uMode == 2) { // M Track
        gridColor = mix(vec3(0.0, 0.8, 1.0), vec3(0.9, 0.0, 0.3), fract(vWorldPosition.z * 0.1 + uTime));
      }

      vec3 finalColor = gridColor * (line * 0.8 + streak * 2.0);
      float alpha = (line * 0.6 + streak * 0.9) * fade;

      gl_FragColor = vec4(finalColor, alpha);
    }
  `,
};
