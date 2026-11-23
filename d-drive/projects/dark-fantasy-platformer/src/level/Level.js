export class Level {
    constructor(game) {
        this.game = game;
        this.tileSize = 64;

        this.zones = [
            { name: "The Ruined Temple", x: 0, width: 2000 },
            { name: "The Courtyard of Bells", x: 2000, width: 2000 },
            { name: "The Corridor of Faces", x: 4000, width: 2000 }
        ];

        this.player = null;
    }

    getTileAt(x, y) {
        const col = Math.floor(x / this.tileSize);
        const row = Math.floor(y / this.tileSize);
        // Boundary check and tile return
        return 0;
    }

    draw(renderer) {
        const ctx = renderer.ctx;
        const camera = renderer.camera;

        // Draw parallax background (static dark gray silhouettes)
        ctx.fillStyle = '#050505';
        ctx.fillRect(0, 0, renderer.width, renderer.height);

        // Draw stone floor with textures
        ctx.fillStyle = '#111111';
        ctx.fillRect(-camera.x, 600 - camera.y, 6000, 500);

        // Decorative elements: Broken bells and hanging cloth
        ctx.strokeStyle = '#2a2a2a';
        ctx.lineWidth = 2;
        for (let i = 0; i < 6000; i += 400) {
            const x = i - camera.x;
            ctx.beginPath();
            ctx.moveTo(x, -camera.y);
            ctx.lineTo(x, 200 - camera.y + Math.sin(Date.now() * 0.001 + i) * 10);
            ctx.stroke();

            // "Bells"
            if (i % 800 === 0) {
                ctx.fillStyle = '#1a1a1a';
                ctx.fillRect(x - 20, 200 - camera.y + Math.sin(Date.now() * 0.001 + i) * 10, 40, 50);
            }
        }

        // Zone Titles
        ctx.fillStyle = 'rgba(58, 58, 58, 0.3)';
        ctx.font = 'italic 48px serif';
        this.zones.forEach(zone => {
            if (this.game.player.x > zone.x && this.game.player.x < zone.x + zone.width) {
                ctx.fillText(zone.name, 50, renderer.height - 50);
            }
        });
    }
}
