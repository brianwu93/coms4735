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

% Locate drum sound files
function [Crash, HfHat, Kick, Rim, Snare, Tom] = LocateDrumSounds()
    Crash = 'DrumSounds/Crash.wav';
    HfHat = 'DrumSounds/HfHat.wav';
    Kick = 'DrumSounds/Kick.wav';
    Rim = 'DrumSounds/Rim.wav';
    Snare = 'DrumSounds/Snare.wav';
    Tom = 'DrumSounds/Tom.wav';
end