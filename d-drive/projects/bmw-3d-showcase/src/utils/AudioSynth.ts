class EngineAudioSynthesizer {
  private ctx: AudioContext | null = null;
  private osc1: OscillatorNode | null = null;
  private osc2: OscillatorNode | null = null;
  private gainNode: GainNode | null = null;
  private filterNode: BiquadFilterNode | null = null;
  private isPlaying: boolean = false;
  private currentMode: 'comfort' | 'sport' | 'mtrack' = 'sport';

  public init() {
    if (this.ctx) return;
    const AudioCtx = window.AudioContext || (window as any).webkitAudioContext;
    if (!AudioCtx) return;

    this.ctx = new AudioCtx();
    this.gainNode = this.ctx.createGain();
    this.gainNode.gain.value = 0;

    this.filterNode = this.ctx.createBiquadFilter();
    this.filterNode.type = 'lowpass';
    this.filterNode.frequency.value = 400;

    this.osc1 = this.ctx.createOscillator();
    this.osc1.type = 'sawtooth';
    this.osc1.frequency.value = 60; // Base engine idle RPM pitch

    this.osc2 = this.ctx.createOscillator();
    this.osc2.type = 'triangle';
    this.osc2.frequency.value = 120; // Sub harmonic pitch

    this.osc1.connect(this.filterNode);
    this.osc2.connect(this.filterNode);
    this.filterNode.connect(this.gainNode);
    this.gainNode.connect(this.ctx.destination);

    this.osc1.start();
    this.osc2.start();
  }

  public setMode(mode: 'comfort' | 'sport' | 'mtrack') {
    this.currentMode = mode;
    if (!this.ctx || !this.filterNode || !this.osc1 || !this.osc2) return;

    const now = this.ctx.currentTime;
    if (mode === 'comfort') {
      this.osc1.frequency.setTargetAtTime(45, now, 0.3);
      this.osc2.frequency.setTargetAtTime(90, now, 0.3);
      this.filterNode.frequency.setTargetAtTime(300, now, 0.3);
    } else if (mode === 'sport') {
      this.osc1.frequency.setTargetAtTime(80, now, 0.2);
      this.osc2.frequency.setTargetAtTime(160, now, 0.2);
      this.filterNode.frequency.setTargetAtTime(800, now, 0.2);
    } else if (mode === 'mtrack') {
      this.osc1.frequency.setTargetAtTime(130, now, 0.1);
      this.osc2.frequency.setTargetAtTime(260, now, 0.1);
      this.filterNode.frequency.setTargetAtTime(1800, now, 0.1);
    }
  }

  public toggleSound(enabled?: boolean): boolean {
    this.init();
    if (!this.ctx || !this.gainNode) return false;

    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }

    const nextState = enabled !== undefined ? enabled : !this.isPlaying;
    this.isPlaying = nextState;

    const now = this.ctx.currentTime;
    if (this.isPlaying) {
      this.gainNode.gain.cancelScheduledValues(now);
      this.gainNode.gain.setValueAtTime(0.001, now);
      this.gainNode.gain.exponentialRampToValueAtTime(0.08, now + 0.3);
    } else {
      this.gainNode.gain.cancelScheduledValues(now);
      this.gainNode.gain.setValueAtTime(this.gainNode.gain.value, now);
      this.gainNode.gain.exponentialRampToValueAtTime(0.0001, now + 0.3);
    }

    return this.isPlaying;
  }

  public revEngine() {
    if (!this.ctx || !this.osc1 || !this.osc2 || !this.filterNode || !this.isPlaying) return;

    const now = this.ctx.currentTime;
    const baseFreq = this.currentMode === 'mtrack' ? 130 : this.currentMode === 'sport' ? 80 : 45;
    
    // Pitch rev spike up & down
    this.osc1.frequency.cancelScheduledValues(now);
    this.osc1.frequency.setValueAtTime(baseFreq, now);
    this.osc1.frequency.exponentialRampToValueAtTime(baseFreq * 2.5, now + 0.4);
    this.osc1.frequency.exponentialRampToValueAtTime(baseFreq, now + 1.2);

    this.filterNode.frequency.cancelScheduledValues(now);
    this.filterNode.frequency.exponentialRampToValueAtTime(2400, now + 0.4);
    this.filterNode.frequency.exponentialRampToValueAtTime(600, now + 1.2);
  }

  public playClickSound() {
    if (!this.ctx) return;
    if (this.ctx.state === 'suspended') this.ctx.resume();

    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();
    const now = this.ctx.currentTime;

    osc.type = 'sine';
    osc.frequency.setValueAtTime(800, now);
    osc.frequency.exponentialRampToValueAtTime(200, now + 0.05);

    gain.gain.setValueAtTime(0.05, now);
    gain.gain.exponentialRampToValueAtTime(0.001, now + 0.05);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start(now);
    osc.stop(now + 0.05);
  }
}

export const engineAudio = new EngineAudioSynthesizer();
