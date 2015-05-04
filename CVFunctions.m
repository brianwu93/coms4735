% Takes an HSV image and thresholds the image around a desired HSV color.
% The resulting image is a binary image.
function binary = getThresholdImage(image, target)
    % Find all pixels in the image within a range of the target values.
    H = target(1);
    S = target(2);
    V = target(3);

    binary = image(:,:,1) > (H - 0.1) & image(:,:,1) < (H + 0.1) &...
             image(:,:,2) > (S - 0.1) & image(:,:,2) < (S + 0.1) &...
             image(:,:,3) > (V - 0.1) & image(:,:,3) < (V + 0.1);
end

% Find the centroid of the given binary image.
function [x, y] = findCentroid(image)
    area = sum(image(:));
    center_x = 0;
    center_y = 0;
    [row, col] = size(image);
    for i = 1:row
        for j = 1:col
            if image(i, j) == 1
                center_y = center_y + i;
                center_x = center_x + j;
            end

        end
    end

    x = center_x / area;
    y = center_y / area;
end

% Use erosion and dilation to clean the image.
function cleaned_image = getCleanImage(image)
    % Clean the image by using dilation and then erosion
    dilated_image = bwmorph(image, 'dilate', 2);

    % Apply erosion then dilation once to remove the noises
    cleaned_image = bwmorph(dilated_image, 'erode', 2);
end