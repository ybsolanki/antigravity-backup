import React, { useState, useEffect } from 'react';
import ThreeBackground from './components/ThreeBackground';
import Navbar from './components/Navbar';
import HeroSection from './components/HeroSection';
import AboutSection from './components/AboutSection';
import ShowreelPresentation from './components/ShowreelPresentation';
import ProjectShowcase from './components/ProjectShowcase';
import ZeroGravitySandbox from './components/ZeroGravitySandbox';
import SkillMatrix from './components/SkillMatrix';
import ExperienceTimeline from './components/ExperienceTimeline';
import InteractiveTerminal from './components/InteractiveTerminal';
import ContactSection from './components/ContactSection';
import Footer from './components/Footer';

function App() {
  const [showreelOpen, setShowreelOpen] = useState(false);
  const [isZeroG, setIsZeroG] = useState(false);
  const [isScanlines, setIsScanlines] = useState(false);

  // Ensure page always opens at the very top (Hero section)
  useEffect(() => {
    if (!window.location.hash) {
      window.scrollTo(0, 0);
    }
  }, []);

  const toggleZeroG = () => {
    setIsZeroG(prev => !prev);
  };

  const toggleScanlines = () => {
    setIsScanlines(prev => !prev);
  };

  return (
    <div className={`portfolio-root ${isScanlines ? 'scanlines-active' : ''}`} style={{ minHeight: '100vh', position: 'relative' }}>
      {/* Dynamic 3D WebGL Particle Universe */}
      <ThreeBackground zeroGravity={isZeroG} />

      {/* Floating Glass Navigation Header */}
      <Navbar
        onOpenShowreel={() => setShowreelOpen(true)}
        onToggleZeroG={toggleZeroG}
        isZeroG={isZeroG}
        onToggleScanlines={toggleScanlines}
        isScanlines={isScanlines}
      />

      {/* Hero Section (Always First on Open) */}
      <HeroSection onOpenShowreel={() => setShowreelOpen(true)} />

      {/* Flagship Video/Keynote Showreel Deck Modal */}
      <ShowreelPresentation
        isOpen={showreelOpen}
        onClose={() => setShowreelOpen(false)}
      />

      {/* Dedicated About Yug Solanki & Student Background */}
      <AboutSection onOpenShowreel={() => setShowreelOpen(true)} />

      {/* Projects Showcase with Live In-Card Simulators */}
      <ProjectShowcase onOpenShowreel={() => setShowreelOpen(true)} />

      {/* Interactive Zero-G Physics Sandbox */}
      <ZeroGravitySandbox />

      {/* Technical Skill Matrix */}
      <SkillMatrix />

      {/* Learning Journey & Project Milestones */}
      <ExperienceTimeline />

      {/* Embedded Portfolio CLI Terminal */}
      <InteractiveTerminal
        onOpenShowreel={() => setShowreelOpen(true)}
        onToggleZeroG={toggleZeroG}
        onToggleScanlines={toggleScanlines}
      />

      {/* Direct Contact & Collaboration Center */}
      <ContactSection />

      {/* Footer */}
      <Footer onOpenShowreel={() => setShowreelOpen(true)} />
    </div>
  );
}

export default App;
