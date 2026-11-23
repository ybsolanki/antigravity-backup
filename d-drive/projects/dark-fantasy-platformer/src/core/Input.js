export class Input {
    constructor() {
        this.keys = {};
        this.prevKeys = {};

        window.addEventListener('keydown', (e) => {
            this.keys[e.code] = true;
        });

        window.addEventListener('keyup', (e) => {
            this.keys[e.code] = false;
        });
    }

    update() {
        this.prevKeys = { ...this.keys };
    }

    isDown(code) {
        return this.keys[code] === true;
    }

    isPressed(code) {
        return this.keys[code] === true && this.prevKeys[code] !== true;
    }
}
