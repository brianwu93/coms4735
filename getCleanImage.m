% Use erosion and dilation to clean the image.
function cleaned_image = getCleanImage(image)
    % Clean the image by using dilation and then erosion
    dilated_image = bwmorph(image, 'dilate', 8);

    % Apply erosion then dilation once to remove the noises
    cleaned_image = bwmorph(dilated_image, 'erode', 8);
end