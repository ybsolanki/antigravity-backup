import React, { useRef, useMemo, useEffect } from 'react';
import { useFrame } from '@react-three/fiber';
import { useGLTF } from '@react-three/drei';
import * as THREE from 'three';
import { HologramShaderMaterial } from './Shaders/HologramShader';
import { HeadlightShaderMaterial } from './Shaders/HeadlightShader';

interface BmwCarModelProps {
  carColor: string;
  isXRay: boolean;
  headlightsOn: boolean;
  driveMode: 'comfort' | 'sport' | 'mtrack';
  isMoving?: boolean;
}

export const BmwCarModel: React.FC<BmwCarModelProps> = ({
  carColor,
  isXRay,
  headlightsOn,
  driveMode,
  isMoving = true,
}) => {
  const groupRef = useRef<THREE.Group>(null!);
  const wheelNodesRef = useRef<THREE.Object3D[]>([]);

  // Load actual BMW M4 3D GLB model from /public/bmw.glb
  const { scene: originalScene } = useGLTF('/bmw.glb');

  // Clone GLTF scene graph so material mutations are isolated per instance
  const clonedScene = useMemo(() => originalScene.clone(true), [originalScene]);

  // Custom Shader Materials
  const hologramShader = useMemo(() => {
    return new THREE.ShaderMaterial({
      ...HologramShaderMaterial,
      transparent: true,
      depthWrite: false,
      side: THREE.DoubleSide,
    });
  }, []);

  const headlightShader = useMemo(() => {
    return new THREE.ShaderMaterial({
      ...HeadlightShaderMaterial,
      transparent: true,
      depthWrite: false,
      blending: THREE.AdditiveBlending,
      side: THREE.DoubleSide,
    });
  }, []);

  // Emissive Kidney Grille Glow Color
  const grilleGlowColor = useMemo(() => {
    if (driveMode === 'sport') return '#ef4444';
    if (driveMode === 'mtrack') return '#00d2ff';
    return '#1c69d2';
  }, [driveMode]);

  // Initial One-Time Scene Setup: Save original materials & collect wheel nodes
  useEffect(() => {
    if (!clonedScene) return;

    // 1. Calculate bounding box & normalize scale/center
    const box = new THREE.Box3().setFromObject(clonedScene);
    const size = box.getSize(new THREE.Vector3());
    const center = box.getCenter(new THREE.Vector3());

    const maxDim = Math.max(size.x, size.y, size.z);
    if (maxDim > 0) {
      const scaleFactor = 4.6 / maxDim;
      clonedScene.scale.set(scaleFactor, scaleFactor, scaleFactor);

      clonedScene.position.x = -center.x * scaleFactor;
      clonedScene.position.y = -box.min.y * scaleFactor;
      clonedScene.position.z = -center.z * scaleFactor;
    }

    const detectedWheels: THREE.Object3D[] = [];

    // 2. Traversal: Store original materials & identify wheel nodes
    clonedScene.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        const mesh = child as THREE.Mesh;
        mesh.castShadow = true;
        mesh.receiveShadow = true;

        // Store original material on userData for robust restoration
        if (!mesh.userData.originalMaterial) {
          mesh.userData.originalMaterial = mesh.material;
        }

        const name = (mesh.name || '').toLowerCase();
        const matName = ((mesh.material as THREE.Material)?.name || '').toLowerCase();

        // Detect wheel / rim / tire nodes for rolling animation
        if (
          name.includes('wheel') ||
          name.includes('tire') ||
          name.includes('tyre') ||
          name.includes('rim') ||
          matName.includes('wheel') ||
          matName.includes('tire') ||
          matName.includes('rim')
        ) {
          detectedWheels.push(mesh);
        }
      }
    });

    // If name search missed some wheels, fallback to searching top-level groups near wheel coordinates
    if (detectedWheels.length === 0) {
      clonedScene.traverse((child) => {
        const name = (child.name || '').toLowerCase();
        if (name.includes('wheel') || name.includes('tire') || name.includes('rim')) {
          detectedWheels.push(child);
        }
      });
    }

    wheelNodesRef.current = detectedWheels;
  }, [clonedScene]);

  // Dynamic Material Updates (Paint color & Hologram ON/OFF toggle restoration)
  useEffect(() => {
    if (!clonedScene) return;

    clonedScene.traverse((child) => {
      if ((child as THREE.Mesh).isMesh) {
        const mesh = child as THREE.Mesh;

        if (isXRay) {
          // Turn Hologram ON
          mesh.material = hologramShader;
        } else {
          // Turn Hologram OFF: Restore original material
          if (mesh.userData.originalMaterial) {
            mesh.material = mesh.userData.originalMaterial;
          }

          // Apply custom paint color to body paint materials
          const matName = ((mesh.material as THREE.Material)?.name || '').toLowerCase();
          const meshName = (mesh.name || '').toLowerCase();

          if (
            matName.includes('paint') ||
            matName.includes('body') ||
            matName.includes('car_paint') ||
            matName.includes('primary') ||
            meshName.includes('body') ||
            matName.includes('color')
          ) {
            mesh.material = new THREE.MeshPhysicalMaterial({
              color: new THREE.Color(carColor),
              metalness: 0.88,
              roughness: 0.12,
              clearcoat: 1.0,
              clearcoatRoughness: 0.08,
              reflectivity: 0.95,
            });
          }
        }
      }
    });
  }, [clonedScene, carColor, isXRay, hologramShader]);

  // Animation Loop (Continuous Wheel Rolling + Shaders)
  useFrame((state, delta) => {
    if (hologramShader) {
      hologramShader.uniforms.uTime.value = state.clock.getElapsedTime();
    }
    if (headlightShader) {
      headlightShader.uniforms.uTime.value = state.clock.getElapsedTime();
      headlightShader.uniforms.uIntensity.value = headlightsOn ? 1.0 : 0.0;
    }

    // CONTINUOUS WHEEL ROLLING ANIMATION
    if (isMoving) {
      const rollSpeed = driveMode === 'mtrack' ? 18.0 : driveMode === 'sport' ? 12.0 : 6.0;

      // Rotate detected wheel nodes
      wheelNodesRef.current.forEach((wheel) => {
        wheel.rotation.x += delta * rollSpeed;
      });
    }

    // Subtle chassis idle vibration
    if (groupRef.current) {
      groupRef.current.position.y = Math.sin(state.clock.getElapsedTime() * 4) * 0.008;
    }
  });

  return (
    <group ref={groupRef} position={[0, 0, 0]}>
      {/* Actual BMW 3D Model Instance (Normalized & Centered) */}
      <primitive object={clonedScene} />

      {/* ==================== SIGNATURE BMW GLOWING KIDNEY GRILLE ==================== */}
      <group position={[0, 0.55, 2.22]}>
        <mesh position={[-0.32, 0, 0]}>
          <boxGeometry args={[0.42, 0.32, 0.06]} />
          <meshStandardMaterial
            color={grilleGlowColor}
            emissive={grilleGlowColor}
            emissiveIntensity={headlightsOn ? 2.8 : 0.6}
          />
        </mesh>
        <mesh position={[0.32, 0, 0]}>
          <boxGeometry args={[0.42, 0.32, 0.06]} />
          <meshStandardMaterial
            color={grilleGlowColor}
            emissive={grilleGlowColor}
            emissiveIntensity={headlightsOn ? 2.8 : 0.6}
          />
        </mesh>
      </group>

      {/* ==================== VOLUMETRIC LASER HEADLIGHT BEAMS ==================== */}
      {headlightsOn && (
        <group position={[0, 0.55, 2.25]}>
          <mesh position={[-0.75, 0, 2.5]} rotation={[Math.PI / 2, 0, 0]} material={headlightShader}>
            <coneGeometry args={[0.8, 5.0, 32, 1, true]} />
          </mesh>
          <mesh position={[0.75, 0, 2.5]} rotation={[Math.PI / 2, 0, 0]} material={headlightShader}>
            <coneGeometry args={[0.8, 5.0, 32, 1, true]} />
          </mesh>
        </group>
      )}

      {/* Inner Electric Core for Hologram mode */}
      {isXRay && (
        <group position={[0, 0.4, 0]}>
          <mesh position={[0, -0.1, 0]}>
            <boxGeometry args={[1.5, 0.3, 2.4]} />
            <meshStandardMaterial color="#00ffff" emissive="#00aaaa" emissiveIntensity={0.8} wireframe />
          </mesh>
          <mesh position={[0, 0, 1.2]} rotation={[0, 0, Math.PI / 2]}>
            <cylinderGeometry args={[0.28, 0.28, 0.5, 16]} />
            <meshStandardMaterial color="#ff0055" emissive="#aa0033" emissiveIntensity={1.0} wireframe />
          </mesh>
        </group>
      )}
    </group>
  );
};

// Preload the GLTF asset for fast initial render
useGLTF.preload('/bmw.glb');
