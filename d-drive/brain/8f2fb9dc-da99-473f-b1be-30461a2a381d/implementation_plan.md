# Antigravity-Inspired Interactive Portfolio & Showreel Platform

Design and build an ultra-premium, futuristic developer portfolio inspired by the **Google Antigravity** official aesthetic. The portfolio combines deep-space cyberpunk visual design, dynamic WebGL particle physics, an interactive **Keynote Showreel & Presentation Mode** with video-like scrubbing, an interactive **Zero-G Physics Playground**, live project simulators, an embedded Antigravity CLI terminal, and procedural Web Audio soundscapes.

---

## 🌟 Core Inspirations & Key Features

1. **Antigravity Visual & Physics Universe**:
   - Deep obsidian space palette (`#06080e`, `#0a0e1a`, `#00f0ff`, `#7c3aed`, `#10b981`).
   - WebGL / Three.js quantum particle field with dynamic gravity well, mouse velocity attraction/repulsion, and focal bloom.
   - **Zero-Gravity Mode Toggle**: Flip the page into zero-g physics where project badges, tech shards, and cards float and can be tossed across the screen.

2. **Cinematic Keynote & Video Showreel Deck**:
   - An interactive, video-like presentation deck complete with play/pause, timeline scrubber, chapter navigation, dynamic slide animations, narration transcripts, and live interactive demo embeds.
   - Showcases the developer's core vision, distributed systems, mesh networks, game engines, and AI integrations.

3. **Interactive Project Nexus (With Live In-Card Simulators)**:
   - **MeshTalk Native**: Interactive decentralized node topology simulator (broadcast packets between offline nodes).
   - **Zedox Rarity Core**: Interactive live RNG roller and probability curve visualizer.
   - **Cloud Sentinel & Infra**: Live DDoS mitigation and server telemetry ping simulator.
   - 3D holographic tilt effects, live modal drill-downs, and source links.

4. **Embedded Antigravity CLI Terminal**:
   - Interactive terminal emulator supporting commands like `help`, `skills`, `projects`, `showreel`, `zerog`, `matrix`, `clear`, `contact`, and audio beeps.

5. **Procedural Web Audio Engine**:
   - Built-in lightweight sound synthesizer using Web Audio API for futuristic UI hover clicks, laser sweeps, gravity hums, and modal transitions (with instant mute/unmute control).

---

## User Review Required

> [!IMPORTANT]
> **Audio & Animation Intensity**: The portfolio will include ambient sound effects (Web Audio API) which default to muted or opt-in with a glowing audio visualizer button in the header.
>
> **Workspace**: We will upgrade the portfolio in `C:\Users\EI\.gemini\antigravity\scratch\zedox-portfolio` (or create a clean preview build in it).

---

## Proposed Changes

### Core & Styling
#### [MODIFY] [package.json](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/package.json)
- Ensure all necessary dependencies (`lucide-react`, `framer-motion`, `three`, `canvas-confetti`) are configured.

#### [MODIFY] [index.html](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/index.html)
- Add Google Fonts (Syne, Space Grotesk, JetBrains Mono, Inter), futuristic meta tags, page title, and favicon.

#### [MODIFY] [src/index.css](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/index.css)
- Implement comprehensive design system tokens (cyber dark backgrounds, neon accents, glowing glassmorphism, scanlines overlay, 3D card tilt styles, scrollbar styling, keyframes).

---

### Audio & Physics Systems
#### [NEW] [src/utils/audioEngine.js](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/utils/audioEngine.js)
- Zero-dependency procedural Web Audio API sound designer (ambient space hum, click ticks, laser sweeps, terminal keystroke beeps, zero-g whoosh).

#### [NEW] [src/components/ThreeBackground.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/ThreeBackground.jsx)
- Upgraded WebGL particle vortex with mouse gravity field, orbital rings, perspective depth, and responsive resizing.

#### [NEW] [src/components/ZeroGravitySandbox.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/ZeroGravitySandbox.jsx)
- Interactive canvas physics engine where badges and tech tokens float, bounce, collide, and react to drag and flick gestures.

---

### Key UI Components
#### [NEW] [src/components/Navbar.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/Navbar.jsx)
- Glassmorphic navigation header with live system telemetry status, Zero-G mode switcher, audio toggle visualizer, quick navigation, and hire/contact CTA.

#### [NEW] [src/components/HeroSection.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/HeroSection.jsx)
- Headline with glowing typography, live system metrics ticker, presentation trigger button, quick resume/spec download, and interactive floating badges.

#### [NEW] [src/components/ShowreelPresentation.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/ShowreelPresentation.jsx)
- The flagship Antigravity Keynote/Video Player:
  - 5 interactive slides/chapters with timeline scrubber, play/pause, next/prev slide controls, full-screen mode, and live interactive preview modules.

#### [NEW] [src/components/ProjectShowcase.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/ProjectShowcase.jsx)
- 3D tilt project cards featuring interactive mini-apps inside each card (Mesh network simulator, RNG rarity simulator, Edge DDoS monitor).

#### [NEW] [src/components/InteractiveTerminal.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/InteractiveTerminal.jsx)
- Cyberpunk CLI terminal emulator with command parser, syntax coloring, sound feedback, and hidden easter eggs.

#### [NEW] [src/components/SkillMatrix.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/SkillMatrix.jsx)
- Interactive node constellation & system capability grid (Systems / Mobile / Game Tech / Cloud & Security).

#### [NEW] [src/components/ExperienceTimeline.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/ExperienceTimeline.jsx)
- Mission log & milestone roadmap with interactive expandable nodes.

#### [NEW] [src/components/ContactSection.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/components/ContactSection.jsx)
- Transmission command console with interactive form submission, direct Discord, GitHub, and email channels.

#### [MODIFY] [src/App.jsx](file:///C:/Users/EI/.gemini/antigravity/scratch/zedox-portfolio/src/App.jsx)
- Main application shell coordinating audio engine, global zero-g state, showreel presentation modal/view, sections, and footer telemetry.

---

## Verification Plan

### Automated / Build Verification
- Run `npm run build` or `npm run dev` in `C:\Users\EI\.gemini\antigravity\scratch\zedox-portfolio` to verify zero compile or lint errors.

### Manual Verification
- Test all interactive features:
  1. Particle canvas mouse attraction and dynamic physics.
  2. Presentation showreel timeline scrubber, autoplay, and slide transitions.
  3. Live project interactive widgets (Mesh packet sender, RNG roll tester, Cloud ping tester).
  4. Terminal command execution (`help`, `projects`, `zerog`, `matrix`).
  5. Audio synthesizer toggle and sound effects on hover/clicks.
  6. Zero-G physics sandbox drag and fling interactions.
  7. Full responsiveness across mobile, tablet, and widescreen viewports.
