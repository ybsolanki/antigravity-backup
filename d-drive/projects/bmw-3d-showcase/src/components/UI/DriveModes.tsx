import React from 'react';
import { Shield, Flame, Gauge } from 'lucide-react';

interface DriveModesProps {
  currentMode: 'comfort' | 'sport' | 'mtrack';
  onSelectMode: (mode: 'comfort' | 'sport' | 'mtrack') => void;
}

export const DriveModes: React.FC<DriveModesProps> = ({
  currentMode,
  onSelectMode,
}) => {
  return (
    <div className="glass-panel p-2 rounded-2xl flex items-center gap-1.5">
      {/* COMFORT MODE */}
      <button
        onClick={() => onSelectMode('comfort')}
        className={`flex-1 px-4 py-2.5 rounded-xl text-xs font-bold transition-all duration-300 flex items-center justify-center gap-2 ${
          currentMode === 'comfort'
            ? 'bg-[#1C69D2] text-white shadow-lg glow-bmw-blue scale-[1.02]'
            : 'text-gray-400 hover:text-white hover:bg-white/5'
        }`}
      >
        <Shield className="w-4 h-4" />
        <span>COMFORT</span>
      </button>

      {/* SPORT MODE */}
      <button
        onClick={() => onSelectMode('sport')}
        className={`flex-1 px-4 py-2.5 rounded-xl text-xs font-bold transition-all duration-300 flex items-center justify-center gap-2 ${
          currentMode === 'sport'
            ? 'bg-[#E60000] text-white shadow-lg glow-bmw-red scale-[1.02]'
            : 'text-gray-400 hover:text-white hover:bg-white/5'
        }`}
      >
        <Flame className="w-4 h-4" />
        <span>SPORT</span>
      </button>

      {/* M TRACK MODE */}
      <button
        onClick={() => onSelectMode('mtrack')}
        className={`flex-1 px-4 py-2.5 rounded-xl text-xs font-bold transition-all duration-300 flex items-center justify-center gap-2 ${
          currentMode === 'mtrack'
            ? 'bg-gradient-to-r from-[#1C69D2] via-[#002663] to-[#E60000] text-white shadow-lg scale-[1.02] border border-cyan-400/50'
            : 'text-gray-400 hover:text-white hover:bg-white/5'
        }`}
      >
        <Gauge className="w-4 h-4 text-cyan-300" />
        <span>M TRACK</span>
      </button>
    </div>
  );
};
