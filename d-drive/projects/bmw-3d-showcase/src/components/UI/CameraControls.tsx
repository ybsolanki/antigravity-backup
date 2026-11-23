import React from 'react';
import { Camera, Eye, Disc, Cpu } from 'lucide-react';

interface CameraControlsProps {
  currentView: 'tour' | 'front' | 'rear' | 'wheel' | 'xray' | 'interior';
  onSelectView: (view: 'tour' | 'front' | 'rear' | 'wheel' | 'xray' | 'interior') => void;
}

const VIEWS = [
  { id: 'tour', label: '360° Tour', icon: Eye },
  { id: 'front', label: 'Kidney Grille', icon: Camera },
  { id: 'rear', label: 'Rear Diffuser', icon: Camera },
  { id: 'wheel', label: 'M Alloy Rim', icon: Disc },
  { id: 'xray', label: 'X-Ray Core', icon: Cpu },
] as const;

export const CameraControls: React.FC<CameraControlsProps> = ({
  currentView,
  onSelectView,
}) => {
  return (
    <div className="glass-panel p-2 rounded-2xl flex flex-wrap items-center justify-center gap-1.5">
      {VIEWS.map((v) => {
        const Icon = v.icon;
        const isSelected = currentView === v.id;
        return (
          <button
            key={v.id}
            onClick={() => onSelectView(v.id as any)}
            className={`px-3 py-1.5 rounded-xl text-xs font-medium transition-all duration-300 flex items-center gap-1.5 ${
              isSelected
                ? 'bg-white/20 text-cyan-300 border border-cyan-400/40 shadow'
                : 'text-gray-400 hover:text-white hover:bg-white/5'
            }`}
          >
            <Icon className="w-3.5 h-3.5" />
            <span>{v.label}</span>
          </button>
        );
      })}
    </div>
  );
};
