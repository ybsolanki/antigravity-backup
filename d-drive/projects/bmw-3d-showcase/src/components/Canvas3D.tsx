import React, { useRef, Suspense } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, Html } from '@react-three/drei';
import * as THREE from 'three';
import { BmwCarModel } from './BmwCarModel';
import { EnvironmentStudio } from './EnvironmentStudio';

interface Canvas3DProps {
  carColor: string;
  isXRay: boolean;
  headlightsOn: boolean;
  driveMode: 'comfort' | 'sport' | 'mtrack';
  cameraView: 'tour' | 'front' | 'rear' | 'wheel' | 'xray' | 'interior';
}

const CAMERA_POSITIONS: Record<string, [number, number, number]> = {
  tour: [7.2, 2.8, 9.2],
  front: [0, 1.5, 7.2],
  rear: [0, 1.5, -7.2],
  wheel: [-3.4, 0.9, 1.8],
  xray: [5.8, 3.2, 5.8],
  interior: [0, 1.15, 0.2],
};

const CAMERA_TARGETS: Record<string, [number, number, number]> = {
  tour: [0, 0.5, 0],
  front: [0, 0.5, 1.8],
  rear: [0, 0.5, -1.8],
  wheel: [-1.0, 0.35, 1.45],
  xray: [0, 0.4, 0],
  interior: [0, 0.6, -0.2],
};

// Sub-component to smoothly interpolate camera position & controls target
function CameraRig({ cameraView }: { cameraView: string }) {
  const controlsRef = useRef<any>(null!);

  useFrame((state, delta) => {
    const targetPos = CAMERA_POSITIONS[cameraView] || CAMERA_POSITIONS.tour;
    const targetLookAt = CAMERA_TARGETS[cameraView] || CAMERA_TARGETS.tour;

    // Interpolate camera position towards preset target when NOT manually dragging
    if (cameraView !== 'tour') {
      state.camera.position.lerp(new THREE.Vector3(...targetPos), delta * 3.5);
    }

    if (controlsRef.current) {
      controlsRef.current.target.lerp(new THREE.Vector3(...targetLookAt), delta * 3.5);
      controlsRef.current.update();
    }
  });

  return (
    <OrbitControls
      ref={controlsRef}
      makeDefault
      enableDamping
      dampingFactor={0.05}
      minDistance={2.5}
      maxDistance={22.0}
      maxPolarAngle={Math.PI / 2 + 0.05} // Don't clip under ground
      autoRotate={cameraView === 'tour'}
      autoRotateSpeed={1.6}
    />
  );
}

// 3D Canvas Suspense Loading Indicator
function CanvasLoader() {
  return (
    <Html center>
      <div className="flex flex-col items-center gap-3 bg-slate-900/90 backdrop-blur-md p-6 rounded-2xl border border-cyan-500/30 text-white min-w-[240px] shadow-2xl">
        <div className="w-10 h-10 border-4 border-cyan-500/30 border-t-cyan-400 rounded-full animate-spin" />
        <div className="text-center font-orbitron">
          <div className="text-sm font-bold text-cyan-300">LOADING BMW M4 3D ASSET</div>
          <div className="text-[10px] text-gray-400 font-mono mt-1">HIGH-POLY GLTF MODEL</div>
        </div>
      </div>
    </Html>
  );
}

export const Canvas3D: React.FC<Canvas3DProps> = ({
  carColor,
  isXRay,
  headlightsOn,
  driveMode,
  cameraView,
}) => {
  return (
    <div className="w-full h-full absolute inset-0">
      <Canvas
        shadows
        dpr={[1, 2]}
        camera={{ position: [7.2, 2.8, 9.2], fov: 42 }}
        gl={{ antialias: true, powerPreference: 'high-performance' }}
      >
        <CameraRig cameraView={cameraView} />
        
        <EnvironmentStudio driveMode={driveMode} />

        <Suspense fallback={<CanvasLoader />}>
          <BmwCarModel
            carColor={carColor}
            isXRay={isXRay}
            headlightsOn={headlightsOn}
            driveMode={driveMode}
          />
        </Suspense>
      </Canvas>
    </div>
  );
};
