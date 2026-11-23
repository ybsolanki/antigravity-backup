import React, { useState, useEffect } from 'react';
import { Search, Home, Library, User, Play, Pause, SkipBack, SkipForward, Shuffle, Repeat, Volume2, Heart, ListMusic, MoreVertical, Download, CheckCircle } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { playback } from './core/playback';
import { storage } from './core/storage';
import { searchSongs, downloadSong, resolveFullTrack } from './api/music';

const PremiumMusicApp = () => {
  const [activeTab, setActiveTab] = useState('home');
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentSong, setCurrentSong] = useState({
    id: 'default',
    title: "Midnight City",
    artist: "M83",
    cover: "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?q=80&w=300&h=300&auto=format&fit=crop",
    duration: "4:03",
    url: 'https://v16m-webapp.tiktokcdn-us.com/...'
  });
  const [searchResults, setSearchResults] = useState([]);
  const [librarySongs, setLibrarySongs] = useState([]);
  const [downloading, setDownloading] = useState({});
  const [searchQuery, setSearchQuery] = useState('');
  const [userProfile, setUserProfile] = useState({ name: 'Guest User' });
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [isShuffle, setIsShuffle] = useState(false);
  const [repeatMode, setRepeatMode] = useState('none');

  useEffect(() => {
    // Sync UI with playback engine
    playback.onStateChange = (state) => {
      setIsPlaying(state.isPlaying);
      setIsShuffle(state.isShuffle);
      setRepeatMode(state.repeatMode);
      if (state.currentSong) {
        setCurrentSong(state.currentSong);
        // FORCE duration update from song metadata
        if (state.currentSong.rawDuration) {
          setDuration(state.currentSong.rawDuration);
        } else if (playback.audio.duration && !isNaN(playback.audio.duration)) {
          setDuration(playback.audio.duration);
        }
      }
    };

    // Update time every second - Don't overwrite duration with preview length
    const interval = setInterval(() => {
      if (playback.audio && !playback.audio.paused) {
        setCurrentTime(playback.audio.currentTime);
      }
    }, 1000);

    // Load local data
    const loadData = async () => {
      await storage.init();
      const songs = await storage.getSongs();
      setLibrarySongs(songs);
      const profile = await storage.getProfile();
      if (profile) setUserProfile(profile);
    };
    loadData();
  }, []);

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!searchQuery) return;
    const results = await searchSongs(searchQuery);
    setSearchResults(results);
    setActiveTab('search');
  };

  const handlePlay = async (song, list = []) => {
    const playList = list.length > 0 ? list : [song];
    const startIndex = playList.findIndex(s => s.id === song.id);

    // 1. Load preview/initial song immediately
    playback.setQueue(playList, startIndex);

    // 2. Quietly resolve full track if not already resolved
    if (!song.isFullTrack) {
      console.log("Upgrading to HD track...");
      const fullTrackInfo = await resolveFullTrack(song);
      if (fullTrackInfo && fullTrackInfo.url) {
        console.log("HD Track Resolved:", fullTrackInfo.durationLabel);
        const enrichedSong = {
          ...song,
          url: fullTrackInfo.url,
          duration: fullTrackInfo.durationLabel,
          rawDuration: fullTrackInfo.duration,
          isFullTrack: true
        };

        // If the same song is still playing, swap the source seamlessly
        if (playback.queue[playback.currentIndex]?.id === song.id) {
          playback.switchSource(enrichedSong.url, true);
          setCurrentSong(enrichedSong);
          setDuration(enrichedSong.rawDuration);
        }

        // Update the queue item so next/prev/offline works with HD
        playback.queue[startIndex] = enrichedSong;
      } else {
        console.warn("HD Resolution failed, staying on preview.");
      }
    }
  };

  const handleTogglePlay = () => {
    if (isPlaying) {
      playback.pause();
    } else {
      playback.play();
    }
  };

  const handleDownload = async (song) => {
    setDownloading(prev => ({ ...prev, [song.id]: true }));
    try {
      const blob = await downloadSong(song);
      await storage.saveSong(song, blob);
      const updatedLibrary = await storage.getSongs();
      setLibrarySongs(updatedLibrary);
    } catch (error) {
      console.error("Download failed", error);
    } finally {
      setDownloading(prev => ({ ...prev, [song.id]: false }));
    }
  };

  const isSaved = (songId) => librarySongs.some(s => s.id === songId);

  return (
    <div className="app-container">
      {/* Sidebar Navigation */}
      <nav className="sidebar glass">
        <div className="logo">
          <div className="logo-icon gradient-bg"></div>
          <span>Zedox Music</span>
        </div>

        <div className="nav-group">
          <NavItem active={activeTab === 'home'} onClick={() => setActiveTab('home')} icon={<Home size={20} />} label="Home" />
          <NavItem active={activeTab === 'search'} onClick={() => setActiveTab('search')} icon={<Search size={20} />} label="Search" />
          <NavItem active={activeTab === 'library'} onClick={() => setActiveTab('library')} icon={<Library size={20} />} label="Library" />
        </div>

        <div className="nav-group profile-group">
          <div className="profile-btn glass" onClick={() => setActiveTab('profile')}>
            <div className="avatar">
              <User size={16} />
            </div>
            <span>{userProfile.name}</span>
          </div>
        </div>
      </nav>

      {/* Main Content Area */}
      <main className="main-content">
        <header className="top-bar">
          <form onSubmit={handleSearch} className="search-wrapper glass">
            <Search size={18} className="text-dim" />
            <input
              type="text"
              placeholder="Search for worlds all songs..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </form>
        </header>

        <section className="content-scroll">
          <AnimatePresence mode="wait">
            {activeTab === 'home' && (
              <motion.div key="home" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                <div className="hero-section glass premium-card">
                  <div className="hero-content">
                    <span className="badge">Featured</span>
                    <h1>Ad-Free Experience</h1>
                    <p>Listen to millions of songs offline, everywhere you go. No ads, just music.</p>
                    <button className="btn-primary">Explore Now</button>
                  </div>
                </div>
                <div className="sections-grid">
                  <MusicSection title="Recently Played" songs={librarySongs.slice(0, 5)} onPlay={(s) => handlePlay(s, librarySongs)} />
                  <MusicSection title="Top Results" songs={searchResults.slice(0, 5)} onPlay={(s) => handlePlay(s, searchResults)} />
                </div>
              </motion.div>
            )}

            {activeTab === 'search' && (
              <motion.div key="search" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                <h2 style={{ marginBottom: '24px' }}>Search Results</h2>
                <div className="song-list">
                  {searchResults.map(song => (
                    <SongRow
                      key={song.id}
                      song={song}
                      onPlay={(s) => handlePlay(s, searchResults)}
                      onDownload={handleDownload}
                      isDownloading={downloading[song.id]}
                      isSaved={isSaved(song.id)}
                    />
                  ))}
                </div>
              </motion.div>
            )}

            {activeTab === 'library' && (
              <motion.div key="library" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }}>
                <h2 style={{ marginBottom: '24px' }}>Offline Library</h2>
                <div className="song-list">
                  {librarySongs.length > 0 ? (
                    librarySongs.map(song => (
                      <SongRow
                        key={song.id}
                        song={{ ...song, album: song.album || 'Zedox Music' }}
                        onPlay={(s) => handlePlay(s, librarySongs)}
                        isSaved={true}
                      />
                    ))
                  ) : (
                    <div className="empty-state">No offline songs yet. Download some!</div>
                  )}
                </div>
              </motion.div>
            )}

            {activeTab === 'profile' && (
              <motion.div key="profile" initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className="glass premium-card" style={{ padding: '40px' }}>
                <h2>User Profile</h2>
                <div style={{ marginTop: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  <div>
                    <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-dim)' }}>Display Name</label>
                    <input
                      className="glass"
                      style={{ padding: '12px 20px', borderRadius: '12px', border: '1px solid var(--glass-border)', color: '#fff', width: '300px' }}
                      value={userProfile.name}
                      onChange={(e) => setUserProfile({ name: e.target.value })}
                    />
                  </div>
                  <button className="btn-primary" style={{ width: 'fit-content' }} onClick={() => storage.saveProfile(userProfile)}>
                    Save Settings
                  </button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </section>
      </main>

      {/* Persistent Player Bar */}
      <footer className="player-bar glass">
        <div className="now-playing">
          <img src={currentSong.cover} alt="Cover" className="song-art" />
          <div className="song-info">
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <span className="song-title">{currentSong.title}</span>
              {currentSong.isFullTrack && <span className="badge" style={{ fontSize: '10px', padding: '2px 6px', background: 'var(--primary)' }}>HD</span>}
            </div>
            <span className="song-artist">{currentSong.artist}</span>
          </div>
          <button className="heart-btn"><Heart size={18} /></button>
        </div>

        <div className="controls-main">
          <div className="playback-btns">
            <button className={`secondary-btn ${isShuffle ? 'active-control' : ''}`} onClick={() => playback.toggleShuffle()}>
              <Shuffle size={18} />
            </button>
            <button className="secondary-btn" onClick={() => playback.prev()}>
              <SkipBack size={20} fill="currentColor" />
            </button>
            <button className="play-btn gradient-bg" onClick={handleTogglePlay}>
              {isPlaying ? <Pause size={24} fill="currentColor" /> : <Play size={24} fill="currentColor" />}
            </button>
            <button className="secondary-btn" onClick={() => playback.next()}>
              <SkipForward size={20} fill="currentColor" />
            </button>
            <button className={`secondary-btn ${repeatMode !== 'none' ? 'active-control' : ''}`} onClick={() => playback.toggleRepeat()}>
              <div style={{ position: 'relative' }}>
                <Repeat size={18} />
                {repeatMode === 'one' && <span style={{ position: 'absolute', top: '-8px', right: '-8px', fontSize: '10px' }}>1</span>}
              </div>
            </button>
          </div>
          <div className="seek-bar-wrapper">
            <span className="time">{formatTime(currentTime)}</span>
            <input
              type="range"
              className="seek-bar"
              min="0"
              max={duration || 0}
              value={currentTime}
              onChange={(e) => {
                const time = parseFloat(e.target.value);
                playback.audio.currentTime = time;
                setCurrentTime(time);
              }}
            />
            <span className="time">{formatTime(duration)}</span>
          </div>
        </div>

        <div className="controls-extra">
          <button className="secondary-btn"><ListMusic size={18} /></button>
          <div className="volume-wrapper">
            <Volume2 size={18} />
            <div className="volume-bar">
              <div className="volume-progress" style={{ width: '70%' }}></div>
            </div>
          </div>
          <button className="secondary-btn"><MoreVertical size={18} /></button>
        </div>
      </footer>

      {/* Global CSS for layout */}
      <style>{`
        .app-container {
          display: grid;
          grid-template-columns: 240px 1fr;
          grid-template-rows: 1fr 100px;
          height: 100vh;
          width: 100vw;
          padding: 16px;
          gap: 16px;
          overflow: hidden;
        }

        .sidebar {
          grid-row: 1 / 2;
          display: flex;
          flex-direction: column;
          padding: 24px 16px;
          gap: 32px;
        }

        .logo {
          display: flex;
          align-items: center;
          gap: 12px;
          font-weight: 700;
          font-size: 1.25rem;
          color: #fff;
        }

        .logo-icon {
          width: 32px;
          height: 32px;
          border-radius: 8px;
        }

        .nav-group {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }

        .nav-item {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 12px 16px;
          border-radius: 12px;
          color: var(--text-dim);
          text-decoration: none;
          font-weight: 500;
          transition: all 0.2s ease;
        }

        .nav-item:hover, .nav-item.active {
          background: var(--glass-bg);
          color: #fff;
        }

        .profile-group {
          margin-top: auto;
        }

        .profile-btn {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 8px 12px;
          border-radius: 50px;
          font-weight: 500;
          cursor: pointer;
        }

        .avatar {
          width: 28px;
          height: 28px;
          border-radius: 50%;
          background: var(--glass-border);
          display: flex;
          align-items: center;
          justify-content: center;
        }

        .main-content {
          grid-column: 2;
          grid-row: 1;
          display: flex;
          flex-direction: column;
          gap: 24px;
          overflow-y: auto;
          padding-right: 8px;
        }

        .top-bar {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .search-wrapper {
          display: flex;
          align-items: center;
          gap: 12px;
          padding: 10px 20px;
          width: 100%;
          max-width: 500px;
          border-radius: 50px;
        }

        .search-wrapper input {
          background: none;
          border: none;
          color: #fff;
          width: 100%;
          outline: none;
          font-size: 0.95rem;
        }

        .hero-section {
          height: 300px;
          background: linear-gradient(to right, rgba(0,0,0,0.8), transparent), url('https://images.unsplash.com/photo-1493225255756-d9584f8606e9?q=80&w=1200') center/cover;
          padding: 48px;
          display: flex;
          align-items: center;
          border-radius: 24px;
          margin-bottom: 24px;
        }

        .hero-content {
          max-width: 400px;
        }

        .hero-content h1 {
          font-size: 3rem;
          margin: 12px 0;
          background: var(--accent-gradient);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
        }

        .badge {
          background: var(--primary);
          padding: 4px 12px;
          border-radius: 50px;
          font-size: 0.75rem;
          text-transform: uppercase;
          font-weight: 700;
        }

        .btn-primary {
          margin-top: 24px;
          background: var(--accent-gradient);
          color: #fff;
          padding: 12px 32px;
          border-radius: 50px;
          font-weight: 600;
          box-shadow: 0 4px 20px var(--primary-glow);
        }

        .song-list {
          display: flex;
          flex-direction: column;
          gap: 8px;
        }

        .song-row {
          display: grid;
          grid-template-columns: 50px 1fr 150px 100px;
          align-items: center;
          padding: 12px 16px;
          border-radius: 12px;
          transition: background 0.2s;
          cursor: pointer;
        }

        .song-row:hover {
          background: var(--glass-bg);
        }

        .player-bar {
          grid-column: 1 / 3;
          grid-row: 2;
          display: grid;
          grid-template-columns: 300px 1fr 300px;
          align-items: center;
          padding: 0 24px;
          border-radius: 24px;
        }

        .now-playing {
          display: flex;
          align-items: center;
          gap: 16px;
        }

        .song-art {
          width: 60px;
          height: 60px;
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0,0,0,0.3);
        }

        .song-info {
          display: flex;
          flex-direction: column;
          overflow: hidden;
        }

        .song-title {
          font-weight: 600;
          font-size: 1rem;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .song-artist {
          font-size: 0.85rem;
          color: var(--text-dim);
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .controls-main {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 12px;
        }

        .playback-btns {
          display: flex;
          align-items: center;
          gap: 24px;
        }

        .play-btn {
          width: 48px;
          height: 48px;
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          color: #fff;
          box-shadow: 0 4px 15px var(--primary-glow);
        }

        .secondary-btn {
          color: var(--text-dim);
        }

        .secondary-btn:hover {
          color: #fff;
        }

        .seek-bar-wrapper {
          width: 100%;
          max-width: 600px;
          display: flex;
          align-items: center;
          gap: 12px;
        }

        .time {
          font-size: 0.75rem;
          color: var(--text-dim);
          min-width: 35px;
        }

        .seek-bar {
          flex: 1;
          height: 4px;
          background: var(--glass-border);
          border-radius: 2px;
          position: relative;
        }

        .seek-progress {
          position: absolute;
          left: 0;
          top: 0;
          height: 100%;
          background: var(--primary);
          border-radius: 2px;
        }

        .controls-extra {
          display: flex;
          align-items: center;
          justify-content: flex-end;
          gap: 20px;
        }

        .volume-wrapper {
          display: flex;
          align-items: center;
          gap: 12px;
          width: 120px;
        }

        .volume-bar {
          flex: 1;
          height: 4px;
          background: var(--glass-border);
          border-radius: 2px;
        }

        .volume-progress {
          height: 100%;
          background: #fff;
          border-radius: 2px;
        }

        .active-control {
          color: var(--primary) !important;
          filter: drop-shadow(0 0 8px var(--primary-glow));
        }

        .active-control div::after {
          content: '';
          position: absolute;
          bottom: -4px;
          left: 50%;
          transform: translateX(-50%);
          width: 4px;
          height: 4px;
          background: var(--primary);
          border-radius: 50%;
        }

        .gradient-bg {
          background: var(--accent-gradient);
        }

        .empty-state {
          padding: 60px;
          text-align: center;
          color: var(--text-dim);
        }

        @media (max-width: 900px) {
          .app-container {
            grid-template-columns: 1fr;
            grid-template-rows: 1fr 100px;
          }
          .sidebar {
            display: none;
          }
          .main-content {
            grid-column: 1;
          }
          .player-bar {
            grid-template-columns: 1fr 100px;
            padding: 0 16px;
          }
          .controls-extra, .controls-main .seek-bar-wrapper {
            display: none;
          }
          .now-playing {
            width: 100%;
          }
        }
      `}</style>
    </div>
  );
};

const NavItem = ({ icon, label, active, onClick }) => (
  <button className={"nav-item " + (active ? 'active' : '')} onClick={onClick}>
    {icon}
    <span>{label}</span>
  </button>
);

const SongRow = ({ song, onPlay, onDownload, isDownloading, isSaved }) => (
  <div className="song-row" onClick={() => onPlay(song)}>
    <img src={song.cover} alt="" style={{ width: '40px', height: '40px', borderRadius: '6px' }} />
    <div style={{ marginLeft: '12px' }}>
      <div style={{ fontWeight: 600 }}>{song.title}</div>
      <div style={{ fontSize: '0.8rem', color: 'var(--text-dim)' }}>{song.artist}</div>
    </div>
    <div style={{ fontSize: '0.85rem', color: 'var(--text-dim)' }}>{song.album}</div>
    <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
      {isSaved ? (
        <CheckCircle size={18} className="text-primary" style={{ color: 'var(--primary)' }} />
      ) : (
        <button
          onClick={(e) => { e.stopPropagation(); onDownload(song); }}
          disabled={isDownloading}
          className="secondary-btn"
        >
          {isDownloading ? <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1 }}><Download size={18} /></motion.div> : <Download size={18} />}
        </button>
      )}
    </div>
  </div>
);

