import { Entity } from './Entity.js';

export class Enemy extends Entity {
    constructor(x, y, type) {
        super(x, y, 32, 64);
        this.type = type;
        this.color = '#3a3a3a'; // Default stone gray

        this.state = 'idle'; // idle, alert, attack, recovery
        this.timer = 0;

        if (type === 'whispered') {
            this.color = '#1a1a1a'; // Darker for Whispered
            this.width = 28;
            this.height = 72; // Tall and thin
            this.speed = 40;
            this.attackRange = 100;
            this.windupTime = 0.8; // Slow, telegraphed lunges
        }
    }

    update(dt, input, physics, level) {
        if (this.isDead) return;

        const player = level ? level.player : null;
        if (!player) return;

        const dist = Math.abs(player.x - this.x);
        const dir = Math.sign(player.x - this.x);

        switch (this.state) {
            case 'idle':
                if (dist < 300) {
                    this.state = 'alert';
                }
                break;

            case 'alert':
                if (dist > 400) {
                    this.state = 'idle';
                } else if (dist < this.attackRange) {
                    this.state = 'windup';
                    this.timer = this.windupTime;
                } else {
                    // Move slowly towards player
                    this.vx = dir * this.speed;
                }
                break;

            case 'windup':
                this.vx = 0;
                this.timer -= dt;
                if (this.timer <= 0) {
                    this.state = 'attack';
                    this.timer = 0.2; // Attack duration
                    this.vx = dir * 300; // Lunge
                }
                break;

            case 'attack':
                this.timer -= dt;
                if (this.timer <= 0) {
                    this.state = 'recovery';
                    this.timer = 1.0; // Long recovery
                }
                break;

            case 'recovery':
                this.vx = 0;
                this.timer -= dt;
                if (this.timer <= 0) {
                    this.state = 'alert';
                }
                break;
        }
    }
}
