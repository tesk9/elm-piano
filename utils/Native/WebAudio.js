var _user$project$Native_WebAudio = function() {

var audioContext = new (window.AudioContext || window.webkitAudioContext)();

var oscillator = function(frequency) {
    var oscillator = audioContext.createOscillator();

    oscillator.type = 'sine';
    oscillator.frequency.value = frequency; // value in hertz
    oscillator.connect(audioContext.destination);
    oscillator.start();
    return oscillator.stop
}

return {
    oscillator: oscillator,
};
}();
