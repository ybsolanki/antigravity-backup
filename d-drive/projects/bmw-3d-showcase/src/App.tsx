import React, { useState } from 'react';
import { Canvas3D } from './components/Canvas3D';
import { Navbar } from './components/UI/Navbar';
import { ColorPicker } from './components/UI/ColorPicker';
import { DriveModes } from './components/UI/DriveModes';
import { CameraControls } from './components/UI/CameraControls';
import { SpecsHUD } from './components/UI/SpecsHUD';
import { SoundToggle } from './components/UI/SoundToggle';
import { engineAudio } from './utils/AudioSynth';

export default function App() {
  const [carColor, setCarColor] = useState('#0b3c8f'); // Marina Bay Blue
  const [isXRay, setIsXRay] = useState(false);
  const [headlightsOn, setHeadlightsOn] = useState(true);
  const [driveMode, setDriveMode] = useState<'comfort' | 'sport' | 'mtrack'>('sport');
  const [cameraView, setCameraView] = useState<'tour' | 'front' | 'rear' | 'wheel' | 'xray' | 'interior'>('tour');
  const [soundEnabled, setSoundEnabled] = useState(false);

  // State handlers with audio feedback
  const handleSelectColor = (color: string) => {
    setCarColor(color);
    engineAudio.playClickSound();
  };

  const handleToggleXRay = () => {
    const next = !isXRay;
    setIsXRay(next);
    if (next) setCameraView('xray');
    engineAudio.playClickSound();
  };

  const handleToggleHeadlights = () => {
    setHeadlightsOn(!headlightsOn);
    engineAudio.playClickSound();
  };

  const handleSelectDriveMode = (mode: 'comfort' | 'sport' | 'mtrack') => {
    setDriveMode(mode);
    engineAudio.setMode(mode);
    engineAudio.playClickSound();
  };

  const handleSelectCameraView = (view: any) => {
    setCameraView(view);
    if (view === 'xray') setIsXRay(true);
    engineAudio.playClickSound();
  };

  const handleToggleSound = () => {
    const isNowPlaying = engineAudio.toggleSound();
    setSoundEnabled(isNowPlaying);
  };

  const handleRevEngine = () => {
    if (!soundEnabled) {
      setSoundEnabled(true);
      engineAudio.toggleSound(true);
    }
    engineAudio.revEngine();
  };

  return (
    <main className="relative w-screen h-screen overflow-hidden bg-[#090C13]">
      {/* 3D WebGL Canvas Layer */}
      <Canvas3D
        carColor={carColor}
        isXRay={isXRay}
        headlightsOn={headlightsOn}
        driveMode={driveMode}
        cameraView={cameraView}
      />

      {/* UI Overlay Controls */}
      <Navbar
        headlightsOn={headlightsOn}
        onToggleHeadlights={handleToggleHeadlights}
        isXRay={isXRay}
        onToggleXRay={handleToggleXRay}
      />

      {/* Floating Left Telemetry HUD */}
      <aside className="absolute bottom-6 left-6 z-10 hidden md:block">
        <SpecsHUD driveMode={driveMode} onRevEngine={handleRevEngine} />
      </aside>

      {/* Floating Right Sound Control */}
      <aside className="absolute top-20 right-6 z-10">
        <SoundToggle soundEnabled={soundEnabled} onToggleSound={handleToggleSound} />
      </aside>

      {/* Bottom Center Studio & View Controls */}
      <section className="absolute bottom-6 left-1/2 -translate-x-1/2 z-10 flex flex-col md:flex-row items-center gap-3 max-w-[95vw]">
        {/* Drive Mode Selector */}
        <DriveModes currentMode={driveMode} onSelectMode={handleSelectDriveMode} />

        {/* Paint Studio Selector */}
        <ColorPicker currentColor={carColor} onSelectColor={handleSelectColor} />

        {/* Camera Views Selector */}
        <CameraControls currentView={cameraView} onSelectView={handleSelectCameraView} />
      </section>

      {/* Bottom Subtle Copyright / Info */}
      <footer className="absolute bottom-1 right-6 z-10 hidden lg:block text-[10px] font-mono text-gray-500 pointer-events-none">
        BMW M-VISION CONCEPT © 2026 // POWERED BY THREE.JS & R3F
      </footer>
    </main>
  );
}
