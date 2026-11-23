# WebGL & 3D Graphics Development Rules

When developing 3D web applications, games, or shader visualizers using **Three.js**, **React Three Fiber (R3F)**, **Babylon.js**, or custom **GLSL Shaders**, follow these mandatory guidelines and standards.

---

## 1. Memory Management & Asset Disposal (CRITICAL)

WebGL applications run inside browser contexts with finite VRAM. Unmanaged geometries, materials, textures, and render targets cause GPU memory leaks and tab crashes.

- **Explicit Cleanup**:
  - Always call `.dispose()` on geometries (`geometry.dispose()`), materials (`material.dispose()`), textures (`texture.dispose()`), and render targets (`renderTarget.dispose()`) when removed from the scene.
  - In React Three Fiber, cleanup is largely handled automatically for unmounted elements, but custom loaders, textures, or manual canvas targets must still be explicitly disposed in `useEffect` cleanup return functions.
- **Texture Compression**:
  - Use KTX2 / Basis Universal compressed texture formats (`.ktx2`) for production high-resolution textures to reduce GPU VRAM consumption by up to 75%.
- **Draco Compression**:
  - Compress 3D meshes using Draco format (`.gltf` / `.glb`) for faster bandwidth transfer and smaller model sizes.

---

## 2. Rendering Optimization & Draw Call Minimization

- **Instanced Rendering**:
  - For repeated 3D objects (trees, bullets, grass, particles, grid tiles), use `InstancedMesh` in Three.js/R3F or `ThinEngine` / `ThinInstances` in Babylon.js instead of individual mesh nodes.
- **Draw Call Auditing**:
  - Keep draw calls under 100 per frame whenever possible for mobile and standard web performance.
  - Merge static geometries using `BufferGeometryUtils.mergeGeometries` (Three.js) or `Mesh.MergeMeshes` (Babylon.js) when objects share materials.
- **Pixel Ratio Capping**:
  - Never set `devicePixelRatio` to uncapped `window.devicePixelRatio` on high-DPI (4K/Retina) screens. Always cap pixel ratio at `Math.min(window.devicePixelRatio, 2)`.

---

## 3. Custom GLSL Shader Guidelines

- **Precision Qualifiers**:
  - Standardize fragment shader precision: `precision mediump float;` (or `highp` when high position/depth accuracy is required).
- **Uniform Update Minimization**:
  - Avoid re-allocating GLSL uniforms per frame. Re-use existing matrix/vector uniform objects (`uniforms.uTime.value = clock.getElapsedTime()`).
- **Conditional Branching**:
  - Minimize heavy `if`/`else` branching inside Fragment Shaders across wide step ranges; use `step()`, `smoothstep()`, and `mix()` for smooth mathematical transitions.

---

## 4. Framework Scoping & Selection

- **Three.js**: Best for standalone visualizers, custom canvas setups, bespoke shaders, and lightweight modular rendering pipelines.
- **React Three Fiber**: Best for React-based UI integrations, componentized 3D scenes, stateful UI overlay overlays, declarative animation pipelines (`drei`, `@react-three/rapier`).
- **Babylon.js**: Best for full-featured web game engine projects, WebXR/VR/AR applications, PBR scene design with built-in GUI, Node Material Editor, and complex physics pipelines (Havok).
