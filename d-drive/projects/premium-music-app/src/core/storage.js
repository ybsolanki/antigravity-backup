/**
 * Storage Handler
 * Uses IndexedDB for metadata and OPFS for blob storage.
 */

class StorageHandler {
    constructor() {
        this.dbName = 'ZenithMusicDB';
        this.dbVersion = 1;
        this.db = null;
    }

    async init() {
        return new Promise((resolve, reject) => {
            const request = indexedDB.open(this.dbName, this.dbVersion);
            request.onerror = () => reject(request.error);
            request.onsuccess = () => {
                this.db = request.result;
                resolve();
            };
            request.onupgradeneeded = (event) => {
                const db = event.target.result;
                if (!db.objectStoreNames.contains('songs')) {
                    db.createObjectStore('songs', { keyPath: 'id' });
                }
                if (!db.objectStoreNames.contains('profile')) {
                    db.createObjectStore('profile', { keyPath: 'key' });
                }
            };
        });
    }

    async saveSong(song, audioBlob) {
        if (!this.db) await this.init();

        // Save blob to OPFS
        const root = await navigator.storage.getDirectory();
        const fileHandle = await root.getFileHandle(`${song.id}.mp3`, { create: true });
        const writable = await fileHandle.createWritable();
        await writable.write(audioBlob);
        await writable.close();

        // Save metadata to IndexedDB
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['songs'], 'readwrite');
            const store = transaction.objectStore('songs');
            const request = store.put({
                ...song,
                localPath: `${song.id}.mp3`,
                savedAt: Date.now()
            });
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    }

    async getSongs() {
        if (!this.db) await this.init();
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['songs'], 'readonly');
            const store = transaction.objectStore('songs');
            const request = store.getAll();
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }

    async getSongAudio(songId) {
        const root = await navigator.storage.getDirectory();
        const fileHandle = await root.getFileHandle(`${songId}.mp3`);
        const file = await fileHandle.getFile();
        return URL.createObjectURL(file);
    }

    async saveProfile(profile) {
        if (!this.db) await this.init();
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['profile'], 'readwrite');
            const store = transaction.objectStore('profile');
            store.put({ key: 'user', ...profile });
            transaction.oncomplete = () => resolve();
            transaction.onerror = () => reject(transaction.error);
        });
    }

    async getProfile() {
        if (!this.db) await this.init();
        return new Promise((resolve, reject) => {
            const transaction = this.db.transaction(['profile'], 'readonly');
            const store = transaction.objectStore('profile');
            const request = store.get('user');
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    }
}

export const storage = new StorageHandler();
