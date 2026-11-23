# BMW M-Vision 3D Concept Experience Implementation Plan

Build a flagship, high-performance interactive 3D website for BMW highlighting advanced WebGL rendering, custom GLSL shaders, procedural 3D sports car model, interactive customization, drive modes, and cinematic camera controls.

---

## User Review Required

> [!IMPORTANT]
> The project will be created in `C:\Users\EI\.gemini\antigravity\scratch\bmw-3d-showcase`.
> Once created, you can set `C:\Users\EI\.gemini\antigravity\scratch\bmw-3d-showcase` as your active workspace.
>
> The web application will launch locally via Vite (`http://localhost:5173`) with live hot-reloading and instant 3D interactive controls.

---

## Proposed Features & Architecture

### 1. Interactive 3D BMW Concept Supercar (`Three.js` / `R3F`)
- **Detailed 3D Vehicle Architecture**: Sleek aerodynamic body, signature glowing LED Kidney Grille, quad headlights, carbon fiber diffuser, metallic alloy rims, high-gloss clearcoat paint, and brake discs.
- **PBR Material Pipeline**: Realistic metalness, roughness, clearcoat finish, and environment map reflections.
- **GLSL Shaders**:
  - *Headlight & Taillight Beams Shader*: Emissive volumetric light glow.
  - *Holographic X-Ray Shader*: Fresnel hologram effect revealing internal electric chassis & drivetrain structure.
  - *Cyber Grid Road Shader*: Procedural infinite floor grid with animated speed streaks and neon glow.
  - *Atmospheric Particles Shader*: Dynamic particle field reacting to drive modes.

### 2. Interactive Customizer & Drive Modes
- **Live Paint Studio**: Real-time switching between iconic BMW colors:
  - *Isle of Man Green*
  - *Marina Bay Blue*
  - *Toronto Red Metallic*
  - *Frozen Dark Grey (Matte)*
  - *Alpine White*
  - *São Paulo Yellow*
- **Drive Mode Selector**:
  - 🟢 **Comfort Mode**: Elegant studio lighting, clean floor reflections, smooth rotation.
  - 🔴 **Sport Mode**: Dynamic red lighting, speed particles, animated road grid.
  - ⚡ **M Track / Cyber Mode**: Neon lighting, holographic x-ray shader, active engine sound synthesis (Web Audio API).

### 3. Cinematic Camera System
- Preset interactive camera perspectives:
  - 🎥 **Cinematic Tour** (Auto-orbiting intro)
  - 🚗 **Front 3/4 View** (Highlights glowing kidney grille & quad headlights)
  - 🛞 **Wheel & Rim Detail** (Close-up metallic alloy rims)
  - 🏎️ **Rear Diffuser** (Quad exhaust & OLED taillights)
  - 🔍 **X-Ray Drivetrain View** (Reveals electric powertrain)

### 4. Futuristic Glassmorphic UI & Sound System
- **Specs & Performance HUD**:
  - 0-60 mph: 2.9 seconds
  - Power: 650 HP TwinPower Turbo V8 + Electric Motor
  - Top Speed: 190 mph (306 km/h)
  - Live RPM / Speedometer gauge & G-Force meter.
- **Web Audio Sound Effects**: Synthetic engine revs, mode switch clicks, and futuristic hums.

---

## Proposed File Structure (`C:\Users\EI\.gemini\antigravity\scratch\bmw-3d-showcase`)

```text
bmw-3d-showcase/
├── index.html
├── package.json
├── vite.config.ts
├── tailwind.config.js
├── postcss.config.js
├── src/
│   ├── main.tsx
│   ├── App.tsx
│   ├── index.css
│   ├── components/
│   │   ├── Canvas3D.tsx            # Main R3F Canvas & Scene Manager
│   │   ├── BmwCarModel.tsx         # Detailed 3D BMW Concept Car
│   │   ├── Shaders/
│   │   │   ├── HologramShader.ts   # Custom GLSL X-Ray Hologram Shader
│   │   │   ├── RoadGridShader.ts   # Animated Speed Grid Shader
│   │   │   └── HeadlightShader.ts  # Volumetric Light Beam Shader
│   │   ├── EnvironmentStudio.tsx  # Studio lighting, Ground, Reflections
│   │   ├── UI/
│   │   │   ├── Navbar.tsx          # BMW M Branding Header
│   │   │   ├── ColorPicker.tsx     # Exterior Paint Studio
│   │   │   ├── DriveModes.tsx      # Comfort / Sport / M Track modes
│   │   │   ├── CameraControls.tsx  # Preset View Angles
│   │   │   ├── SpecsHUD.tsx        # Performance telemetry overlay
│   │   │   └── SoundToggle.tsx     # Web Audio engine sound toggle
│   │   └── utils/
│   │       └── AudioSynth.ts       # Web Audio API procedural engine revs
```

---

## Verification & Execution Plan

### Automated Verification
1. Run `npm install` to set up Three.js, React Three Fiber, Drei, Lucide Icons, and Tailwind CSS.
2. Run `npm run build` to verify TypeScript compilation and bundle creation without errors.

### Manual Verification
1. Launch local dev server with `npm run dev`.
2. Test interactive 3D canvas orbiting, zoom, pan, and smooth camera transitions.
3. Test paint color swatches, X-Ray GLSL shader mode, drive modes, and audio synthesis.
