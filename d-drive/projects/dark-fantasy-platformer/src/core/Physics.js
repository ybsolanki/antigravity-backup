export class Physics {
    constructor() {
        this.gravity = 1500;
    }

    update(entities, level) {
        for (const entity of entities) {
            if (entity.isStatic) continue;

            // Apply gravity
            if (!entity.onGround) {
                entity.vy += this.gravity * 0.016; // Approx 60fps dt
            }

            // Horizontal friction
            entity.vx *= 0.85;

            // Integrate velocity
            entity.x += entity.vx * 0.016;
            entity.y += entity.vy * 0.016;

            // Basic ground check (placeholder until level geometry is implemented)
            if (entity.y > 600) {
                entity.y = 600;
                entity.vy = 0;
                entity.onGround = true;
            } else {
                entity.onGround = false;
            }
        }
    }

    checkCollision(rect1, rect2) {
        return (
            rect1.x < rect2.x + rect2.width &&
            rect1.x + rect1.width > rect2.x &&
            rect1.y < rect2.y + rect2.height &&
            rect1.y + rect1.height > rect2.y
        );
    }
}
