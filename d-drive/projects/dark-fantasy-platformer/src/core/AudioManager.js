export class AudioManager {
    constructor() {
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        this.ambient = null;
        this.chant = null;
    }

    async init() {
        // Generate procedurally or load placeholder if needed
        // For this build, we use Low-frequency oscillators to simulate wind
    }

    playAmbient() {
        if (this.ctx.state === 'suspended') this.ctx.resume();

        // Simple noise-based wind simulation
        const bufferSize = 2 * this.ctx.sampleRate;
        const noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const output = noiseBuffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            output[i] = Math.random() * 2 - 1;
        }

        const whiteNoise = this.ctx.createBufferSource();
        whiteNoise.buffer = noiseBuffer;
        whiteNoise.loop = true;

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.value = 400;
        filter.Q.value = 10;

        const gain = this.ctx.createGain();
        gain.gain.value = 0.05;

        whiteNoise.connect(filter);
        filter.connect(gain);
        gain.connect(this.ctx.destination);

        whiteNoise.start();
        this.ambient = whiteNoise;
    }

    playChant() {
        // Distant, low-frequency hum/chant
        const osc = this.ctx.createOscillator();
        osc.type = 'sawtooth';
        osc.frequency.value = 60; // Low hum

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.value = 200;

        const gain = this.ctx.createGain();
        gain.gain.value = 0.02;

        osc.connect(filter);
        filter.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start();
        this.chant = osc;
    }
}
