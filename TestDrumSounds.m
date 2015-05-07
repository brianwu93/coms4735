% Test all drum sounds
function TestDrumSounds()
    sounds = LocateDrumSounds();
    
    play(sounds(1,:));
    pause(0.2);
    play(sounds(2,:));
    pause(0.2);
    play(sounds(3,:));
    pause(0.2);
    play(sounds(4,:));
    pause(0.2);
    play(sounds(5,:));
    pause(0.2);
    play(sounds(6,:));
end