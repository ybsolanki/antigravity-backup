import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import Scene from './components/Scene';
import Preloader from './components/Preloader';
import CustomCursor from './components/CustomCursor';
import Lenis from 'lenis';

function App() {
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const lenis = new Lenis();
        function raf(time) {
            lenis.raf(time);
            requestAnimationFrame(raf);
        }
        requestAnimationFrame(raf);

        // Simulate loading
        const timer = setTimeout(() => {
            setLoading(false);
        }, 2500);

        return () => {
            clearTimeout(timer);
            lenis.destroy();
        };
    }, []);

    return (
        <div className="app-container">
            <CustomCursor />
            <div className="noise" />

            <AnimatePresence>
                {loading && <Preloader key="loader" />}
            </AnimatePresence>

            <div className="canvas-wrapper">
                <Scene />
            </div>

            <main>
                <section className="hero">
                    <motion.div
                        initial={{ opacity: 0, y: 50 }}
                        animate={!loading ? { opacity: 1, y: 0 } : {}}
                        transition={{ duration: 1, delay: 0.5, ease: [0.33, 1, 0.68, 1] }}
                    >
                        <p className="text-accent">Protocol 01 // System Online</p>
                        <h1>
                            ZEDOX <br />
                            <span className="text-gradient">NETWORK</span>
                        </h1>
                        <p>
                            Architecting the next generation of high-availability <br />
                            mesh networks and digital infrastructure.
                        </p>
                    </motion.div>
                </section>

                <section className="about">
                    <div style={{ maxWidth: '800px' }}>
                        <motion.div
                            initial={{ opacity: 0, x: -50 }}
                            whileInView={{ opacity: 1, x: 0 }}
                            transition={{ duration: 1 }}
                        >
                            <h2 className="text-accent">// INFRASTRUCTURE</h2>
                            <p style={{ marginTop: '2rem', fontSize: '1.8rem', lineHeight: 1.2, fontWeight: 700 }}>
                                WE DON'T JUST HOST BOTS. <br />
                                WE BUILD ECOSYSTEMS.
                            </p>
                            <p style={{ marginTop: '1.5rem', color: 'var(--text-muted)' }}>
                                Our proprietary mesh technology ensures 99.9% uptime for decentralized
                                applications, AI-driven moderation, and immersive gaming experiences.
                            </p>
                        </motion.div>
                    </div>
                </section>

                <section className="stats">
                    <div className="flex justify-between w-full">
                        <div className="stat-item">
                            <h3 className="text-accent">1.2ms</h3>
                            <p>Avg Latency</p>
                        </div>
                        <div className="stat-item">
                            <h3 className="text-accent">50k+</h3>
                            <p>Concurrent Nodes</p>
                        </div>
                        <div className="stat-item">
                            <h3 className="text-accent">Zero</h3>
                            <p>Packet Loss</p>
                        </div>
                    </div>
                </section>

                <section className="cta">
                    <h2 className="display">Join the Grid</h2>
                    <div className="flex gap-8 mt-8">
                        <a href="https://discord.gg/zedox" className="btn-link">DISCORD</a>
                        <a href="https://github.com/zedox" className="btn-link">GITHUB</a>
                    </div>
                </section>
            </main>

            <style jsx>{`
        .app-container {
          position: relative;
        }
        .canvas-wrapper {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100vh;
          z-index: 0;
          pointer-events: none;
        }
        main {
          position: relative;
          z-index: 10;
        }
        .flex { display: flex; }
        .justify-between { justify-content: space-between; }
        .gap-8 { gap: 2rem; }
        .mt-8 { margin-top: 2rem; }
        .stat-item h3 { font-size: 3rem; }
        .stat-item p { color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.2em; font-size: 0.8rem; }
        .btn-link {
          color: var(--fg);
          text-decoration: none;
          padding: 10px 30px;
          border: 1px solid rgba(255, 255, 255, 0.1);
          background: rgba(255, 255, 255, 0.05);
          transition: all 0.3s;
          font-family: var(--font-display);
          font-size: 0.8rem;
        }
        .btn-link:hover {
          background: var(--accent);
          color: var(--bg);
          border-color: var(--accent);
          box-shadow: 0 0 20px var(--accent);
        }
      `}</style>
        </div>
    );
}

export default App;
