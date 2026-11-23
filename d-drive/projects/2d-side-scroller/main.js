const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');
const healthBar = document.getElementById('health-bar');
const dialogueBox = document.getElementById('dialogue-box') || createDialogueBox();

function createDialogueBox() {
    const div = document.createElement('div');
    div.id = 'dialogue-box';
    div.style.position = 'fixed';
    div.style.bottom = '15%';
    div.style.left = '50%';
    div.style.transform = 'translateX(-50%)';
    div.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
    div.style.color = '#d4af37';
    div.style.padding = '20px 40px';
    div.style.fontFamily = "'Outfit', sans-serif";
    div.style.fontSize = '18px';
    div.style.border = '1px solid #d4af37';
    div.style.display = 'none';
    div.style.textAlign = 'center';
    div.style.maxWidth = '80%';
    div.style.zIndex = '1000';
    document.body.appendChild(div);
    return div;
}

canvas.width = window.innerWidth;
canvas.height = window.innerHeight;

window.addEventListener('resize', () => {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
});

const CONFIG = {
    GRAVITY: 0.8,
    FRICTION: 0.85,
    ACCEL: 0.5,
    MAX_SPEED: 5,
    JUMP_FORCE: -15,
    MAX_HEALTH: 100,
    ATTACK_DELAY: 300,
    HIT_RECOVERY: 200,
    WHIFF_RECOVERY: 600,
    ROLL_COOLDOWN: 400,
    ROLL_SPEED: 14,
    ROLL_DURATION: 250,
    INVULNERABILITY_DURATION: 300,
    ENEMY_MAX_HEALTH: 150,
    ENEMY_SPEED: 1.5,
    BOSS_MAX_HEALTH: 1000,
    CAMERA_LERP: 0.08,
    MAX_SHAKE: 15,
    NORMAL_ZOOM: 0.8,
    COMBAT_ZOOM: 1.0,
    HIT_STOP_DURATION: 120,
    ASH_COUNT: 100
};

const PALETTE = {
    SKY: '#0d0d10',
    ASH: 'rgba(150, 150, 160, 0.2)',
    STONE_DARK: '#1a1a20',
    STONE_LIGHT: '#363645',
    ACCENT: '#d4af37',
    PLAYER: '#e0e0e0',
    ENEMY: '#2e004a',
    BOSS: '#4e0000'
};

// WORLD STRUCTURE: COORDINATE-BASED HUB & SPOKE
const WORLD = {
    HUB: { x: 0, y: 0, w: 1000, h: 600, name: "The Sunken Plaza" },
    R1: { x: 1500, y: 0, w: 1200, h: 400, name: "Ash-Choked Gardens (East)" },
    R2: { x: -1500, y: -400, w: 1200, h: 800, name: "Well of Shadows (West)" },
    R3: { x: 0, y: -1500, w: 800, h: 1200, name: "Bell-Ringer's Tower (North)" },
    R4: { x: 0, y: 1200, w: 1200, h: 600, name: "The Deep Vault (South)" }
};

