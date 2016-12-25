var _user$project$Native_WebAudio = function() {

var audioContext = new (window.AudioContext || window.webkitAudioContext)();

var oscillator = function(frequency) {
    var oscillator = audioContext.createOscillator();
    var gain = audioContext.createGain();
    gain.gain.value = 0;

    oscillator.type = 'sine';
    oscillator.frequency.value = frequency; // value in hertz
    oscillator.connect(gain);
    gain.connect(audioContext.destination);
    gain.gain.setTargetAtTime(1, audioContext.currentTime, 0.015);
    oscillator.start();
    return gain;
}

return {
    oscillator: oscillator,
    stop: function(gainNode) {
        gainNode.gain.setTargetAtTime(0, audioContext.currentTime, 0.015);
    },
};
}();
