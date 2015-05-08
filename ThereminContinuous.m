function ThereminContinuous()
    % Preload sound components.
    global MUSIC;
    global NOTE_INDEX;
    NOTE_INDEX = ['C', 'D', 'E', 'F', 'G', 'A', 'B', 'C'];
    NOTE_FREQ = [261.626, 293.665, 329.628, 349.228, 391.995, 440, 493.883, 523.251];
    Fs = 44100;
    t = 0:1/Fs:0.5;
    MUSIC = cell(8);
    for i = 1:8
        f = NOTE_FREQ(i);
        MUSIC{i} = 5 * sin(2.*pi.*f.*t) .* exp(-7*t);
    end

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
    FPS = 5;
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
    clear functions;
end

function PlayTheremin(obj, event, vid, target)
    persistent image;
    persistent current;
    playSound = 1;
    trigger(vid);
    current =getdata(vid,1,'uint8');

    % Downsample and then convert raw data to HSV.
    current = imresize(current, 0.2);
    hsv_image = rgb2hsv(current);

    % Convert image to binary to identify the hands.
    binary = getThresholdImage(hsv_image, target);
    binary = getCleanImage(binary);

    % Segment the binary image so we can separate the two hands.
    [labeled, num] = bwlabel(binary);
    objects = zeros(num, 1);
    for i = 1:num
        objects(i) = sum(labeled(:) == i);
    end
    num_large_objects = sum(objects > 150);

    if num_large_objects >= 2
        [~, i] = max(objects);
        objects(i) = 0;
        [~, j] = max(objects);
        blob1 = (labeled == i);
        blob2 = (labeled == j);
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
        [height, ~] = size(binary);
        volume = 1.0 - hand1(2) / height;
        pitch = 1.0 - hand2(2) / height;

        % Play the sound.
        playNote(pitch, volume);
    end

    % Display the video showing only the tracking objects.
    if playSound
        binary = blob1 + blob2;
    end
    if isempty(image)
       image =imagesc(binary);
       title('Theremin CV Capture');
    else
       % Only update if needed.
       set(image,'CData', binary);
    end
end

function playNote(pitch, volume)
    global MUSIC;
    global NOTE_INDEX;
    % Figure out the note to play.
    y = MUSIC{ceil(pitch * 8)};
    sound(y .* volume, 44100);

    % Play the sound.
    string = sprintf('Playing %s at %s percent volume.', ...
                     NOTE_INDEX(ceil(pitch * 8)), int2str(volume * 100));
    disp(string);
end