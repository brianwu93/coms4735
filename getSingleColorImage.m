% Use threshold color and image cleaning to get a single color image.
function single_color_image = getSingleColorImage(hsv_image, color)
        single_color_image = getThresholdImage(hsv_image, color);
        single_color_image = getCleanImage(single_color_image);
end