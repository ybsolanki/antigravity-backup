import { Entity } from './Entity.js';

export class Player extends Entity {
    constructor(x, y) {
        super(x, y, 32, 64);
        this.color = '#8c763a'; // Muted gold for contrast

        this.accel = 1000;
        this.jumpForce = -600;

        this.stamina = 100;
        this.maxStamina = 100;
        this.staminaRegen = 20;

        this.isAttacking = false;
        this.attackTimer = 0;
        this.attackDuration = 0.5; // Heavy, deliberate swings
    }

    update(dt, input, physics, level) {
        if (this.isDead) return;

        // Movement
        if (input.isDown('KeyA') || input.isDown('ArrowLeft')) {
            this.vx -= this.accel * dt;
        } else if (input.isDown('KeyD') || input.isDown('ArrowRight')) {
            this.vx += this.accel * dt;
        }

        // Jump
        if ((input.isPressed('Space') || input.isPressed('ArrowUp')) && this.onGround) {
            this.vy = this.jumpForce;
            this.onGround = false;
        }

        // Attack
        if (input.isPressed('KeyK') || input.isPressed('KeyZ')) {
            this.attack();
        }

        // Attack logic
        if (this.isAttacking) {
            this.attackTimer -= dt;

            // Trigger damage at the "sweet spot" of the animation (0.3s into 0.5s)
            if (this.attackTimer < 0.2 && this.attackTimer > 0.15) {
                this.checkCombatHit(level);
            }

            if (this.attackTimer <= 0) {
                this.isAttacking = false;
            }
        }

        // Stamina regen
        if (!this.isAttacking && this.stamina < this.maxStamina) {
            this.stamina += this.staminaRegen * dt;
        }

        // Update UI elements
        this.updateUI();
    }

    attack() {
        if (this.isAttacking || this.stamina < 30) return;

        this.isAttacking = true;
        this.attackTimer = this.attackDuration;
        this.stamina -= 30;

        console.log("Player Attacks!");
    }

    checkCombatHit(level) {
        if (!level) return;

        const hitWidth = 60;
        const hitHeight = 64;
        const hitX = this.vx >= 0 ? this.x : this.x - hitWidth;
        const hitRect = { x: hitX, y: this.y - 32, width: hitWidth, height: hitHeight };

        for (const enemy of level.game.entities) {
            if (enemy === this || enemy.isDead) continue;

            if (level.game.physics.checkCollision(hitRect, {
                x: enemy.x - enemy.width / 2,
                y: enemy.y - enemy.height / 2,
                width: enemy.width,
                height: enemy.height
            })) {
                enemy.takeDamage(25);
                console.log("Hit enemy!", enemy.hp);
            }
        }
    }

    updateUI() {
        const hpBar = document.getElementById('health-bar');
        const staminaBar = document.getElementById('stamina-bar');

        if (hpBar) hpBar.style.width = `${(this.hp / this.maxHp) * 100}%`;
        if (staminaBar) staminaBar.style.width = `${(this.stamina / this.maxStamina) * 100}%`;
    }
}
