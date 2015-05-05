% Test all drum sounds
function TestDrumSounds()
    [Crash, HfHat, Kick, Rim, Snare, Tom] = LocateDrumSounds();
    
    play(Crash);
    pause(0.2);
    play(HfHat);
    pause(0.2);
    play(Kick);
    pause(0.2);
    play(Rim);
    pause(0.2);
    play(Snare);
    pause(0.2);
    play(Tom);
end