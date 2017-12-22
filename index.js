var piano = Elm.Main.fullscreen()


piano.ports.playNote.subscribe(function(frequency) {
    console.log(frequency);
});

piano.ports.stopNote.subscribe(function(frequency) {
    console.log(frequency)
});
