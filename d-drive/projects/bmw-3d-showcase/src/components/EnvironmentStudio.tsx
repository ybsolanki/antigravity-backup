import React, { useRef, useMemo } from 'react';
import { useFrame } from '@react-three/fiber';
import { ContactShadows, Environment } from '@react-three/drei';
import * as THREE from 'three';
import { RoadGridShaderMaterial } from './Shaders/RoadGridShader';

interface EnvironmentStudioProps {
  driveMode: 'comfort' | 'sport' | 'mtrack';
  isMoving?: boolean;
}

export const EnvironmentStudio: React.FC<EnvironmentStudioProps> = ({ driveMode, isMoving = true }) => {
  const roadMatRef = useRef<THREE.ShaderMaterial>(null!);

  // Mode based light colors & intensities
  const lightConfig = useMemo(() => {
    if (driveMode === 'sport') {
      return {
        ambient: '#200505',
        key: '#ff2222',
        fill: '#ff5500',
        spot: '#ff0033',
        grid: new THREE.Color(0xef4444),
        modeInt: 1,
      };
    } else if (driveMode === 'mtrack') {
      return {
        ambient: '#020b18',
        key: '#00d2ff',
        fill: '#ff0055',
        spot: '#00ffff',
        grid: new THREE.Color(0x00d2ff),
        modeInt: 2,
      };
    }
    return {
      ambient: '#090d16',
      key: '#ffffff',
      fill: '#1c69d2',
      spot: '#38bdf8',
      grid: new THREE.Color(0x1c69d2),
      modeInt: 0,
    };
  }, [driveMode]);

  // Road Grid Shader Material
  const roadShader = useMemo(() => {
    return new THREE.ShaderMaterial({
      ...RoadGridShaderMaterial,
      transparent: true,
      depthWrite: false,
      side: THREE.DoubleSide,
    });
  }, []);

  useFrame((state) => {
    if (roadShader) {
      roadShader.uniforms.uTime.value = state.clock.getElapsedTime();
      roadShader.uniforms.uSpeed.value = isMoving ? (driveMode === 'mtrack' ? 4.0 : driveMode === 'sport' ? 2.5 : 1.2) : 0.0;
      roadShader.uniforms.uColor.value = lightConfig.grid;
      roadShader.uniforms.uMode.value = lightConfig.modeInt;
    }
  });

  return (
    <group>
      {/* Dynamic Studio Ambient & Key Lights */}
      <ambientLight intensity={0.7} color={lightConfig.ambient} />
      
      {/* Overhead Dramatic Studio Spotlight */}
      <spotLight
        position={[0, 15, 0]}
        intensity={3.5}
        angle={0.6}
        penumbra={0.8}
        color={lightConfig.spot}
        castShadow
      />

      {/* Primary Key Light with Soft Shadows */}
      <directionalLight
        position={[10, 14, 8]}
        intensity={2.2}
        color={lightConfig.key}
        castShadow
        shadow-mapSize={2048}
        shadow-camera-near={0.5}
        shadow-camera-far={35}
        shadow-camera-left={-8}
        shadow-camera-right={8}
        shadow-camera-top={8}
        shadow-camera-bottom={-8}
      />

      {/* Secondary Fill & Rim Lights */}
      <directionalLight position={[-10, 8, -8]} intensity={1.8} color={lightConfig.fill} />
      <pointLight position={[0, -0.2, 4]} intensity={1.5} color={lightConfig.key} />
      <pointLight position={[0, 0.2, -4]} intensity={1.5} color={lightConfig.fill} />

      {/* Realistic Contact Shadows Under Car */}
      <ContactShadows
        position={[0, 0, 0]}
        opacity={0.85}
        scale={14}
        blur={1.6}
        far={6}
        resolution={1024}
        color="#000000"
      />

      {/* Animated GLSL Cyber Road Grid Floor */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.01, 0]} material={roadShader}>
        <planeGeometry args={[100, 100, 1, 1]} />
      </mesh>

      {/* Realistic HDRI Studio Reflections */}
      <Environment preset="city" background={false} environmentIntensity={0.9} />
    </group>
  );
};
