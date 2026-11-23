import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';

const Preloader = () => {
    const [progress, setProgress] = useState(0);

    useEffect(() => {
        const interval = setInterval(() => {
            setProgress((oldProgress) => {
                if (oldProgress === 100) {
                    clearInterval(interval);
                    return 100;
                }
                const diff = Math.random() * 10;
                return Math.min(oldProgress + diff, 100);
            });
        }, 100);

        return () => clearInterval(interval);
    }, []);

    return (
        <motion.div
            className="preloader"
            exit={{ y: '-100%' }}
            transition={{ duration: 1.2, ease: [0.76, 0, 0.24, 1] }}
        >
            <div className="preloader-count">
                {Math.round(progress)}
            </div>
            <div className="preloader-bar">
                <motion.div
                    className="preloader-progress"
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                />
            </div>
            <p style={{ marginTop: '20px', letterSpacing: '0.5em', fontSize: '10px', color: '#444' }}>
                INITIALIZING ZEDOX CORE
            </p>
        </motion.div>
    );
};

export default Preloader;
