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