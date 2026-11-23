---
name: react-three-fiber
description: >-
  Mastery skill for building declarative 3D user interfaces and visual experiences in React using
  React Three Fiber (@react-three/fiber), Drei (@react-three/drei), and Rapier physics (@react-three/rapier).
  Use when the user asks for R3F, React 3D components, Drei helpers, React GLSL shaders, or declarative 3D scenes.
---

# React Three Fiber (R3F) Mastery Skill

Use this skill when building declarative 3D graphics applications in React using `@react-three/fiber` and `@react-three/drei`.

---

## 1. Declarative `<Canvas>` Setup Boilerplate

```tsx
import React, { Suspense, useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Environment, ContactShadows, Float, Html } from '@react-three/drei';
import * as THREE from 'three';

function RotatingCube() {
  const meshRef = useRef<THREE.Mesh>(null!);

  // Animation loop inside R3F - NO React re-renders, direct mutation of THREE object
  useFrame((state, delta) => {
    meshRef.current.rotation.y += delta * 0.5;
    meshRef.current.rotation.x += delta * 0.2;
  });

  return (
    <Float speed={2} rotationIntensity={0.5} floatIntensity={1}>
      <mesh ref={meshRef} castShadow receiveShadow>
        <boxGeometry args={[2, 2, 2]} />
        <meshStandardMaterial color="#6366f1" roughness={0.1} metalness={0.8} />
        <Html position={[0, 1.5, 0]} center distanceFactor={10}>
          <div className="bg-slate-900/80 backdrop-blur text-white text-xs px-2 py-1 rounded shadow border border-slate-700">
            Interactive Cube
          </div>
        </Html>
      </mesh>
    </Float>
  );
}

export default function SceneView() {
  return (
    <div style={{ width: '100vw', height: '100vh', background: '#090d16' }}>
      <Canvas
        shadows
        dpr={[1, 2]} // Capped device pixel ratio
        camera={{ position: [0, 3, 8], fov: 50 }}
        gl={{ antialias: true, powerPreference: 'high-performance' }}
      >
        <ambientLight intensity={0.5} />
        <directionalLight position={[10, 10, 5]} intensity={1.5} castShadow shadow-mapSize={1024} />

        <Suspense fallback={null}>
          <RotatingCube />
          <Environment preset="city" />
        </Suspense>

        <ContactShadows position={[0, -1.5, 0]} opacity={0.6} scale={10} blur={2} far={4} />
        <OrbitControls makeDefault enableDamping dampingFactor={0.05} />
      </Canvas>
    </div>
  );
}
```

---

## 2. Custom GLSL Shader Material in R3F (`shaderMaterial`)

```tsx
import React, { useRef } from 'react';
import { Canvas, useFrame, extend } from '@react-three/fiber';
import { shaderMaterial } from '@react-three/drei';
import * as THREE from 'three';

// Define Custom Shader Material
const WaveShaderMaterial = shaderMaterial(
  // 1. Uniforms
  {
    uTime: 0,
    uColor: new THREE.Color(0x3b82f6),
  },
  // 2. Vertex Shader
  /* glsl */ `
    uniform float uTime;
    varying vec2 vUv;
    varying float vElevation;

    void main() {
      vUv = uv;
      vec4 modelPosition = modelMatrix * vec4(position, 1.0);

      float elevation = sin(modelPosition.x * 3.0 + uTime * 2.0) * 0.2
                      + cos(modelPosition.z * 2.0 + uTime * 1.5) * 0.2;
      modelPosition.y += elevation;

      vElevation = elevation;
      gl_Position = projectionMatrix * viewMatrix * modelPosition;
    }
  `,
  // 3. Fragment Shader
  /* glsl */ `
    uniform vec3 uColor;
    varying vec2 vUv;
    varying float vElevation;

    void main() {
      vec3 color = uColor + vElevation * 0.4;
      gl_FragColor = vec4(color, 1.0);
    }
  `
);

// Register with JSX elements
extend({ WaveShaderMaterial });

// TypeScript declaration for JSX
declare global {
  namespace JSX {
    interface IntrinsicElements {
      waveShaderMaterial: any;
    }
  }
}

function WavePlane() {
  const shaderRef = useRef<any>(null!);

  useFrame((state, delta) => {
    if (shaderRef.current) {
      shaderRef.current.uTime += delta;
    }
  });

  return (
    <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, 0]}>
      <planeGeometry args={[10, 10, 64, 64]} />
      <waveShaderMaterial ref={shaderRef} key={WaveShaderMaterial.key} />
    </mesh>
  );
}
```

---

## 3. Physics Integration with `@react-three/rapier`

```tsx
import React from 'react';
import { Canvas } from '@react-three/fiber';
import { Physics, RigidBody, CuboidCollider } from '@react-three/rapier';

function DynamicScene() {
  return (
    <Physics gravity={[0, -9.81, 0]}>
      {/* Dynamic Falling Object */}
      <RigidBody restitution={0.7} position={[0, 5, 0]}>
        <mesh castShadow>
          <sphereGeometry args={[1, 32, 32]} />
          <meshStandardMaterial color="#ef4444" roughness={0.3} />
        </mesh>
      </RigidBody>

      {/* Static Ground Floor */}
      <RigidBody type="fixed" position={[0, -1, 0]}>
        <mesh receiveShadow>
          <boxGeometry args={[20, 1, 20]} />
          <meshStandardMaterial color="#334155" />
        </mesh>
      </RigidBody>
    </Physics>
  );
}
```

---

## R3F Performance Best Practices

1. **Never trigger React state inside `useFrame`**: Update Three.js object properties directly via `ref.current`.
2. **Use `dpr={[1, 2]}`**: Prevents rendering at native 4K resolutions on mobile/Mac display screens.
3. **Wrap async loaders/assets in `<Suspense>`**: Prevents white-screens and broken state during model loading.
4. **Use Drei's `Instances` & `Instance`**: Componentized wrapper over `InstancedMesh` for rendering thousands of React sub-trees efficiently.
