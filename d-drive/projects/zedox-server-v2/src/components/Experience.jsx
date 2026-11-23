import React, { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { Points, PointMaterial, MeshDistortMaterial } from '@react-three/drei';
import * as THREE from 'three';

const Experience = () => {
    const pointsRef = useRef();
    const meshRef = useRef();

    // Generate random points for the background particle field
    const particlesCount = 2000;
    const positions = new Float32Array(particlesCount * 3);
    for (let i = 0; i < particlesCount * 3; i++) {
        positions[i] = (Math.random() - 0.5) * 15;
    }

    useFrame((state) => {
        const t = state.clock.getElapsedTime();

        // Rotate particles slowly
        if (pointsRef.current) {
            pointsRef.current.rotation.y = t * 0.05;
            pointsRef.current.rotation.x = t * 0.02;
        }

        // Morphing central object
        if (meshRef.current) {
            meshRef.current.rotation.x = Math.cos(t / 4) / 4;
            meshRef.current.rotation.y = Math.sin(t / 4) / 4;
            meshRef.current.rotation.z = Math.sin(t / 4) / 4;

            // Mouse react
            meshRef.current.position.x = THREE.MathUtils.lerp(meshRef.current.position.x, state.mouse.x * 0.5, 0.1);
            meshRef.current.position.y = THREE.MathUtils.lerp(meshRef.current.position.y, state.mouse.y * 0.5, 0.1);
        }
    });

    return (
        <group>
            {/* Background Particles */}
            <points ref={pointsRef}>
                <bufferGeometry>
                    <bufferAttribute
                        attach="attributes-position"
                        count={particlesCount}
                        array={positions}
                        itemSize={3}
                    />
                </bufferGeometry>
                <pointsMaterial
                    size={0.02}
                    color="#00f3ff"
                    transparent
                    opacity={0.4}
                    sizeAttenutation={true}
                    blending={THREE.AdditiveBlending}
                />
            </points>

            {/* Central Immersive Mesh */}
            <mesh ref={meshRef} scale={1.5}>
                <icosahedronGeometry args={[1, 15]} />
                <MeshDistortMaterial
                    color="#050505"
                    emissive="#100030"
                    roughness={0.1}
                    metalness={1}
                    distort={0.4}
                    speed={2}
                />
            </mesh>

            {/* Glowing Aura Ring */}
            <mesh rotation={[Math.PI / 2, 0, 0]}>
                <torusGeometry args={[2.5, 0.005, 16, 100]} />
                <meshBasicMaterial color="#00f3ff" transparent opacity={0.2} />
            </mesh>
            <mesh rotation={[Math.PI / 4, 0, 0]}>
                <torusGeometry args={[2.8, 0.005, 16, 100]} />
                <meshBasicMaterial color="#7000ff" transparent opacity={0.1} />
            </mesh>
        </group>
    );
};

export default Experience;
