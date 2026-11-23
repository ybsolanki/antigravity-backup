import React from 'react';
import { Zap, Sparkles, Activity } from 'lucide-react';

interface NavbarProps {
  headlightsOn: boolean;
  onToggleHeadlights: () => void;
  isXRay: boolean;
  onToggleXRay: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({
  headlightsOn,
  onToggleHeadlights,
  isXRay,
  onToggleXRay,
}) => {
  return (
    <header className="absolute top-0 left-0 right-0 z-20 px-6 py-4 flex items-center justify-between pointer-events-none">
      {/* BMW M Brand Logo */}
      <div className="flex items-center gap-3 pointer-events-auto">
        <div className="flex items-center gap-1">
          {/* Tri-color M stripes */}
          <div className="w-1.5 h-6 bg-[#1C69D2] -skew-x-12"></div>
          <div className="w-1.5 h-6 bg-[#002663] -skew-x-12"></div>
          <div className="w-1.5 h-6 bg-[#E60000] -skew-x-12"></div>
        </div>
        <div>
          <h1 className="text-xl font-bold font-orbitron tracking-wider text-white flex items-center gap-2">
            BMW <span className="text-[#1C69D2]">M4 COMPETITION</span>
          </h1>
          <p className="text-[10px] text-cyan-400 tracking-widest uppercase font-mono flex items-center gap-1">
            <Activity className="w-3 h-3 text-cyan-400 animate-pulse" />
            NEXT-GEN WEBGL 3D SHOWCASE
          </p>
        </div>
      </div>

      {/* Top Action Quick Buttons */}
      <div className="flex items-center gap-3 pointer-events-auto">
        {/* Headlight Toggle */}
        <button
          onClick={onToggleHeadlights}
          className={`glass-panel px-4 py-2 rounded-xl text-xs font-semibold flex items-center gap-2 transition-all duration-300 ${
            headlightsOn
              ? 'bg-[#1C69D2]/30 text-cyan-300 border-cyan-400/50 glow-bmw-blue scale-[1.02]'
              : 'text-gray-300 hover:text-white hover:bg-white/10'
          }`}
        >
          <Zap className={`w-4 h-4 ${headlightsOn ? 'fill-cyan-300' : ''}`} />
          <span>LASER LIGHTS {headlightsOn ? 'ON' : 'OFF'}</span>
        </button>

        {/* X-Ray Hologram Toggle */}
        <button
          onClick={onToggleXRay}
          className={`glass-panel px-4 py-2 rounded-xl text-xs font-semibold flex items-center gap-2 transition-all duration-300 ${
            isXRay
              ? 'bg-cyan-500/40 text-cyan-300 border-cyan-400 glow-bmw-blue ring-2 ring-cyan-400/50 scale-[1.02]'
              : 'text-gray-300 hover:text-white hover:bg-white/10'
          }`}
        >
          <Sparkles className={`w-4 h-4 ${isXRay ? 'animate-spin text-cyan-300' : ''}`} />
          <span>HOLOGRAM X-RAY {isXRay ? '[ACTIVE]' : '[OFF]'}</span>
        </button>
      </div>
    </header>
  );
};
