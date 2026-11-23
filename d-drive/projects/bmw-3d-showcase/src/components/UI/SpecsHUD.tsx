import React, { useState, useEffect } from 'react';
import { Gauge, Zap, Activity, Wind } from 'lucide-react';

interface SpecsHUDProps {
  driveMode: 'comfort' | 'sport' | 'mtrack';
  onRevEngine: () => void;
}

export const SpecsHUD: React.FC<SpecsHUDProps> = ({ driveMode, onRevEngine }) => {
  const [speed, setSpeed] = useState(0);
  const [rpm, setRpm] = useState(1200);

  // Dynamic simulated telemetry values depending on drive mode
  useEffect(() => {
    const targetSpeed = driveMode === 'mtrack' ? 186 : driveMode === 'sport' ? 120 : 65;
    const targetRpm = driveMode === 'mtrack' ? 7200 : driveMode === 'sport' ? 4800 : 2200;

    const interval = setInterval(() => {
      setSpeed((prev) => Math.min(targetSpeed, Math.max(0, prev + (targetSpeed - prev) * 0.1)));
      setRpm((prev) => Math.min(targetRpm, Math.max(1000, prev + (targetRpm - prev) * 0.1)));
    }, 50);

    return () => clearInterval(interval);
  }, [driveMode]);

  return (
    <div className="glass-panel p-4 rounded-2xl flex flex-col gap-3 min-w-[240px]">
      {/* Telemetry Header */}
      <div className="flex items-center justify-between border-b border-white/10 pb-2">
        <span className="text-[11px] font-mono text-gray-400 uppercase tracking-widest flex items-center gap-1.5">
          <Activity className="w-3.5 h-3.5 text-cyan-400 animate-pulse" />
          TELEMETRY HUD
        </span>
        <span className="text-[10px] font-mono text-emerald-400 px-2 py-0.5 rounded bg-emerald-500/10 border border-emerald-500/20">
          LIVE
        </span>
      </div>

      {/* Speedometer & RPM metrics */}
      <div className="flex items-baseline justify-between">
        <div>
          <div className="text-3xl font-black font-orbitron text-white text-glow-blue tracking-tight">
            {Math.round(speed)}
          </div>
          <div className="text-[10px] font-mono text-gray-400 uppercase">MPH SPEED</div>
        </div>
        <div className="text-right">
          <div className="text-xl font-bold font-orbitron text-cyan-300">
            {Math.round(rpm)}
          </div>
          <div className="text-[10px] font-mono text-gray-400 uppercase">RPM TACHO</div>
        </div>
      </div>

      {/* Performance Highlights grid */}
      <div className="grid grid-cols-2 gap-2 text-xs font-mono pt-1">
        <div className="glass-card p-2 rounded-lg border border-white/5">
          <div className="text-[10px] text-gray-400 flex items-center gap-1">
            <Zap className="w-3 h-3 text-amber-400" />
            <span>0-60 MPH</span>
          </div>
          <div className="font-bold text-white font-orbitron text-sm">2.9 s</div>
        </div>

        <div className="glass-card p-2 rounded-lg border border-white/5">
          <div className="text-[10px] text-gray-400 flex items-center gap-1">
            <Wind className="w-3 h-3 text-cyan-400" />
            <span>HORSEPOWER</span>
          </div>
          <div className="font-bold text-white font-orbitron text-sm">650 HP</div>
        </div>
      </div>

      {/* Rev Engine Action Button */}
      <button
        onClick={onRevEngine}
        className="mt-1 w-full py-2 rounded-xl bg-gradient-to-r from-[#1C69D2] to-[#E60000] hover:from-[#1C69D2]/90 hover:to-[#E60000]/90 text-white font-orbitron text-xs font-bold tracking-wider transition-all duration-200 active:scale-95 shadow-md flex items-center justify-center gap-2"
      >
        <Gauge className="w-4 h-4" />
        <span>REV ENGINE</span>
      </button>
    </div>
  );
};
