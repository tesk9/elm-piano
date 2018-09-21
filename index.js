var piano = Elm.Main.init({
    node: document.getElementById("elm-node")
})

var Piano = Player()

piano.ports.playNote.subscribe(function(frequency) {
    Piano.play(frequency);
});

piano.ports.stopNote.subscribe(function(frequency) {
    Piano.stop(frequency)
});

function Player() {
    var audioContext = new (window.AudioContext || window.webkitAudioContext)();

    var playing = {};

    var setWave = function(osc) {
        var real = new Float32Array(2);
        var imag = new Float32Array(2);

        real[0] = 0;
        imag[0] = 0;
        real[1] = 1;
        imag[1] = 0;

        if (audioContext.createPeriodicWave) {
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
        playing[frequency] = gain;
    }

    var stop = function(frequency) {
        var gainNode = playing[frequency];
        if(gainNode) {
            gainNode.gain.setTargetAtTime(0, audioContext.currentTime, 0.015);
        }
        playing[frequency] = null;
    }

    return {
        play: oscillator,
        stop: stop,
    };
};
