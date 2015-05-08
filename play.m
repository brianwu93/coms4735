% Play sounds
% input sound file i.e. filename = 'DrumSounds/Kick.wav';

function play(filename)
    [y,Fs] = audioread(filename);
    sound(y,Fs);
end