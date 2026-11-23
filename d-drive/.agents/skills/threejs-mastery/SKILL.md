---
name: threejs-mastery
description: >-
  Mastery skill for building 3D web applications, scene graphs, custom shaders, asset loading,
  postprocessing pipelines, and high-performance graphics using Three.js. Use when the user asks
  for Three.js scene creation, canvas setup, GLTF loading, lighting, particle engines, or WebGL rendering.
---

# Three.js Mastery Skill

Use this skill when building modern, high-performance 3D web experiences using **Three.js**.

---

## 1. Minimal Production Scene Setup Boilerplate

```typescript
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

export class ThreeScene {
  private container: HTMLElement;
  private scene: THREE.Scene;
  private camera: THREE.PerspectiveCamera;
  private renderer: THREE.WebGLRenderer;
  private controls: OrbitControls;
  private clock: THREE.Clock;
  private animationFrameId: number | null = null;

  constructor(container: HTMLElement) {
    this.container = container;
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x0f172a);
    this.clock = new THREE.Clock();

    // 1. Camera setup
    const width = container.clientWidth;
    const height = container.clientHeight;
    this.camera = new THREE.PerspectiveCamera(60, width / height, 0.1, 1000);
    this.camera.position.set(0, 5, 10);

    // 2. Renderer setup
    this.renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: 'high-performance' });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.2;
    this.container.appendChild(this.renderer.domElement);

    // 3. Controls
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.dampingFactor = 0.05;

    // 4. Lighting & Content
    this.setupLighting();
    this.setupMesh();

    // 5. Events & Render Loop
    window.addEventListener('resize', this.onResize);
    this.animate();
  }

  private setupLighting(): void {
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
    this.scene.add(ambientLight);

    const dirLight = new THREE.DirectionalLight(0xffffff, 1.5);
    dirLight.position.set(10, 20, 15);
    dirLight.castShadow = true;
    dirLight.shadow.mapSize.width = 2048;
    dirLight.shadow.mapSize.height = 2048;
    dirLight.shadow.camera.near = 0.5;
    dirLight.shadow.camera.far = 50;
    this.scene.add(dirLight);
  }

  private setupMesh(): void {
    const geometry = new THREE.BoxGeometry(2, 2, 2);
    const material = new THREE.MeshStandardMaterial({
      color: 0x3b82f6,
      roughness: 0.2,
      metalness: 0.8,
    });
    const cube = new THREE.Mesh(geometry, material);
    cube.castShadow = true;
    cube.receiveShadow = true;
    cube.name = 'mainCube';
    this.scene.add(cube);
  }

  private onResize = (): void => {
    const width = this.container.clientWidth;
    const height = this.container.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  };

  private animate = (): void => {
    this.animationFrameId = requestAnimationFrame(this.animate);
    const elapsedTime = this.clock.getElapsedTime();

    const cube = this.scene.getObjectByName('mainCube');
    if (cube) {
      cube.rotation.y = elapsedTime * 0.5;
      cube.rotation.x = elapsedTime * 0.25;
    }

    this.controls.update();
    this.renderer.render(this.scene, this.camera);
  };

  public dispose(): void {
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
    }
    window.removeEventListener('resize', this.onResize);
    this.controls.dispose();
    
    // Traversal cleanup
    this.scene.traverse((object) => {
      if (object instanceof THREE.Mesh) {
        object.geometry.dispose();
        if (Array.isArray(object.material)) {
          object.material.forEach((m) => m.dispose());
        } else if (object.material) {
          object.material.dispose();
        }
      }
    });

    this.renderer.dispose();
    if (this.renderer.domElement.parentElement) {
      this.renderer.domElement.parentElement.removeChild(this.renderer.domElement);
    }
  }
}
```

---

## 2. GLTF Model Loading with Draco Compression

```typescript
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';
import { DRACOLoader } from 'three/examples/jsm/loaders/DRACOLoader.js';

export function loadGLTFModel(scene: THREE.Scene, url: string): Promise<THREE.Group> {
  return new Promise((resolve, reject) => {
    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');

    const gltfLoader = new GLTFLoader();
    gltfLoader.setDRACOLoader(dracoLoader);

    gltfLoader.load(
      url,
      (gltf) => {
        const model = gltf.scene;
        model.traverse((child) => {
          if ((child as THREE.Mesh).isMesh) {
            child.castShadow = true;
            child.receiveShadow = true;
          }
        });
        scene.add(model);
        resolve(model);
      },
      (progress) => {
        console.log(`Loading progress: ${(progress.loaded / progress.total) * 100}%`);
      },
      (error) => reject(error)
    );
  });
}
```

---

## 3. High Performance Instanced Rendering (`InstancedMesh`)

Use `InstancedMesh` when rendering hundreds or thousands of identical objects in a single draw call:

```typescript
import * as THREE from 'three';

export function createInstancedForest(count: number = 1000): THREE.InstancedMesh {
  const geometry = new THREE.ConeGeometry(0.5, 2, 8);
  const material = new THREE.MeshStandardMaterial({ color: 0x22c55e, roughness: 0.8 });

  const instancedMesh = new THREE.InstancedMesh(geometry, material, count);
  const dummy = new THREE.Object3D();

  for (let i = 0; i < count; i++) {
    dummy.position.set(
      (Math.random() - 0.5) * 100,
      1,
      (Math.random() - 0.5) * 100
    );
    dummy.rotation.y = Math.random() * Math.PI;
    const scale = 0.5 + Math.random() * 1;
    dummy.scale.set(scale, scale, scale);
    dummy.updateMatrix();

    instancedMesh.setMatrixAt(i, dummy.matrix);
  }

  instancedMesh.instanceMatrix.needsUpdate = true;
  instancedMesh.castShadow = true;
  instancedMesh.receiveShadow = true;

  return instancedMesh;
}
```

---

## 4. Post-Processing Pipeline (`EffectComposer`)

```typescript
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js';
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js';
import { OutputPass } from 'three/examples/jsm/postprocessing/OutputPass.js';

export function createPostProcessing(
  renderer: THREE.WebGLRenderer,
  scene: THREE.Scene,
  camera: THREE.PerspectiveCamera
): EffectComposer {
  const composer = new EffectComposer(renderer);

  const renderPass = new RenderPass(scene, camera);
  composer.addPass(renderPass);

  const bloomPass = new UnrealBloomPass(
    new THREE.Vector2(window.innerWidth, window.innerHeight),
    0.8,  // Bloom strength
    0.4,  // Bloom radius
    0.85  // Bloom threshold
  );
  composer.addPass(bloomPass);

  const outputPass = new OutputPass();
  composer.addPass(outputPass);

  return composer;
}
```

---

## Key Best Practices Checklist

1. **Always cap pixel ratio**: `Math.min(window.devicePixelRatio, 2)`.
2. **Dispose geometries, materials, and textures** during scene unmounting to prevent VRAM memory leaks.
3. **Use ACESFilmicToneMapping** for realistic color management with PBR lighting.
4. **Use InstancedMesh** when instantiating repeating objects (>20 nodes).
5. **Optimize shadow map sizes**: 1024x1024 or 2048x2048 is usually sufficient; do not use 4096+ without necessity.
