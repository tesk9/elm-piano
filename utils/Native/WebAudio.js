var _user$project$Native_WebAudio = function() {

var audioContext = new (window.AudioContext || window.webkitAudioContext)();

var setWave = function(osc) {
    var real = new Float32Array(2);
    var imag = new Float32Array(2);

    real[0] = 0;
    imag[0] = 0;
    real[1] = 1;
    imag[1] = 0;

    if (audioContext.createPeriodicWave) {
        console.log("Creating periodic wave")
        var wave = audioContext.createPeriodicWave(real, imag, {disableNormalization: true});
        osc.setPeriodicWave(wave);
    } else {
        osc.type = 'sine';
    }
}

var oscillator = function(frequency) {
    var oscillator = audioContext.createOscillator();
    var gain = audioContext.createGain();
    gain.gain.value = 0;

    setWave(oscillator)
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
