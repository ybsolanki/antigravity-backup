---
name: babylonjs-mastery
description: >-
  Mastery skill for building high-performance 3D web engines, interactive games, architectural visualizers,
  PBR materials, WebXR/VR apps, and Havok physics simulations using Babylon.js. Use when the user asks for
  Babylon.js scene creation, ArcRotateCamera, Havok physics, PBRMaterial, Node Material, or Babylon GUI.
---

# Babylon.js Mastery Skill

Use this skill when building enterprise 3D web applications, web games, or WebXR experiences using **Babylon.js**.

---

## 1. Production Engine & Scene Boilerplate

```typescript
import {
  Engine,
  Scene,
  Vector3,
  Color3,
  Color4,
  ArcRotateCamera,
  HemisphericLight,
  DirectionalLight,
  MeshBuilder,
  PBRMaterial,
  ShadowGenerator,
} from '@babylonjs/core';
import '@babylonjs/loaders/glTF';

export class BabylonApp {
  private canvas: HTMLCanvasElement;
  private engine: Engine;
  private scene: Scene;

  constructor(canvas: HTMLCanvasElement) {
    this.canvas = canvas;

    // 1. Initialize Engine
    this.engine = new Engine(this.canvas, true, {
      preserveDrawingBuffer: true,
      stencil: true,
      disableWebGL2Support: false,
    });

    // 2. Create Scene
    this.scene = new Scene(this.engine);
    this.scene.clearColor = new Color4(0.06, 0.09, 0.16, 1.0);

    // 3. Setup Camera & Lights
    this.setupCamera();
    this.setupLighting();
    this.setupEnvironment();

    // 4. Start Render Loop & Resize Handling
    this.engine.runRenderLoop(() => {
      this.scene.render();
    });

    window.addEventListener('resize', this.onResize);
  }

  private setupCamera(): void {
    const camera = new ArcRotateCamera(
      'mainCamera',
      -Math.PI / 2,
      Math.PI / 3,
      10,
      new Vector3(0, 1, 0),
      this.scene
    );
    camera.attachControl(this.canvas, true);
    camera.lowerRadiusLimit = 2;
    camera.upperRadiusLimit = 50;
    camera.wheelPrecision = 50;
  }

  private setupLighting(): void {
    const ambientLight = new HemisphericLight('hemiLight', new Vector3(0, 1, 0), this.scene);
    ambientLight.intensity = 0.5;

    const dirLight = new DirectionalLight('dirLight', new Vector3(-1, -2, -1), this.scene);
    dirLight.position = new Vector3(10, 20, 10);
    dirLight.intensity = 1.5;

    // Shadows
    const shadowGenerator = new ShadowGenerator(2048, dirLight);
    shadowGenerator.useBlurExponentialShadowMap = true;
    shadowGenerator.blurKernel = 32;
  }

  private setupEnvironment(): void {
    // PBR Metallic Sphere
    const sphere = MeshBuilder.CreateSphere('pbrSphere', { diameter: 2, segments: 32 }, this.scene);
    sphere.position.y = 1;

    const pbrMat = new PBRMaterial('metallicPBR', this.scene);
    pbrMat.albedoColor = new Color3(0.2, 0.5, 0.9);
    pbrMat.metallic = 0.9;
    pbrMat.roughness = 0.1;
    sphere.material = pbrMat;

    // Ground Plane
    const ground = MeshBuilder.CreateGround('ground', { width: 20, height: 20 }, this.scene);
    ground.receiveShadows = true;
  }

  private onResize = (): void => {
    this.engine.resize();
  };

  public dispose(): void {
    window.removeEventListener('resize', this.onResize);
    this.scene.dispose();
    this.engine.dispose();
  }
}
```

---

## 2. Asset Loading with `SceneLoader`

```typescript
import { SceneLoader, Vector3 } from '@babylonjs/core';
import '@babylonjs/loaders/glTF';

export async function loadGLTFMesh(scene: Scene, rootUrl: string, fileName: string) {
  try {
    const result = await SceneLoader.ImportMeshAsync('', rootUrl, fileName, scene);
    const mainMesh = result.meshes[0];
    mainMesh.position = new Vector3(0, 0, 0);
    mainMesh.scaling = new Vector3(1, 1, 1);
    
    // Enable shadows on child meshes
    result.meshes.forEach((mesh) => {
      mesh.receiveShadows = true;
    });

    return result;
  } catch (error) {
    console.error('Failed to load Babylon GLTF asset:', error);
    throw error;
  }
}
```

---

## 3. Havok Physics V2 Setup (`HavokPlugin`)

```typescript
import { HavokPlugin, PhysicsAggregate, PhysicsShapeType, Vector3 } from '@babylonjs/core';
import HavokPhysics from '@babylonjs/havok';

export async function initPhysicsScene(scene: Scene) {
  // Load Havok WASM binary
  const havokInstance = await HavokPhysics();
  const havokPlugin = new HavokPlugin(true, havokInstance);
  scene.enablePhysics(new Vector3(0, -9.81, 0), havokPlugin);

  // Dynamic Sphere
  const sphere = MeshBuilder.CreateSphere('physicsSphere', { diameter: 1 }, scene);
  sphere.position.y = 5;
  const sphereAggregate = new PhysicsAggregate(
    sphere,
    PhysicsShapeType.SPHERE,
    { mass: 1, restitution: 0.75 },
    scene
  );

  // Static Floor
  const ground = MeshBuilder.CreateGround('physicsGround', { width: 10, height: 10 }, scene);
  const groundAggregate = new PhysicsAggregate(
    ground,
    PhysicsShapeType.BOX,
    { mass: 0, restitution: 0.5 },
    scene
  );
}
```

---

## 4. Babylon GUI (`AdvancedDynamicTexture`)

```typescript
import { AdvancedDynamicTexture, Button, Control } from '@babylonjs/gui';

export function createInteractiveUI(scene: Scene) {
  const guiTexture = AdvancedDynamicTexture.CreateFullscreenUI('UI', true, scene);

  const button = Button.CreateSimpleButton('btnStart', 'Start Simulation');
  button.width = '200px';
  button.height = '50px';
  button.color = 'white';
  button.cornerRadius = 10;
  button.background = '#2563eb';
  button.horizontalAlignment = Control.HORIZONTAL_ALIGNMENT_CENTER;
  button.verticalAlignment = Control.VERTICAL_ALIGNMENT_BOTTOM;
  button.top = '-40px';

  button.onPointerUpObservable.add(() => {
    alert('Simulation Started!');
  });

  guiTexture.addControl(button);
}
```

---

## Babylon.js Best Practices Checklist

1. Always import `@babylonjs/loaders/glTF` at entry files to auto-register GLTF parsing.
2. Call `engine.resize()` on container resize events.
3. Use `ThinInstances` for rendering massive repetitive meshes (>1,000 instances).
4. Use Havok Physics V2 (`@babylonjs/havok`) for realistic performance over legacy Cannon/Oimo plugins.
