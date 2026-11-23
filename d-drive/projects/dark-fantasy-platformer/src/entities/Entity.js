export class Entity {
    constructor(x, y, width, height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;

        this.vx = 0;
        this.vy = 0;

        this.vx_max = 300;
        this.vy_max = 1000;

        this.onGround = false;
        this.isStatic = false;
        this.color = '#3a3a3a';
        this.sprite = null;

        // Combat state
        this.hp = 100;
        this.maxHp = 100;
        this.isDead = false;
    }

    update(dt, input, physics, level) {
        // To be overridden
    }

    takeDamage(amount) {
        this.hp -= amount;
        if (this.hp <= 0) {
            this.hp = 0;
            this.isDead = true;
        }
    }
}
