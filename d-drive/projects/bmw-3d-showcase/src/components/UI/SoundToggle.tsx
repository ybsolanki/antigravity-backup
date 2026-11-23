import React from 'react';
import { Volume2, VolumeX } from 'lucide-react';

interface SoundToggleProps {
  soundEnabled: boolean;
  onToggleSound: () => void;
}

export const SoundToggle: React.FC<SoundToggleProps> = ({
  soundEnabled,
  onToggleSound,
}) => {
  return (
    <button
      onClick={onToggleSound}
      title={soundEnabled ? 'Mute Engine Audio' : 'Enable Engine Audio'}
      className={`glass-panel p-3 rounded-full transition-all duration-300 pointer-events-auto ${
        soundEnabled
          ? 'bg-cyan-500/20 text-cyan-300 border-cyan-400/50 glow-bmw-blue'
          : 'text-gray-400 hover:text-white hover:bg-white/10'
      }`}
    >
      {soundEnabled ? (
        <Volume2 className="w-5 h-5 animate-pulse" />
      ) : (
        <VolumeX className="w-5 h-5" />
      )}
    </button>
  );
};