const PLATFORMS = [
    // --- CENTRAL HUB ---
    { x: WORLD.HUB.x, y: WORLD.HUB.y + 500, width: WORLD.HUB.w, height: 100, type: 'SOLID' }, // Floor
    { x: WORLD.HUB.x, y: WORLD.HUB.y, width: 50, height: 500, type: 'SOLID' }, // West wall
    { x: WORLD.HUB.x + WORLD.HUB.w - 50, y: WORLD.HUB.y, width: 50, height: 500, type: 'SOLID' }, // East wall
    { x: 200, y: 350, width: 200, height: 30, type: 'PLATFORM' },
    { x: 600, y: 200, width: 200, height: 30, type: 'PLATFORM' },
    { x: 450, y: 480, width: 100, height: 20, type: 'CHECKPOINT' }, // Spawn Point

    // --- REGION 1: EAST (ASH GARDENS) ---
    { x: WORLD.HUB.x + 950, y: WORLD.HUB.y + 400, width: 300, height: 100, type: 'SOLID' }, // Connector passage
    { x: WORLD.R1.x, y: WORLD.R1.y + 400, width: WORLD.R1.w, height: 100, type: 'SOLID' }, // Ground
    { x: WORLD.R1.x + 1100, y: -500, width: 100, height: 1000, type: 'SOLID' }, // Far east wall
    { x: WORLD.R1.x + 400, y: WORLD.R1.y + 370, width: 50, height: 30, type: 'UPGRADE', ability: 'WallClamber', text: "Grained: Wall Clamber" },
    // Shortcut Elev: Hidden platform at end of R1 that takes you to Hub upper balcony
    { x: WORLD.R1.x + 1000, y: 150, width: 100, height: 20, type: 'PLATFORM', name: 'Shortcut 1' },
    { x: WORLD.HUB.x + 800, y: 50, width: 200, height: 20, type: 'PLATFORM' }, // Upper balcony

    // --- REGION 2: WEST (SHADOW WELL) ---
    // Requires Wall Clamber to get high enough on the Hub west wall
    { x: WORLD.HUB.x - 500, y: WORLD.HUB.y + 100, width: 500, height: 50, type: 'SOLID', lock: 'WallClamber' },
    { x: WORLD.R2.x, y: WORLD.R2.y + 600, width: WORLD.R2.w, height: 80, type: 'SOLID' }, // Floor
    { x: WORLD.R2.x + 100, y: WORLD.R2.y + 100, width: 40, height: 40, type: 'UPGRADE', ability: 'DoubleJump', text: "Gained: Double Jump" },
    // Shortcut: Hole in the floor
    { x: WORLD.R2.x + 1100, y: WORLD.R2.y + 600, width: 100, height: 500, type: 'PASSAGE' }, // Drops to Hub West

    // --- REGION 3: NORTH (TOWER) ---
    // Requires Double Jump to reach the high rafters
    { x: WORLD.HUB.x + 400, y: WORLD.HUB.y - 400, width: 200, height: 50, type: 'SOLID', lock: 'DoubleJump' },
    { x: WORLD.R3.x, y: WORLD.R3.y, width: 800, height: 50, type: 'SOLID' }, // Top of tower
    { x: WORLD.R3.x + 350, y: WORLD.R3.y - 50, width: 100, height: 100, type: 'UPGRADE', ability: 'MasterKey', text: "Found: Master Key" },
    // Shortcut: Leap of faith
    { x: WORLD.R3.x - 300, y: WORLD.R3.y + 500, width: 500, height: 50, type: 'PLATFORM' },

    // --- REGION 4: SOUTH (VAULT) ---
    // Requires Master Key for the trapdoor at (500, 500)
    { x: 450, y: 500, width: 100, height: 20, type: 'SOLID', lock: 'MasterKey' },
    { x: WORLD.R4.x, y: WORLD.R4.y + 500, width: WORLD.R4.w, height: 100, type: 'SOLID' }, // Vault Floor
    { x: WORLD.R4.x + 500, y: WORLD.R4.y + 400, width: 150, height: 20, type: 'BOSS_REWARD', text: "The Deepest Secret" }
];

let globalHitStop = 0;
let isBossDefeated = false;

class AudioEngine {
    constructor() { this.ctx = null; }
    init() {
        if (!this.ctx) {
            this.ctx = new (window.AudioContext || window.webkitAudioContext)();
            this.masterGain = this.ctx.createGain(); this.masterGain.gain.value = 0.3;
            this.masterGain.connect(this.ctx.destination);
        }
    }
    resume() { this.init(); if (this.ctx.state === 'suspended') this.ctx.resume(); }
    playFootstep() {
        if (!this.ctx) return;
        const osc = this.ctx.createOscillator(); const noise = this.ctx.createGain();
        osc.type = 'triangle'; osc.frequency.setValueAtTime(60, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(10, this.ctx.currentTime + 0.1);
        noise.gain.setValueAtTime(0.2, this.ctx.currentTime);
        noise.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.1);
        osc.connect(noise); noise.connect(this.masterGain);
        osc.start(); osc.stop(this.ctx.currentTime + 0.1);
    }
    playSwing(isHeavy = false) {
        if (!this.ctx) return;
        const osc = this.ctx.createOscillator(); const noise = this.ctx.createGain();
        osc.type = 'sine'; osc.frequency.setValueAtTime(isHeavy ? 100 : 200, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(50, this.ctx.currentTime + 0.3);
        noise.gain.setValueAtTime(0.1, this.ctx.currentTime);
        noise.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.3);
        osc.connect(noise); noise.connect(this.masterGain);
        osc.start(); osc.stop(this.ctx.currentTime + 0.3);
    }
    playImpact() {
        if (!this.ctx) return;
        const osc = this.ctx.createOscillator(); const noise = this.ctx.createGain();
        osc.type = 'sawtooth'; osc.frequency.setValueAtTime(100, this.ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(40, this.ctx.currentTime + 0.2);
        noise.gain.setValueAtTime(0.3, this.ctx.currentTime);
        noise.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.2);
        osc.connect(noise); noise.connect(this.masterGain);
        osc.start(); osc.stop(this.ctx.currentTime + 0.2);
    }
}

