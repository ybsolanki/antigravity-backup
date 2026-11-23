/**
 * Music API Service - Resilient Version
 * Fetches search results from iTunes and resolves full streams using a pool of Piped/Invidious instances.
 */

const STREAM_INSTANCES = [
    'https://pipedapi.kavin.rocks',
    'https://api-piped.mha.fi',
    'https://pipedapi.rivm.ch',
    'https://piped-api.garudalinux.org',
    'https://invidious.snopyta.org/api/v1',
    'https://yewtu.be/api/v1',
    'https://invidious.kavin.rocks/api/v1',
    'https://vid.priv.au/api/v1'
];

const fetchResilient = async (path) => {
    for (const instance of STREAM_INSTANCES) {
        try {
            const url = `${instance}${path}`;
            const res = await fetch(url, { signal: AbortSignal.timeout(5000) });
            if (res.ok) {
                const data = await res.json();
                // Normalization: Piped returns {items: []}, Invidious usually returns results directly or {videos: []}
                return data;
            }
        } catch (e) {
            continue;
        }
    }
    throw new Error("All streaming instances failed");
};

export const searchSongs = async (query) => {
    try {
        const response = await fetch(`https://itunes.apple.com/search?term=${encodeURIComponent(query)}&media=music&limit=25`);
        const data = await response.json();

        return data.results.map(item => ({
            id: item.trackId.toString(),
            title: item.trackName,
            artist: item.artistName,
            album: item.collectionName,
            cover: item.artworkUrl100.replace('100x100bb', '600x600bb'),
            duration: formatDuration(item.trackTimeMillis),
            rawDuration: (item.trackTimeMillis || 0) / 1000,
            previewUrl: item.previewUrl,
            url: item.previewUrl,
            isFullTrack: false
        }));
    } catch (error) {
        console.error("Search failed:", error);
        return [];
    }
};

const formatDuration = (ms) => {
    if (!ms) return "0:00";
    const minutes = Math.floor(ms / 60000);
    const seconds = Math.floor((ms % 60000) / 1000);
    return `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`;
};

export const resolveFullTrack = async (song) => {
    try {
        const query = `${song.title} ${song.artist}`;

        // 1. Search for the video ID
        // We try Piped format search first, then Invidious if needed
        let videoId = null;
        let duration = 0;

        for (const instance of STREAM_INSTANCES) {
            try {
                const isInv = instance.includes('inv') || instance.includes('yewtu') || instance.includes('priv');
                const searchPath = isInv
                    ? `/search?q=${encodeURIComponent(query)}&type=video`
                    : `/search?q=${encodeURIComponent(query)}&filter=music_songs`;

                const res = await fetch(`${instance}${searchPath}`, { signal: AbortSignal.timeout(4000) });
                if (!res.ok) continue;
                const data = await res.json();

                const items = isInv ? data : data.items;
                if (items && items.length > 0) {
                    videoId = isInv ? items[0].videoId : items[0].url.split('v=')[1];
                    duration = isInv ? items[0].lengthSeconds : data.items[0].duration;
                    if (videoId) break;
                }
            } catch (e) { continue; }
        }

        if (!videoId) return null;

        // 2. Get the stream URL
        for (const instance of STREAM_INSTANCES) {
            try {
                const isInv = instance.includes('inv') || instance.includes('yewtu') || instance.includes('priv');
                const streamPath = isInv ? `/videos/${videoId}` : `/streams/${videoId}`;

                const res = await fetch(`${instance}${streamPath}`, { signal: AbortSignal.timeout(4000) });
                if (!res.ok) continue;
                const data = await res.json();

                let streamUrl = null;
                if (isInv) {
                    const audio = data.adaptiveFormats.find(f => f.type.includes('audio/webm')) || data.adaptiveFormats.find(f => f.type.includes('audio'));
                    streamUrl = audio.url;
                } else {
                    const audio = data.audioStreams.sort((a, b) => b.bitrate - a.bitrate)[0];
                    streamUrl = audio.url;
                }

                if (streamUrl) {
                    return {
                        url: streamUrl,
                        duration: duration || song.rawDuration,
                        durationLabel: formatDuration((duration || song.rawDuration) * 1000)
                    };
                }
            } catch (e) { continue; }
        }
    } catch (e) {
        console.error("Full track resolution failed:", e);
    }
    return null;
};

export const downloadSong = async (song) => {
    try {
        const fullTrackInfo = song.isFullTrack ? { url: song.url, duration: song.rawDuration } : await resolveFullTrack(song);
        if (!fullTrackInfo || !fullTrackInfo.url) throw new Error("Resolution failed");
        const response = await fetch(fullTrackInfo.url);
        return await response.blob();
    } catch (error) {
        console.error("Download failed:", error);
        throw error;
    }
};
