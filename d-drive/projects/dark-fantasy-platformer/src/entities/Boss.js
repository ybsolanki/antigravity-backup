import { Enemy } from './Enemy.js';

export class Boss extends Enemy {
    constructor(x, y) {
        super(x, y, 'boss');
        this.width = 48;
        this.height = 96; // Taller than the player
        this.color = '#3a3a3a'; // Stone gray armor 

        this.hp = 1000;
        this.maxHp = 1000;

        this.windupTime = 1.5; // Very readable arcs
        this.recoveryTime = 2.0; // Shows restraint/hesitation

        this.state = 'intro';
        this.timer = 3.0;
    }

    update(dt, input, physics, level) {
        if (this.isDead) return;

        const player = level ? level.player : null;
        if (!player) return;

        const dist = Math.abs(player.x - this.x);
        const dir = Math.sign(player.x - this.x);

        // Boss specific state machine
        switch (this.state) {
            case 'intro':
                this.timer -= dt;
                if (this.timer <= 0) this.state = 'idle';
                break;

            case 'idle':
                if (dist < 200) {
                    this.state = 'windup';
                    this.timer = this.windupTime;
                } else {
                    // Slow, dignified walk
                    this.vx = dir * 30;
                }
                break;

            case 'windup':
                this.vx = 0;
                this.timer -= dt;
                if (this.timer <= 0) {
                    this.state = 'attack';
                    this.timer = 0.4;
                    // Launch massive sword swing (logic handled in Game.js or Boss)
                }
                break;

            case 'attack':
                this.timer -= dt;
                if (this.timer <= 0) {
                    this.state = 'recovery';
                    this.timer = this.recoveryTime;
                }
                break;

            case 'recovery':
                this.vx = 0;
                this.timer -= dt;
                if (this.timer <= 0) {
                    this.state = 'idle';
                }
                break;
        }

        // Low health behavior
        if (this.hp < this.maxHp * 0.3) {
            this.windupTime = 2.0; // Slower
            this.recoveryTime = 3.0; // More hesitation
        }
    }
}
