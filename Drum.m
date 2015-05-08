function Drum()
    global MUSIC;
    global NOTE_INDEX;
    global COUNT;
    global FPS;
    global CENTROIDS;
    COUNT = 0;
    colors = zeros(5, 3);
    % Preload sound components.
    Crash = 'DrumSounds/1.wav';
    HfHat = 'DrumSounds/2.wav';
    Kick = 'DrumSounds/3.wav';
    Rim = 'DrumSounds/4.wav';
    sounds = [Crash; HfHat; Kick; Rim];
    NOTE_INDEX = ['Crash', 'HfHat', 'Kick', 'Rim'];
    MUSIC = cell(4);
    for i = 1:4
        [y,~] = audioread(sounds(i,:));
        MUSIC{i} = y;
    end
    
    % Connect to the webcam.
    vid = videoinput('macvideo', 1);

    % Configure video settings.
    set(vid,'FramesPerTrigger',1);
    set(vid,'TriggerRepeat',Inf);
    set(vid,'ReturnedColorSpace','rgb');
    set(vid,'Timeout',50); %set the Timeout property of VIDEOINPUT object 'vid' to 50 seconds
    triggerconfig(vid, 'Manual');
    fig = figure(1);
    
    % Delay a few seconds to allow camera repositioning
    %pause(3);
    
    % All sounds play to represent start
    %TestDrumSounds();
    
    % Identify the color of the drum sticks to be tracked.
    rgb_image = getsnapshot(vid);
    imshow(rgb_image);
    [x, y] = ginput(1);
    target = impixel(rgb2hsv(rgb_image), x, y);
    colors(1, :) = target(:);
    
    % Identify the color of the drum pads to be tracked.
    imshow(rgb_image);
    [a, b] = ginput(4);
    hsv_image = rgb2hsv(rgb_image);
    for n = 1:4
    	color = impixel(hsv_image, a(n), b(n));
        colors(n+1,:) = color(:);
    end
    
    CENTROIDS = zeros(4,2);
    % Downsample and then convert raw data to HSV.
    hsv_image = imresize(hsv_image, 0.2);
    for n = 1:4
        binary_pad = getSingleColorImage(hsv_image, colors(n+1,:));
        [labeled, num] = bwlabel(binary_pad);
        objects = zeros(num, 1);
        for i = 1:num
            objects(i) = sum(labeled(:) == i);
        end
        num_large_objects = sum(objects > 300);

        if num_large_objects >= 1
            [~, i] = max(objects);
            drumblob = (labeled == i);
        end

        [c1,c2] = findCentroid(drumblob);
        CENTROIDS(n,:) = [c1,c2];
    end

    % Pull from the webcam and execute sound at a timed interval.
    FPS = 20;
    play = timer('TimerFcn', {@PlayDrums, vid, colors}, 'Period', ...
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
    clear functions;
end

function PlayDrums(obj, event, vid, colors)
    global MUSIC;
    global COUNT;
    global FPS;
    global CENTROIDS;
    persistent image;
    persistent current;
    playSound = 1; %
    trigger(vid);
    current = getdata(vid,1,'uint8');
    
    if COUNT > 0
        playSound = 0;
        COUNT = COUNT - 1;
    end
    % Downsample and then convert raw data to HSV.
    current = imresize(current, 0.2);
    hsv_image = rgb2hsv(current);

    % Convert image to binary to identify the sticks.
    binary_stick = getThresholdImage(hsv_image, colors(1,:));
    binary_stick = getCleanImage(binary_stick);

    % Segment the binary image so we can find the two drum sticks.
    [labeled, num] = bwlabel(binary_stick);
    [m,n] = size(labeled);
    binary_image = zeros(m,n);
    objects = zeros(num, 1);
    for i = 1:num
        objects(i) = sum(labeled(:) == i);
    end
    num_large_objects = sum(objects > 300);

    if num_large_objects == 1
        [~, i] = max(objects);
        blob1 = (labeled == i);
        twoSticks = 0;
    elseif num_large_objects >= 2
        [~, i] = max(objects);
        objects(i) = 0;
        [~, j] = max(objects);
        blob1 = (labeled == i);
        blob2 = (labeled == j);
        twoSticks = 1;
    else
        playSound = 0;
    end
    if playSound 
        % Find closest pad centroids to drum stick centroids
        % Display the video showing only the tracking objects
        if twoSticks
            [x1,y1] = findCentroid(blob1);
            [x2,y2] = findCentroid(blob2);
            XI = [x1,y1;x2,y2];
            k = dsearchn(CENTROIDS,XI);
            y1 = MUSIC{k(1)};
            y2 = MUSIC{k(2)};
            sound(y1, 44100);
            sound(y2, 44100);
            binary_image = blob1 + blob2;
        else
            [x1,y1] = findCentroid(blob1);
            XI = [x1,y1];
            k = dsearchn(CENTROIDS,XI);
            y = MUSIC{k(1)};
            sound(y, 44100);
            binary_image = blob1;
        end
        COUNT = FPS/5;
    end
    
    if isempty(image)
       image = imagesc(binary_image);
       title('Drum CV Capture');
    else
       % Only update if needed.
       set(image,'CData', binary_image);
    end
end