import React, { Suspense } from 'react';
import { Canvas } from '@react-three/fiber';
import { Bloom, EffectComposer } from '@react-three/postprocessing';
import Experience from './Experience';

const Scene = () => {
    return (
        <Canvas
            camera={{ position: [0, 0, 5], fov: 75 }}
            style={{ background: 'transparent' }}
            dpr={[1, 2]}
        >
            <ambientLight intensity={0.5} />
            <pointLight position={[10, 10, 10]} intensity={1} color="#00f3ff" />
            <pointLight position={[-10, -10, -10]} intensity={0.5} color="#7000ff" />

            <Suspense fallback={null}>
                <Experience />
                <EffectComposer disableNormalPass>
                    <Bloom
                        luminanceThreshold={0.2}
                        mipmapBlur
                        intensity={1.5}
                        radius={0.4}
                    />
                </EffectComposer>
            </Suspense>
        </Canvas>
    );
};

export default Scene;
