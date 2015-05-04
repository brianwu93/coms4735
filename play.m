% Play sounds
% input sound file i.e. filename = 'DrumSounds/Kick.wav';

function play(filename)
    load handel.mat
    [y,Fs] = audioread(filename);
    sound(y,Fs);
end

