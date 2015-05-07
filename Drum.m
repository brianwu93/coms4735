function Drum(URL)

    TestDrumSounds();
  
    sounds = LocateDrumSounds();
    
    XI = zeros(2,2);

    % If it hit: size of orange ball
    % where it hit: sectioned region of the image
    
    % Feature: Allow user to select sound for each pad
    
    % Delay a few seconds to allow camera repositioning
    pause(3);
    
    % Identify the color of the drum sticks to be tracked.
    rgb_image = imread(URL);
    imshow(rgb_image);
    [x, y] = getpts;
    hsv_image = rgb2hsv(rgb_image);
    target = impixel(hsv_image, x, y);
    
    % Identify all 6 drum pads
    imshow(rgb_image);
    [a, b] = getpts;
    X = [a, b];
%     hsv_image = rgb2hsv(rgb_image);
%     d = zeros(1,5);
%     for n = 1:6
%     	d(n) = impixel(hsv_image, a(n), b(n));
%     end


    
    % Play the instrument until the program is stopped.
    %while 1
        % Pull the image in HSV.
       % hsv_image = rgb2hsv(snapshot(cam));
        
        % Convert image to binary to identify the sticks.
        binary = getThresholdImage(hsv_image, target);
        binary = getCleanImage(binary);
        
        % Erode to remove noise
        se = strel('disk', 7);        
        eroded = imerode(binary, se);
    
        % Segment the binary image so we can find the two drum sticks.
        [labeled, num] = bwlabel(eroded);
        if num == 2
            blob1 = (labeled == 1);
            blob2 = (labeled == 2);
            XI(1,:) = findCentroid(blob1);
            XI(2,:) = findCentroid(blob2);
            XI;
        elseif num < 2
            imshow(eroded);
            disp('Less than two drum sticks detected.');
            %continue;
        else
              % computationally expensive...
%             while num > 2
%                 CC = bwconncomp(binary);
%                 numPixels = cellfun(@numel,CC.PixelIdxList);
%                 [~,idx] = min(numPixels);
%                 binary(CC.PixelIdxList{idx}) = 0;
%             end
            imshow(eroded);
            disp('More than two drum sticks detected.');
            %continue;
        end
        
        %IDX = knnsearch(X,Y);
        k = dsearchn(X,XI);
        
        
        play(sounds(k(1),:));
        play(sounds(k(2),:));
        
     
        % Locate circles that correspond to different drum noises
        % Locate drum stick ends
        % If sticks and circles overlap, play sounds
       
        
        
   % end
end