const audio = new AudioEngine();

class Ash {
    constructor() { this.reset(); this.y = Math.random() * canvas.height; }
    reset() {
        this.x = Math.random() * canvas.width; this.y = -20;
        this.vx = (Math.random() - 0.5) * 1; this.vy = 1 + Math.random() * 2; this.size = 1 + Math.random() * 2;
    }
    update() { this.x += this.vx; this.y += this.vy; if (this.y > canvas.height) this.reset(); }
    draw() { ctx.fillStyle = PALETTE.ASH; ctx.fillRect(this.x, this.y, this.size, this.size); }
}

const ashParticles = Array.from({ length: CONFIG.ASH_COUNT }, () => new Ash());

class Camera {
    constructor() {
        this.x = 0; this.y = 0;
        this.zoom = CONFIG.NORMAL_ZOOM; this.targetZoom = CONFIG.NORMAL_ZOOM;
        this.shakeAmount = 0; this.shakeDecay = 0.9;
    }
    update(target, isCombat) {
        const targetX = target.x + target.width / 2 - canvas.width / (2 * this.zoom);
        const targetY = target.y + target.height / 2 - canvas.height / (2 * this.zoom);
        this.x += (targetX - this.x) * CONFIG.CAMERA_LERP;
        this.y += (targetY - this.y) * CONFIG.CAMERA_LERP;
        this.targetZoom = isCombat ? CONFIG.COMBAT_ZOOM : CONFIG.NORMAL_ZOOM;
        this.zoom += (this.targetZoom - this.zoom) * 0.05;
        if (this.shakeAmount > 0.1) this.shakeAmount *= this.shakeDecay; else this.shakeAmount = 0;
    }
    shake(amount) { this.shakeAmount = Math.min(this.shakeAmount + amount, CONFIG.MAX_SHAKE); }
    apply(ctx) {
        ctx.save();
        const shakeX = (Math.random() - 0.5) * 2 * this.shakeAmount;
        const shakeY = (Math.random() - 0.5) * 2 * this.shakeAmount;
        ctx.translate(canvas.width / 2 + shakeX, canvas.height / 2 + shakeY);
        ctx.scale(this.zoom, this.zoom);
        ctx.translate(-canvas.width / 2 - this.x, -canvas.height / 2 - this.y);
    }
    restore(ctx) { ctx.restore(); }
}

