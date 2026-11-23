import * as THREE from 'three';

export const HologramShaderMaterial = {
  uniforms: {
    uTime: { value: 0 },
    uColor: { value: new THREE.Color(0x00d2ff) },
  },
  vertexShader: /* glsl */ `
    uniform float uTime;
    varying vec3 vNormal;
    varying vec3 vWorldPosition;
    varying vec2 vUv;

    void main() {
      vUv = uv;
      vNormal = normalize(normalMatrix * normal);
      
      vec4 worldPos = modelMatrix * vec4(position, 1.0);
      vWorldPosition = worldPos.xyz;

      // Slight vertex displacement scan wave
      float wave = sin(worldPos.y * 10.0 + uTime * 4.0) * 0.02;
      worldPos.xyz += normal * wave;

      gl_Position = projectionMatrix * viewMatrix * worldPos;
    }
  `,
  fragmentShader: /* glsl */ `
    uniform float uTime;
    uniform vec3 uColor;

    varying vec3 vNormal;
    varying vec3 vWorldPosition;
    varying vec2 vUv;

    void main() {
      vec3 viewDir = normalize(cameraPosition - vWorldPosition);
      
      // Fresnel Rim Light calculation
      float fresnel = pow(1.0 - max(dot(viewDir, vNormal), 0.0), 2.5);

      // Scanline effect across vertical height
      float scanline = sin(vWorldPosition.y * 40.0 - uTime * 8.0) * 0.5 + 0.5;
      scanline = pow(scanline, 2.0);

      // Grid lattice pattern
      float grid = step(0.92, fract(vUv.x * 30.0)) + step(0.92, fract(vUv.y * 30.0));

      vec3 glowColor = uColor * (fresnel * 2.5 + scanline * 0.4 + grid * 0.6);
      float alpha = clamp(fresnel * 0.8 + scanline * 0.3 + 0.1, 0.1, 0.9);

      gl_FragColor = vec4(glowColor, alpha);
    }
  `,
};
