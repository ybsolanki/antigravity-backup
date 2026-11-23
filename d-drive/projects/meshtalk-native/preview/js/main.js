function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    document.getElementById(screenId).classList.add('active');
}

// Simple interaction simulation
document.querySelector('.send-btn').onclick = () => {
    const input = document.querySelector('.input-card input');
    if (input.value) {
        alert('Signal Transmitted: ' + input.value);
        input.value = '';
    }
};
