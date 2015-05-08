function Drum()
    % Get sounds
    C = cell(1,3);
    sounds = LocateDrumSounds();
    C(1,3) = {sounds};
    
    % Connect to the webcam.
    vid = videoinput('macvideo', 1);

    % Configure video settings.
    set(vid,'FramesPerTrigger',1);
    set(vid,'TriggerRepeat',Inf);
    set(vid,'ReturnedColorSpace','rgb');
    triggerconfig(vid, 'Manual');
    fig = figure(1);
    
    % Delay a few seconds to allow camera repositioning
    pause(3);
    
    % All sounds play to represent start
    TestDrumSounds();
    
    % Identify the color of the drum sticks to be tracked.
    rgb_image = getsnapshot(vid);
    imshow(rgb_image);
    [x, y] = ginput(1);
    target = impixel(rgb2hsv(rgb_image), x, y);
    C(1,1) = {target};
    
    % Identify the color of the drum pads to be tracked.
    imshow(rgb_image);
    [a, b] = ginput(4);
    hsv_image = rgb2hsv(rgb_image);
    pad_colors = zeros(4,3);
    for n = 1:4
    	pad_colors(n,:) = impixel(hsv_image, a(n), b(n));
    end
    C(1,2) = {pad_colors};

    % Pull from the webcam and execute sound at a timed interval.
    FPS = 5;
    play = timer('TimerFcn', {@PlayDrums, vid, C}, 'Period', ...
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

function PlayDrums(obj, event, vid, C)
    persistent image;
    persistent current;
    playSound = 1; %
    twoSticks = 1; %
    trigger(vid);
    current = getdata(vid,1,'uint8');
    binary_pads = zeros(1,4);
    pad_centroids = zeros(4,2);
    target = C{1,1};
    pad_colors = C{1,2};
    sounds = C{1,3};
   
    % Downsample and then convert raw data to HSV.
    current = imresize(current, 0.5);
    hsv_image = rgb2hsv(current);

    % Convert image to binary to identify the sticks.
    binary_stick = getSingleColorImage(hsv_image, target);

%         % Erode to remove noise
%         se = strel('disk', 7);        
%         eroded = imerode(binary, se);

    % Segment the binary image so we can find the two drum sticks.
    [labeled, num] = bwlabel(binary_stick);
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
    else
        playSound = 0;
    end
    
    if playSound   
         % Locate drum pads
        for n = 1:4
            binary_pads(n) = getSingleColorImage(hsv_image, pad_colors(n));
            [labeled, num] = bwlabel(binary_pads(n));
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
             pad_centroids(n,:) = [c1,c2];
        end
        
        % Find closest pad centroids to drum stick centroids
        % Display the video showing only the tracking objects
        if twoSticks
            [x1,y1] = findCentroid(blob1);
            [x2,y2] = findCentroid(blob2);
            XI = [x1,y1;x2,y2];
            k = dsearchn(pad_centroids,XI);
            play(sounds(k(1),:));
            play(sounds(k(2),:));
            binary_image = blob1 + blob2;
        else
            [x1,y1] = findCentroid(blob1);
            XI = [x1,y1];
            k = dsearchn(pad_centroids,XI);
            play(sounds(k(1),:));
            binary_image = blob1;
        end     
    end
    
    if isempty(image)
       image = imagesc(binary_image);
       title('Drum CV Capture');
    else
       % Only update if needed.
       set(image,'CData', binary_image);
    end
end