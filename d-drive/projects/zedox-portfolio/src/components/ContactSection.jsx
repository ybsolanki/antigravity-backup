import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { MessageSquare, Send, CheckCircle2, Copy, Check, MessageCircle, Github, Mail } from 'lucide-react';
import { PORTFOLIO_DATA } from '../data/portfolioData';
import { sound } from '../utils/audioEngine';

const ContactSection = () => {
  const { profile } = PORTFOLIO_DATA;
  const [formData, setFormData] = useState({ name: '', email: '', message: '' });
  const [copied, setCopied] = useState(false);
  const [sent, setSent] = useState(false);
  const [isSending, setIsSending] = useState(false);

  const handleCopyDiscord = () => {
    navigator.clipboard.writeText(profile.discordTag);
    sound.playClick(1000, 0.05);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.name || !formData.message) return;

    setIsSending(true);
    sound.playLaser();

    setTimeout(() => {
      setIsSending(false);
      setSent(true);
      sound.playPowerUp();
    }, 800);
  };

  return (
    <section className="container section-spacing" id="contact">
      <div style={{ marginBottom: '3rem', textAlign: 'center' }}>
        <div className="inline-flex items-center gap-2" style={{ marginBottom: '0.4rem' }}>
          <span className="telemetry-dot" style={{ backgroundColor: 'var(--accent-cyan)' }} />
          <span style={{ color: 'var(--accent-cyan)', fontWeight: 'bold', fontSize: '0.8rem', letterSpacing: '2px', textTransform: 'uppercase' }}>
            Get In Touch
          </span>
        </div>
        <h2 style={{ fontSize: 'clamp(1.85rem, 4.5vw, 3rem)' }}>
          CONTACT & <span className="text-gradient">COLLABORATION</span>
        </h2>
        <p style={{ color: 'var(--text-muted)', fontSize: '0.92rem', maxWidth: '520px', margin: '0.4rem auto 0' }}>
          Available for freelance projects, Roblox game scripting, Android app development, and tech collaborations.
        </p>
      </div>

      <div className="grid grid-cols-1 grid-md-2 gap-6" style={{ maxWidth: '1000px', margin: '0 auto' }}>
        {/* Left Side: Direct Channels (Discord & GitHub) */}
        <div className="flex flex-col gap-5">
          {/* Discord Card */}
          <motion.div
            whileHover={{ y: -4 }}
            className="glass-panel"
            style={{
              padding: '1.75rem',
              borderColor: 'rgba(99, 102, 241, 0.35)',
              background: 'rgba(15, 18, 38, 0.8)'
            }}
          >
            <div className="flex items-center gap-3" style={{ marginBottom: '1rem' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '10px',
                  background: 'rgba(99, 102, 241, 0.2)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#818cf8'
                }}
              >
                <MessageCircle size={22} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.15rem', color: '#ffffff' }}>Discord Priority Channel</h3>
                <span style={{ fontSize: '0.72rem', color: '#818cf8', fontFamily: 'var(--font-mono)' }}>
                  FASTEST RESPONSE
                </span>
              </div>
            </div>

            <p style={{ color: 'var(--text-muted)', fontSize: '0.88rem', marginBottom: '1.25rem' }}>
              Direct message for project briefs, game mechanics consulting, and tech discussions.
            </p>

            <div className="flex flex-wrap gap-2.5">
              <button
                onClick={() => {
                  sound.playClick();
                  window.open(profile.discordUrl, '_blank');
                }}
                className="btn btn-violet btn-sm flex-1"
              >
                OPEN DISCORD
              </button>

              <button
                onClick={handleCopyDiscord}
                className="btn btn-outline btn-sm"
                title="Copy Handle"
              >
                {copied ? <Check size={13} style={{ color: '#10b981' }} /> : <Copy size={13} />}
                {copied ? 'COPIED!' : profile.discordTag}
              </button>
            </div>
          </motion.div>

          {/* GitHub Card */}
          <motion.div
            whileHover={{ y: -4 }}
            className="glass-panel"
            style={{
              padding: '1.75rem',
              borderColor: 'rgba(255, 255, 255, 0.1)'
            }}
          >
            <div className="flex items-center gap-3" style={{ marginBottom: '1rem' }}>
              <div
                style={{
                  width: '42px',
                  height: '42px',
                  borderRadius: '10px',
                  background: 'rgba(255, 255, 255, 0.06)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#ffffff'
                }}
              >
                <Github size={22} />
              </div>
              <div>
                <h3 style={{ fontSize: '1.15rem', color: '#ffffff' }}>GitHub Profile</h3>
                <span style={{ fontSize: '0.72rem', color: 'var(--text-dim)', fontFamily: 'var(--font-mono)' }}>
                  OPEN SOURCE REPOSITORIES
                </span>
              </div>
            </div>

            <p style={{ color: 'var(--text-muted)', fontSize: '0.88rem', marginBottom: '1.25rem' }}>
              Explore my code repositories, open-source projects, and experiments.
            </p>

            <a
              href={profile.githubUrl}
              target="_blank"
              rel="noreferrer"
              className="btn btn-outline btn-sm"
              style={{ width: '100%' }}
              onClick={() => sound.playClick()}
            >
              VISIT GITHUB (@ybsolanki)
            </a>
          </motion.div>
        </div>

        {/* Right Side: Message Form */}
        <div
          className="glass-panel"
          style={{
            padding: '1.75rem',
            borderColor: 'rgba(0, 240, 255, 0.25)',
            boxShadow: '0 20px 45px rgba(0,0,0,0.8), 0 0 25px rgba(0, 240, 255, 0.08)'
          }}
        >
          <div className="flex items-center gap-2" style={{ marginBottom: '1.25rem', paddingBottom: '0.65rem', borderBottom: '1px solid rgba(255, 255, 255, 0.08)' }}>
            <span className="telemetry-dot" />
            <h3 style={{ fontSize: '1.1rem', color: '#f8fafc' }}>
              Send a Message
            </h3>
          </div>

          {sent ? (
            <motion.div
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              style={{ textAlign: 'center', padding: '2.5rem 1rem' }}
            >
              <div
                style={{
                  width: '52px',
                  height: '52px',
                  borderRadius: '50%',
                  background: 'rgba(16, 185, 129, 0.2)',
                  border: '1px solid #10b981',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  margin: '0 auto 1.25rem',
                  color: '#10b981'
                }}
              >
                <CheckCircle2 size={28} />
              </div>
              <h4 style={{ fontSize: '1.25rem', color: '#ffffff', marginBottom: '0.35rem' }}>
                MESSAGE SENT
              </h4>
              <p style={{ color: 'var(--text-muted)', fontSize: '0.85rem', marginBottom: '1.25rem' }}>
                Thanks for reaching out! I will get back to you as soon as possible.
              </p>
              <button
                onClick={() => setSent(false)}
                className="btn btn-outline btn-sm"
              >
                SEND ANOTHER MESSAGE
              </button>
            </motion.div>
          ) : (
            <form onSubmit={handleSubmit} className="flex flex-col gap-3.5">
              <div>
                <label style={{ display: 'block', fontSize: '0.72rem', color: 'var(--text-dim)', marginBottom: '0.3rem', fontFamily: 'var(--font-mono)' }}>
                  YOUR NAME
                </label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  placeholder="e.g. Alex"
                  style={{
                    width: '100%',
                    padding: '0.65rem 0.9rem',
                    background: 'rgba(0,0,0,0.5)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    borderRadius: 'var(--radius-sm)',
                    color: '#ffffff',
                    fontFamily: 'var(--font-body)',
                    outline: 'none'
                  }}
                  onFocus={() => sound.playHover(700, 0.02)}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '0.72rem', color: 'var(--text-dim)', marginBottom: '0.3rem', fontFamily: 'var(--font-mono)' }}>
                  EMAIL OR DISCORD HANDLE
                </label>
                <input
                  type="text"
                  required
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="e.g. alex@example.com or user#1234"
                  style={{
                    width: '100%',
                    padding: '0.65rem 0.9rem',
                    background: 'rgba(0,0,0,0.5)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    borderRadius: 'var(--radius-sm)',
                    color: '#ffffff',
                    fontFamily: 'var(--font-body)',
                    outline: 'none'
                  }}
                  onFocus={() => sound.playHover(750, 0.02)}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: '0.72rem', color: 'var(--text-dim)', marginBottom: '0.3rem', fontFamily: 'var(--font-mono)' }}>
                  MESSAGE
                </label>
                <textarea
                  required
                  rows={3}
                  value={formData.message}
                  onChange={(e) => setFormData({ ...formData, message: e.target.value })}
                  placeholder="Describe your project inquiry or collaboration..."
                  style={{
                    width: '100%',
                    padding: '0.65rem 0.9rem',
                    background: 'rgba(0,0,0,0.5)',
                    border: '1px solid rgba(255, 255, 255, 0.1)',
                    borderRadius: 'var(--radius-sm)',
                    color: '#ffffff',
                    fontFamily: 'var(--font-body)',
                    outline: 'none',
                    resize: 'vertical'
                  }}
                  onFocus={() => sound.playHover(800, 0.02)}
                />
              </div>

              <button
                type="submit"
                disabled={isSending}
                className="btn btn-primary"
                style={{ width: '100%', marginTop: '0.25rem', padding: '0.7rem' }}
              >
                <Send size={14} />
                {isSending ? 'SENDING...' : 'SEND MESSAGE'}
              </button>
            </form>
          )}
        </div>
      </div>
    </section>
  );
};

export default ContactSection;
