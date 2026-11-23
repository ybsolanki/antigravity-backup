import React from 'react';
import { Palette } from 'lucide-react';

interface ColorPickerProps {
  currentColor: string;
  onSelectColor: (colorHex: string) => void;
}

const BMW_COLORS = [
  { name: 'Isle of Man Green', hex: '#054e38' },
  { name: 'Marina Bay Blue', hex: '#0b3c8f' },
  { name: 'Toronto Red', hex: '#b91c1c' },
  { name: 'Frozen Dark Grey', hex: '#27272a' },
  { name: 'Alpine White', hex: '#f8fafc' },
  { name: 'São Paulo Yellow', hex: '#ca8a04' },
];

export const ColorPicker: React.FC<ColorPickerProps> = ({
  currentColor,
  onSelectColor,
}) => {
  return (
    <div className="glass-panel p-4 rounded-2xl flex flex-col gap-3">
      <div className="flex items-center gap-2 text-xs font-semibold text-gray-300 uppercase tracking-wider">
        <Palette className="w-3.5 h-3.5 text-[#1C69D2]" />
        <span>M Exterior Paint Studio</span>
      </div>

      <div className="grid grid-cols-6 gap-2">
        {BMW_COLORS.map((color) => {
          const isSelected = currentColor.toLowerCase() === color.hex.toLowerCase();
          return (
            <button
              key={color.name}
              onClick={() => onSelectColor(color.hex)}
              title={color.name}
              className={`w-9 h-9 rounded-full transition-all duration-300 relative flex items-center justify-center ${
                isSelected
                  ? 'ring-2 ring-white ring-offset-2 ring-offset-[#090C13] scale-110'
                  : 'hover:scale-105 opacity-80 hover:opacity-100'
              }`}
              style={{ backgroundColor: color.hex }}
            >
              {isSelected && (
                <div className="w-2 h-2 rounded-full bg-white shadow" />
              )}
            </button>
          );
        })}
      </div>
    </div>
  );
};
