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