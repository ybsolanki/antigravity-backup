import { Enemy } from './Enemy.js';

export class BoundEnemy extends Enemy {
    constructor(x, y) {
        super(x, y, 'bound');
        this.color = '#4a0404'; // Dried blood red
        this.width = 48;
        this.height = 64;
        this.speed = 20; // Very slow
        this.attackRange = 80;
        this.windupTime = 1.2; // Very slow, crushing attack
        this.hp = 200; // Tanky
    }

    update(dt, input, physics, level) {
        if (this.isDead) return;

        // Chains rattle sound logic could go here
        super.update(dt, input, physics, level);
    }
}
