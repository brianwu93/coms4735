function Drum(URL)
    % First calibrate by identifying the color of the hands to be tracked.
    rgb_image = imread(URL);
    imshow(rgb_image);
    [x, y] = getpts;
    target = impixel(rgb2hsv(rgb_image), x, y);
    
    % Initialize variables to track the centroid of the hands.
    hand1 = [-1 -1];
    hand2 = [-1 -1];
    
    TestDrumSounds();

    % Play the instrument until the program is stopped.
    while 1
        % Pull the image in HSV.
        hsv_image = rgb2hsv(imread(URL));
        
        % Convert image to binary to identify the drum sticks.
        binary = getThresholdImage(hsv_image, target);
        binary = getCleanImage(binary);
        
        % Locate circles that correspond to different drum noises
        % Locate drum stick ends
        % If sticks and circles overlap, play sounds
       
        
        
        % Feature: Allow user to select sound for each pad
        
    end
end