class Player {
    constructor() {
        this.width = 40; this.height = 70;
        this.spawnPoint = { x: 500, y: 400 };
        this.respawn();
        this.vx = 0; this.vy = 0; this.isGrounded = false;
        this.health = CONFIG.MAX_HEALTH; this.direction = 1;
        this.isAttacking = false; this.isRecovering = false;
        this.isRolling = false; this.canRoll = true;
        this.isInvulnerable = false; this.color = PALETTE.PLAYER;
        this.abilities = { WallClamber: false, DoubleJump: false, MasterKey: false };
        this.jumpCount = 0;
        this.rollHistory = [];
    }
    respawn() { this.x = this.spawnPoint.x; this.y = this.spawnPoint.y; this.health = CONFIG.MAX_HEALTH; this.vx = 0; this.vy = 0; }
    update(keys, enemies, camera, npcs, interactables) {
        if (this.health <= 0) { this.color = '#333'; setTimeout(() => this.respawn(), 2000); return; }

        const canMove = !this.isRolling && !this.isAttacking && !this.isRecovering;
        if (canMove) {
            if (keys.arrowleft || keys.a) { this.vx -= CONFIG.ACCEL; this.direction = -1; }
            else if (keys.arrowright || keys.d) { this.vx += CONFIG.ACCEL; this.direction = 1; }
            else this.vx *= CONFIG.FRICTION;
            this.vx = Math.max(-CONFIG.MAX_SPEED, Math.min(CONFIG.MAX_SPEED, this.vx));
        }

        // Jump & Double Jump
        if (keys.space_pressed && canMove) {
            const maxJumps = this.abilities.DoubleJump ? 2 : 1;
            if (this.isGrounded) {
                this.vy = CONFIG.JUMP_FORCE; this.isGrounded = false; this.jumpCount = 1; audio.playFootstep();
            } else if (this.jumpCount < maxJumps) {
                this.vy = CONFIG.JUMP_FORCE * 0.9; this.jumpCount++; audio.playFootstep();
            }
            keys.space_pressed = false;
        }

        // Wall Clamber (Simplified hold against wall)
        if (this.abilities.WallClamber && !this.isGrounded && Math.abs(this.vx) > 0.1) {
            // Check for wall collision
            for (const obj of PLATFORMS) {
                if (obj.type === 'SOLID' && this.checkCollision(this, obj)) {
                    if (this.vy > 0) this.vy *= 0.5; // Slide slow
                    if (keys.space_pressed) { this.vy = CONFIG.JUMP_FORCE; this.vx = -this.direction * 5; keys.space_pressed = false; }
                }
            }
        }

        if ((keys.j || keys.mouse0) && !this.isAttacking && !this.isRecovering && !this.isRolling) this.startAttack(enemies, camera);
        if ((keys.k || keys.shift) && !this.isRolling && this.canRoll && canMove) this.startRoll();

        if (keys.e) {
            npcs.forEach(npc => npc.interact(this));
            interactables.forEach(obj => obj.interact(this));
        } else { dialogueBox.style.display = 'none'; }

        this.vy += CONFIG.GRAVITY; this.x += this.vx; this.y += this.vy;
        this.handlePhysicsCollisions();
        this.updateVisuals();
    }
    handlePhysicsCollisions() {
        const wasGrounded = this.isGrounded;
        this.isGrounded = false;
        for (const obj of PLATFORMS) {
            // Check for ability locks
            if (obj.lock && !this.abilities[obj.lock]) {
                if (this.checkCollision(this, obj)) {
                    // Treat as solid blocker
                } else continue;
            }

            if (obj.type === 'CHECKPOINT') {
                if (this.checkCollision(this, obj)) { this.spawnPoint = { x: obj.x + obj.width / 2, y: obj.y - this.height }; obj.active = true; }
                continue;
            }
            if (obj.type === 'UPGRADE') {
                if (this.checkCollision(this, obj) && !this.abilities[obj.ability]) {
                    this.abilities[obj.ability] = true;
                    dialogueBox.innerText = obj.text; dialogueBox.style.display = 'block';
                }
                continue;
            }
            if (obj.type === 'PLATFORM') {
                if (this.vy >= 0 && this.y + this.height <= obj.y + 10 && this.y + this.height + this.vy >= obj.y &&
                    this.x + this.width > obj.x && this.x < obj.x + obj.width) {
                    this.y = obj.y - this.height; this.vy = 0; this.isGrounded = true; this.jumpCount = 0;
                }
                continue;
            }
            if (obj.type === 'SOLID') {
                if (this.checkCollision(this, obj)) {
                    const overlapX = Math.min(this.x + this.width - obj.x, obj.x + obj.width - this.x);
                    const overlapY = Math.min(this.y + this.height - obj.y, obj.y + obj.height - this.y);
                    if (overlapX < overlapY) {
                        if (this.x + this.width / 2 < obj.x + obj.width / 2) this.x = obj.x - this.width;
                        else this.x = obj.x + obj.width;
                        this.vx = 0;
                    } else {
                        if (this.y + this.height / 2 < obj.y + obj.height / 2) { this.y = obj.y - this.height; this.vy = 0; this.isGrounded = true; this.jumpCount = 0; }
                        else { this.y = obj.y + obj.height; this.vy = 0.2; }
                    }
                }
            }
        }
    }
    takeDamage(amount, camera) {
        if (this.isInvulnerable || this.health <= 0) return;
        this.health -= amount; this.isInvulnerable = true; camera.shake(10); audio.playImpact();
        globalHitStop = CONFIG.HIT_STOP_DURATION;
        setTimeout(() => { if (!this.isRolling) this.isInvulnerable = false; }, 500);
    }
    startAttack(enemies, camera) {
        this.isAttacking = true; audio.playSwing();
        setTimeout(() => {
            const hitX = this.direction === 1 ? this.x + this.width : this.x - 60;
            const hitbox = { x: hitX, y: this.y + 20, width: 60, height: 20 };
            this.isAttacking = false; this.isRecovering = true;
            let target = null;
            enemies.forEach(e => { if (e.health > 0 && this.checkCollision(hitbox, e)) target = e; });
            if (target) { target.takeDamage(50, camera); globalHitStop = CONFIG.HIT_STOP_DURATION; }
            setTimeout(() => { this.isRecovering = false; }, CONFIG.HIT_RECOVERY);
        }, CONFIG.ATTACK_DELAY);
    }
    checkCollision(rect1, rect2) {
        return rect1.x < rect2.x + rect2.width && rect1.x + rect1.width > rect2.x &&
            rect1.y < rect2.y + rect2.height && rect1.y + rect1.height > rect2.y;
    }
    startRoll() {
        this.isRolling = true; this.canRoll = false; this.isInvulnerable = true;
        this.rollHistory.push(Date.now());
        this.vx = this.direction * CONFIG.ROLL_SPEED;
        audio.playSwing();
        setTimeout(() => { this.isRolling = false; this.isInvulnerable = false; this.vx *= 0.5; }, CONFIG.ROLL_DURATION);
        setTimeout(() => { this.canRoll = true; }, CONFIG.ROLL_COOLDOWN);
    }
    updateVisuals() {
        if (this.health <= 0) this.color = '#333';
        else if (this.isInvulnerable && !this.isRolling) this.color = Date.now() % 200 < 100 ? PALETTE.PLAYER : '#ff4d4d';
        else if (this.isAttacking) this.color = PALETTE.ACCENT;
        else if (this.isRolling) this.color = '#3a86ff';
        else this.color = PALETTE.PLAYER;
        if (healthBar) healthBar.style.width = `${(this.health / CONFIG.MAX_HEALTH) * 100}%`;
    }
    draw() {
        ctx.fillStyle = this.color; ctx.fillRect(this.x, this.y, this.width, this.height);
        if (this.isAttacking || this.isRecovering) {
            ctx.fillStyle = `rgba(212, 175, 55, 0.5)`;
            const swordX = this.direction === 1 ? this.x + this.width : this.x - 60;
            ctx.fillRect(swordX, this.y + 20, 60, 20);
        }
    }
}

