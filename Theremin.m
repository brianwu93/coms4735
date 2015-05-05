function Theremin()
    % Connect to the webcam.
    cam = webcam;

    % First calibrate by identifying the color of the hands to be tracked.
    rgb_image = snapshot(cam);
    imshow(rgb_image);
    [x, y] = ginput(1);
    target = impixel(rgb2hsv(rgb_image), x, y);
    
    % Initialize variables to track the centroid of the hands.
    hand1 = [-1 -1];
    hand2 = [-1 -1];
    [height, ~, ~] = size(rgb_image);

    % Play the instrument until the program is stopped.
    while 1
        % Pull the image in HSV.
        hsv_image = rgb2hsv(snapshot(cam));
        
        % Convert image to binary to identify the hands.
        binary = getThresholdImage(hsv_image, target);
        binary = getCleanImage(binary);
        imshow(binary);
    
        % Segment the binary image so we can separate the two hands.
        [labeled, num] = bwlabel(binary);
        if num == 2
            blob1 = (labeled == 1);
            blob2 = (labeled == 2);
        elseif num < 2
            imshow(binary);
            disp('Less than two objects detected.');
            continue;
        else
            imshow(binary);
            disp('More than two objects detected.');
            continue;
        end
        centroid1 = findCentroid(blob1);
        centroid2 = findCentroid(blob2);
        if centroid1(1) < centroid(2)
            hand1 = centroid1;
            hand2 = centroid2;
        else
            hand1 = centroid2;
            hand2 = centroid1;
        end
        
        % Determine the pitch and volume relative to hand height.
        volume = 1.0 - hand1(2) / height;
        pitch = 1.0 - hand2(2) / height;
        
        % Play the sound.
        play(pitch, volume);
    end
end

function play(pitch, volume)
    % Figure out the note to play.
    filename = strcat(int2str(round(pitch * 8)), '.aif');
    
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