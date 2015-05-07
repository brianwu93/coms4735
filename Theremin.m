function Theremin()
    % Connect to the webcam.
    vid = videoinput('macvideo', 1);
    
    % Configure video settings.
    set(vid,'FramesPerTrigger',1);
    set(vid,'TriggerRepeat',Inf);
    set(vid,'ReturnedColorSpace','rgb');
    triggerconfig(vid, 'Manual');
    fig = figure(1);
    
    % Calibrate the color tracking.
	rgb_image = getsnapshot(vid);
	imshow(rgb_image);
	[x, y] = ginput(1);
	target = impixel(rgb2hsv(rgb_image), x, y);
    
    % Pull from the webcam and execute sound at a timed interval.
    FPS = 10;
    play = timer('TimerFcn', {@PlayTheremin, vid, target}, 'Period', ...
                 1/FPS, 'ExecutionMode', 'fixedRate', 'BusyMode', 'drop');
             
    % Begin pulling from the webcam.
    start(vid);
    start(play);
    uiwait(fig);

    % Clean up.
    stop(play);
    delete(play);
    stop(vid);
    delete(vid);
end

function PlayTheremin(obj, event, vid, target)
    persistent image;
    persistent current;
    playSound = 1;
    trigger(vid);
    current =getdata(vid,1,'uint8');

    % Convert raw data to HSV.
    hsv_image = rgb2hsv(current);

    % Convert image to binary to identify the hands.
    binary = getThresholdImage(hsv_image, target);
    binary = getCleanImage(binary);

    % Segment the binary image so we can separate the two hands.
    [labeled, num] = bwlabel(binary);
    if num == 2
        blob1 = (labeled == 1);
        blob2 = (labeled == 2);
    elseif num < 2
        %disp('Less than two objects detected.');
        playSound = 0;
    else
        %disp('More than two objects detected.');
        playSound = 0;
    end
    
    if playSound
        hand1 = [-1 -1];
        hand2 = [-1 -1];
        [x1, y1] = findCentroid(blob1);
        [x2, y2] = findCentroid(blob2);
        if x1 < x2
            hand1 = [x1, y1];
            hand2 = [x2, y2];
        else
            hand1 = [x2, y2];
            hand2 = [x1, y1];
        end

        % Determine the pitch and volume relative to hand height.
        height = 720;
        volume = 1.0 - hand1(2) / height;
        pitch = 1.0 - hand2(2) / height;

        % Play the sound.
        play(pitch, volume);
    end

    % Display the video.
    if isempty(image)
       image =imagesc(binary);
       title('Theremin CV Capture');
    else
       % Only update if needed.
       set(image,'CData', binary);
    end
end

function play(pitch, volume)
    % Figure out the note to play.
    filename = strcat('ThereminSounds/', int2str(round(pitch * 8)), '.aif');
    
    % Load the audio file.
    load handel.mat
    [y,Fs] = audioread(filename);
    
    % Scale volume.
    y = y .* volume;
    
    % Play the sound.
    string = ['Playing ', filename, ' at ', volume * 100, '% volume.'];
    disp(string);
    sound(y,Fs);
end