const MusicSection = ({ title, songs, onPlay }) => (
  <div className="section" style={{ marginTop: '24px' }}>
    <h3 style={{ marginBottom: '16px', fontSize: '1.25rem' }}>{title}</h3>
    <div style={{ display: 'flex', gap: '16px', overflowX: 'auto', paddingBottom: '12px' }}>
      {songs.length > 0 ? songs.map(song => (
        <div key={song.id} className="glass premium-card" style={{ minWidth: '160px', padding: '16px', cursor: 'pointer' }} onClick={() => onPlay(song)}>
          <img src={song.cover} style={{ width: '100%', borderRadius: '12px', marginBottom: '12px' }} alt="" />
          <div style={{ fontWeight: 600, fontSize: '0.9rem', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{song.title}</div>
          <div style={{ fontSize: '0.8rem', color: 'var(--text-dim)' }}>{song.artist}</div>
        </div>
      )) : (
        <div style={{ color: 'var(--text-dim)', fontSize: '0.9rem' }}>No songs yet.</div>
      )}
    </div>
  </div>
);

const formatTime = (time) => {
  if (!time || isNaN(time)) return "0:00";
  const min = Math.floor(time / 60);
  const sec = Math.floor(time % 60);
  return `${min}:${sec < 10 ? '0' : ''}${sec}`;
};

export default PremiumMusicApp;