class Enemy {
    constructor(x, y) {
        this.width = 60; this.height = 80; this.x = x; this.y = y; this.vx = 0; this.vy = 0;
        this.health = 100; this.state = 'IDLE'; this.direction = -1;
    }
    update(player, camera) {
        if (this.health <= 0) return;
        const dist = Math.abs(player.x - this.x);
        if (dist < 400) {
            this.direction = player.x > this.x ? 1 : -1;
            this.x += this.direction * CONFIG.ENEMY_SPEED;
            if (dist < 60 && Math.random() < 0.02) player.takeDamage(10, camera);
        }
    }
    takeDamage(amount, camera) { this.health -= amount; camera.shake(5); audio.playImpact(); }
    draw() {
        if (this.health <= 0) return;
        ctx.fillStyle = PALETTE.ENEMY; ctx.fillRect(this.x, this.y, this.width, this.height);
        ctx.fillStyle = '#ff1744'; ctx.fillRect(this.x, this.y - 15, (this.health / 100) * this.width, 5);
    }
}

const player = new Player();
const enemies = [
    new Enemy(2000, 320), // R1
    new Enemy(-1200, 520), // R2
    new Enemy(400, 1620) // R4
];
const camera = new Camera();
const keys = {};

window.addEventListener('keydown', (e) => {
    audio.resume();
    keys[e.key.toLowerCase()] = true;
    if (e.key === ' ' || e.key === 'w' || e.key === 'ArrowUp') keys.space_pressed = true;
});
window.addEventListener('keyup', (e) => {
    keys[e.key.toLowerCase()] = false;
});
window.addEventListener('mousedown', (e) => { audio.resume(); if (e.button === 0) keys['mouse0'] = true; });
window.addEventListener('mouseup', (e) => { if (e.button === 0) keys['mouse0'] = false; });

function loop(timestamp) {
    const deltaTime = timestamp - (loop.lastTime || timestamp); loop.lastTime = timestamp;
    ctx.fillStyle = PALETTE.SKY; ctx.fillRect(0, 0, canvas.width, canvas.height);

    ashParticles.forEach(p => { p.update(); p.draw(); });

    if (globalHitStop > 0) globalHitStop -= deltaTime;
    else {
        player.update(keys, enemies, camera, [], []);
        enemies.forEach(e => e.update(player, camera));
    }

    camera.update(player, false); camera.apply(ctx);

    // Draw Level
    PLATFORMS.forEach(obj => {
        if (obj.lock && !player.abilities[obj.lock]) {
            ctx.fillStyle = '#4e0000'; // Locked gate color
        } else {
            ctx.fillStyle = obj.type === 'SOLID' ? PALETTE.STONE_DARK : (obj.type === 'UPGRADE' ? PALETTE.ACCENT : PALETTE.STONE_LIGHT);
        }
        ctx.fillRect(obj.x, obj.y, obj.width, obj.height);

        if (obj.lock && !player.abilities[obj.lock]) {
            ctx.fillStyle = '#fff'; ctx.font = '10px Arial';
            ctx.fillText("LOCKED", obj.x + 5, obj.y + 15);
        }
    });

    player.draw();
    enemies.forEach(e => e.draw());

    camera.restore(ctx);
    requestAnimationFrame(loop);
}
requestAnimationFrame(loop);
