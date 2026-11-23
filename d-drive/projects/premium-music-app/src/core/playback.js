/**
 * Playback Engine for the Music App
 * Handles Audio objects, Media Session API, Queue logic, Shuffle, and Repeat.
 */
import { storage } from './storage';

class PlaybackEngine {
    constructor() {
        this.audio = new Audio();
        this.queue = [];
        this.currentIndex = -1;
        this.isPlaying = false;
        this.isShuffle = false;
        this.repeatMode = 'none'; // 'none', 'one', 'all'
        this.onStateChange = null;

        // Handle song end automatically
        this.audio.onended = () => {
            if (this.repeatMode === 'one') {
                this.audio.currentTime = 0;
                this.audio.play();
            } else {
                this.next();
            }
        };

        if ('mediaSession' in navigator) {
            this.setupMediaSession();
        }
    }

    setupMediaSession() {
        const ms = navigator.mediaSession;
        ms.setActionHandler('play', () => this.play());
        ms.setActionHandler('pause', () => this.pause());
        ms.setActionHandler('previoustrack', () => this.prev());
        ms.setActionHandler('nexttrack', () => this.next());
        ms.setActionHandler('seekto', (details) => {
            this.audio.currentTime = details.seekTime;
        });
    }

    updateMetadata(song) {
        if ('mediaSession' in navigator) {
            navigator.mediaSession.metadata = new MediaMetadata({
                title: song.title,
                artist: song.artist,
                album: song.album || 'Zedox Music',
                artwork: [{ src: song.cover || '', sizes: '512x512', type: 'image/png' }]
            });
        }
    }

    setQueue(songs, startIndex = 0) {
        this.queue = [...songs];
        this.currentIndex = startIndex;
        this.load(this.queue[this.currentIndex]);
    }

    async load(song) {
        if (!song) return;

        let playUrl = song.url;

        // Check if we have this song offline
        try {
            const offlineUrl = await storage.getSongAudio(song.id);
            if (offlineUrl) {
                playUrl = offlineUrl;
                console.log("Playing from local storage:", song.title);
            }
        } catch (e) {
            // Not offline or error, use original URL
        }

        this.audio.src = playUrl;
        this.updateMetadata(song);
        this.play();
    }

    switchSource(newUrl, preserveTime = true) {
        const currentTime = this.audio.currentTime;
        const wasPlaying = !this.audio.paused;

        this.audio.src = newUrl;
        if (preserveTime) {
            this.audio.onloadedmetadata = () => {
                this.audio.currentTime = currentTime;
                if (wasPlaying) this.audio.play();
                this.audio.onloadedmetadata = null;
            };
        } else if (wasPlaying) {
            this.audio.play();
        }
    }

    play() {
        this.audio.play().then(() => {
            this.isPlaying = true;
            this.emitState();
            if ('mediaSession' in navigator) navigator.mediaSession.playbackState = 'playing';
        }).catch(e => console.error("Playback failed:", e));
    }

    pause() {
        this.audio.pause();
        this.isPlaying = false;
        this.emitState();
        if ('mediaSession' in navigator) navigator.mediaSession.playbackState = 'paused';
    }

    next() {
        if (this.queue.length === 0) return;

        if (this.isShuffle) {
            this.currentIndex = Math.floor(Math.random() * this.queue.length);
        } else {
            this.currentIndex = (this.currentIndex + 1) % this.queue.length;
            if (this.currentIndex === 0 && this.repeatMode !== 'all') {
                this.pause();
                return;
            }
        }
        this.load(this.queue[this.currentIndex]);
    }

    prev() {
        if (this.queue.length === 0) return;
        this.currentIndex = (this.currentIndex - 1 + this.queue.length) % this.queue.length;
        this.load(this.queue[this.currentIndex]);
    }

    toggleShuffle() {
        this.isShuffle = !this.isShuffle;
        this.emitState();
    }

    toggleRepeat() {
        const modes = ['none', 'all', 'one'];
        const idx = modes.indexOf(this.repeatMode);
        this.repeatMode = modes[(idx + 1) % modes.length];
        this.emitState();
    }

    emitState() {
        if (this.onStateChange) {
            this.onStateChange({
                isPlaying: this.isPlaying,
                currentIndex: this.currentIndex,
                isShuffle: this.isShuffle,
                repeatMode: this.repeatMode,
                currentSong: this.queue[this.currentIndex]
            });
        }
    }
}

export const playback = new PlaybackEngine();
