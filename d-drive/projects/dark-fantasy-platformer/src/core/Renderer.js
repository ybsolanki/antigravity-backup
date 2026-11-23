export class Renderer {
    constructor(ctx) {
        this.ctx = ctx;
        this.width = 0;
        this.height = 0;

        // Aesthetic settings
        this.camera = { x: 0, y: 0 };
    }

    resize(width, height) {
        this.width = width;
        this.height = height;
    }

    clear() {
        this.ctx.fillStyle = '#0a0a0a'; // Ash black
        this.ctx.fillRect(0, 0, this.width, this.height);
    }

    drawLevel(level) {
        level.draw(this);
    }

    updateCamera(target) {
        if (!target) return;

        // Smooth follow
        const lerp = 0.1;
        this.camera.x += (target.x - this.width / 2 - this.camera.x) * lerp;
        this.camera.y += (target.y - this.height / 2 - this.camera.y) * lerp;

        // Limit camera y to keep ground in view
        this.camera.y = Math.min(this.camera.y, 200);
    }

    drawEntity(entity) {
        const rx = entity.x - this.camera.x;
        const ry = entity.y - this.camera.y;

        this.ctx.save();
        this.ctx.translate(rx, ry);

        // Draw shadows (soft, elongated)
        this.ctx.shadowColor = 'rgba(0, 0, 0, 0.8)';
        this.ctx.shadowBlur = 15;
        this.ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
        this.ctx.beginPath();
        this.ctx.ellipse(0, entity.height / 2, entity.width * 0.8, 6, 0, 0, Math.PI * 2);
        this.ctx.fill();
        this.ctx.shadowBlur = 0;

        if (entity.sprite) {
            // Draw sprite logic
        } else {
            // Painterly silhouette
            this.ctx.fillStyle = entity.color || '#3a3a3a';

            // Add slight "brush stroke" variance to the silhouette
            this.ctx.beginPath();
            const w = entity.width;
            const h = entity.height;
            this.ctx.moveTo(-w / 2 + Math.random() * 2, -h / 2 + Math.random() * 2);
            this.ctx.lineTo(w / 2 + Math.random() * 2, -h / 2 + Math.random() * 2);
            this.ctx.lineTo(w / 2 + Math.random() * 2, h / 2 + Math.random() * 2);
            this.ctx.lineTo(-w / 2 + Math.random() * 2, h / 2 + Math.random() * 2);
            this.ctx.closePath();
            this.ctx.fill();

            // Combat feedback: faint glow for eyes/cursed energy
            if (entity instanceof Player && entity.isAttacking) {
                this.ctx.fillStyle = 'rgba(168, 213, 186, 0.5)'; // Sickly jade
                this.ctx.beginPath();
                this.ctx.arc(0, -h / 2 + 10, 4, 0, Math.PI * 2);
                this.ctx.fill();
            }
        }

        this.ctx.restore();
    }
}
