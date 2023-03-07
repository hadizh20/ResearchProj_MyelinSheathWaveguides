
%This function generates a figure which depicts the value of each matrix element for each point in a two-dimensional grid.
%Plots are made using a contour map and a legend matching color to value.

%Inputs required:
    %four-dimensional array (matrix, A x B x 3 x 3 double where A and B are integers),
    %name for figure (figureName, String).

%Output:
    %generates a figure with a 3x3 grid of subplots with x axis 1:A and y axis 1:B with title figureName.

function generateMatrixFigure(matrix, figureName)
    
    figure("Name", figureName);                   %generates figure with specified name

    subplot(3,3,1), imagesc(matrix(:,:,1,1));     %plots top left element
    colorbar                                      %legend

    subplot(3,3,2), imagesc(matrix(:,:,1,2));     %top middle element
    colorbar

    subplot(3,3,3), imagesc(matrix(:,:,1,3));     %top right element
    colorbar

    subplot(3,3,4), imagesc(matrix(:,:,2,1));     %middle left element
    colorbar

    subplot(3,3,5), imagesc(matrix(:,:,2,2));     %center element
    colorbar

    subplot(3,3,6), imagesc(matrix(:,:,2,3));     %middle right element
    colorbar

    subplot(3,3,7), imagesc(matrix(:,:,3,1));     %bottom left element
    colorbar

    subplot(3,3,8), imagesc(matrix(:,:,3,2));     %bottom middle element
    colorbar

    subplot(3,3,9), imagesc(matrix(:,:,3,3));     %bottom right element
    colorbar


end
