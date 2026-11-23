import * as THREE from 'three';

export const HeadlightShaderMaterial = {
  uniforms: {
    uTime: { value: 0 },
    uColor: { value: new THREE.Color(0x88ccff) },
    uIntensity: { value: 1.0 },
  },
  vertexShader: /* glsl */ `
    varying vec3 vNormal;
    varying vec3 vWorldPosition;
    varying vec2 vUv;

    void main() {
      vUv = uv;
      vNormal = normalize(normalMatrix * normal);
      vec4 worldPos = modelMatrix * vec4(position, 1.0);
      vWorldPosition = worldPos.xyz;
      gl_Position = projectionMatrix * viewMatrix * worldPos;
    }
  `,
  fragmentShader: /* glsl */ `
    uniform float uTime;
    uniform vec3 uColor;
    uniform float uIntensity;

    varying vec3 vNormal;
    varying vec3 vWorldPosition;
    varying vec2 vUv;

    void main() {
      // Cone length fade (from tip UV y=0 to base UV y=1)
      float lengthFade = smoothstep(0.0, 0.4, vUv.y) * smoothstep(1.0, 0.6, vUv.y);

      // Edge falloff based on normal facing angle to camera
      vec3 viewDir = normalize(cameraPosition - vWorldPosition);
      float edgeFade = pow(1.0 - abs(dot(viewDir, vNormal)), 2.0);

      // Subtle volumetric light dust flicker
      float flicker = sin(uTime * 15.0 + vWorldPosition.x * 10.0) * 0.05 + 0.95;

      vec3 beamColor = uColor * uIntensity * flicker * 2.0;
      float alpha = lengthFade * edgeFade * 0.4 * uIntensity;

      gl_FragColor = vec4(beamColor, alpha);
    }
  `,
};
