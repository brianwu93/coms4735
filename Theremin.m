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
    end
end