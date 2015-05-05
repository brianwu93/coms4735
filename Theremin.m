function Theremin(URL)
    % First calibrate by identifying the color of the hands to be tracked.
    rgb_image = imread(URL);
    imshow(rgb_image);
    [x, y] = getpts;
    target = impixel(rgb2hsv(rgb_image), x, y);
    
    % Initialize variables to track the centroid of the hands.
    hand1 = [-1 -1];
    hand2 = [-1 -1];

    % Play the instrument until the program is stopped.
    while 1
        % Pull the image in HSV.
        hsv_image = rgb2hsv(imread(URL));
        
        % Convert image to binary to identify the hands.
        binary = getThresholdImage(hsv_image, target);
        binary = getCleanImage(binary);
    
        % Segment the binary image so we can separate the two hands.
        [labeled, num] = bwlabel(binary);
        if num == 2
            blob1 = (labeled == 1);
            blob2 = (labeled == 2);
        else
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
        
        % Determine the height of each hand relative to image size.
    end
end

function playInstrument(pitch, volume)
    % Load the audio file.
    load handel.mat
    [y,Fs] = audioread(filename);
    
    % Scale volume.
    y = y .* volume;
    
    % Determine the note to play.
    y = y(1:10000, :);
    sound(y,Fs);
end