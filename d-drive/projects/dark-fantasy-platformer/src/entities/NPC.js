import { Entity } from './Entity.js';

export class NPC extends Entity {
    constructor(x, y) {
        super(x, y, 32, 64);
        this.color = '#3a3a3a';
        this.isStatic = true;

        this.dialogue = [
            "Some wounds do not bleed.",
            "You carried this longer than you should.",
            "Go. It will not follow you."
        ];
        this.currentLine = 0;
        this.interactionRange = 100;
    }

    interact() {
        const box = document.getElementById('dialogue-box');
        if (!box) return;

        box.innerText = this.dialogue[this.currentLine];
        box.style.opacity = 1;

        setTimeout(() => {
            box.style.opacity = 0;
        }, 4000);

        this.currentLine = (this.currentLine + 1) % this.dialogue.length;
    }
}
