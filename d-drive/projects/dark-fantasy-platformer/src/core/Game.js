import { Renderer } from './Renderer.js';
import { Input } from './Input.js';
import { Physics } from './Physics.js';
import { Player } from '../entities/Player.js';
import { Enemy } from '../entities/Enemy.js';
import { BoundEnemy } from '../entities/BoundEnemy.js';
import { Boss } from '../entities/Boss.js';
import { NPC } from '../entities/NPC.js';
import { Level } from '../level/Level.js';
import { AudioManager } from './AudioManager.js';

export class Game {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');

        this.renderer = new Renderer(this.ctx);
        this.input = new Input();
        this.physics = new Physics();
        this.audio = new AudioManager();

        this.lastTime = 0;
        this.isRunning = false;

        this.entities = [];
        this.level = new Level(this);

        // Initialize Player
        this.player = new Player(400, 400);
        this.entities.push(this.player);
        this.level.player = this.player;

        // Initialize entities
        this.entities.push(new Enemy(800, 400, 'whispered'));
        this.entities.push(new BoundEnemy(1200, 400));

        this.npc = new NPC(1800, 400);
        this.entities.push(this.npc);

        this.boss = new Boss(4500, 400);
        this.entities.push(this.boss);

        this.resize();
    }

    start() {
        this.isRunning = true;
        this.audio.playAmbient();
        requestAnimationFrame(this.loop.bind(this));
    }

    stop() {
        this.isRunning = false;
    }

    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
        this.renderer.resize(this.canvas.width, this.canvas.height);
    }

    loop(timestamp) {
        if (!this.isRunning) return;

        const deltaTime = (timestamp - this.lastTime) / 1000;
        this.lastTime = timestamp;

        // Cap deltaTime to avoid massive jumps on lag
        const dt = Math.min(deltaTime, 0.1);

        this.update(dt);
        this.draw();

        requestAnimationFrame(this.loop.bind(this));
    }

    update(dt) {
        // Update input state
        this.input.update();

        // Update entities
        for (const entity of this.entities) {
            entity.update(dt, this.input, this.physics, this.level);
        }

        // Handle interaction
        if (this.input.isPressed('KeyE')) {
            const dist = Math.abs(this.player.x - this.npc.x);
            if (dist < this.npc.interactionRange) {
                this.npc.interact();
            }
        }

        // Handle collisions
        this.physics.update(this.entities, this.level);

        // Audio state triggers
        if (this.player.x > 4000 && !this.bossChanting) {
            this.audio.playChant();
            this.bossChanting = true;
        }
    }

    draw() {
        this.renderer.updateCamera(this.player);
        this.renderer.clear();

        if (this.level) {
            this.renderer.drawLevel(this.level);
        }

        for (const entity of this.entities) {
            this.renderer.drawEntity(entity);
        }

        // Draw UI overlay
        this.drawUI();
    }

    drawUI() {
        // UI is partially handled by DOM, but can add canvas-based UI here if needed
    }
}
