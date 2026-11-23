import { Game } from './core/Game.js';

const canvas = document.getElementById('game-canvas');
const game = new Game(canvas);

// Start the game loop
game.start();

// Handle window resize
window.addEventListener('resize', () => {
  game.resize();
});
