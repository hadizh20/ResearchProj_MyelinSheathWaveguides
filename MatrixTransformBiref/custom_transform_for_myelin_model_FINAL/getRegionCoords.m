
%This function generates three matrices (fluidIndices, myelinIndices, axonIndices) which have the coordinate information for every point in their respective region.
%They will each have a number of rows corresponding to the number of grid points in their region, and two columns (to hold the horizontal and vertical grid point coordinates). 
%The totalGrid matrix is also returned, which is a grid with three different element values -- 0 for fluid, 1 for myelin, 2 for axon.
%This is accomplished by specifying dimensions of the model -- myelinRadius, axonRadius, sideLength, sidePoints are all variables described in the main script.


function [fluidIndices, myelinIndices, axonIndices, totalGrid] = getRegionCoords(myelinRadius, axonRadius, sideLength, sidePoints)

    %finds the magnitude of the edge points assuming a center point located at the origin
    maxPoint = (sidePoints - 1)/2; %note maxPoint must be an integer, we have assumed sidePoints is odd to allow for a center point exactly at the origin
    
    %finds the physical distance between two points on the grid
    distancePerPoint = sideLength / (sidePoints-1); 
    
    %finds the distance from the origin to the myelin-fluid boundary (myelinPointRadius) in units of points on the grid
    myelinPointRadius = myelinRadius / distancePerPoint;
    %finds the distance from the origin to the axon-myelin boundary (axonPointRadius) in units of points on the grid
    axonPointRadius = axonRadius / distancePerPoint;
    
    
    %generates x and y point coordinates, equally distributed across the origin
    x = - maxPoint:maxPoint;
    y = - maxPoint:maxPoint; 
    
    %sets up a mesh grid of the x and y point coordinates
    [xx, yy] = meshgrid(x,y); 
    %xx is matrix with all the same rows, columns from -maxPoint to maxPoint
    %yy is matrix with all the same columns, rows from -maxPoint to maxPoint
    %both xx and yy are two-dimensional matrices of sidePoints by sidePoints
    
    %sets up an empty point grid on which myelin points will be identified 
    myelinGrid = zeros(size(xx));
    %sets up an empty point grid on which axon points will be identified
    axonGrid = zeros(size(xx));
    
    %checks if a given point on the grid is less than the myelin-fluid boundary distance from the origin (in grid point units)
    %if it is, assigns a 1 (value for True)
        %note: this will identify the axon region, in addition to the myelin region,
        %this is effective as we will double-count the axon region, and they will be distinct
    myelinGrid((xx.^2+yy.^2)<myelinPointRadius^2)=1;
    %checks if a given point on the grid is less than the axon-myelin boundary distance from the origin (in grid point units)
        %note: this will identify just the axon region on the grid
    axonGrid((xx.^2+yy.^2)<axonPointRadius^2)=1;
    %.^2 is element-wise power 

    
    %sets up a total simulation grid, for each elements adds the corresponding elements of myelinGrid and axonGrid
    %there are three distinct regions on this grid, so we can set different properties for each region
    %a point belongs to the surrounding fluid region if it has value of 0, to the myelin region if it has value of 1, 
        %to the axon region if it has value of 2
    totalGrid = myelinGrid + axonGrid;
    
    %this prints totalGrid, good for a snapshot of the resolution
    %figure(1)
    %imagesc(totalGrid);
    %colorbar;
    
    %sets up three matrices to hold the point coordinates for each of the three regions
        %sets up matrices with enough rows for each of the points in totalGrid (extreme case for a single region, makes code more efficient to set maximum size up front)
        %each row has two entries (each matrix has two columns), the first will contain the horizontal point coordinate, the second will contain the vertical point coordinate
        %a matrix like this is set up for each region, which will contain the coordinates of every point belonging in that region
    fluidIndices = zeros(size(totalGrid,1)*size(totalGrid,2), 2); %fluid region
    myelinIndices = zeros(size(totalGrid,1)*size(totalGrid,2), 2); %myelin region
    axonIndices = zeros(size(totalGrid,1)*size(totalGrid,2), 2); %axon region
    
    %initializes a variable for every region to describe the index (row number in above matrices) that the next point found for that region will have
    fluidNum = 1; %fluid region
    myelinNum = 1; %myelin region
    axonNum = 1; %axon region
    

    %these loops populate the coordinate matrices
    %traverses every row in totalGrid
    for i = 1:length(totalGrid(:,1))
        %traverses every column in totalGrid
        for j = 1:length(totalGrid(1,:))
            
            %reads the element value of totalGrid at the current location (loops above will traverse through all elements)
            %recall: 0 = fluid, 1 = myelin, 2 = axon
            ele = totalGrid(i,j);
            
            %if the point is in the fluid region
            if ele == 0
                %in the row fluidNum, sets the first entry to be the horizontal point coordinate
                fluidIndices(fluidNum, 1) = i;
                %in the row fluidNum, sets the second entry to be the vertical point coordinate
                fluidIndices(fluidNum, 2) = j;
                %increments fluidNum so it will move to the next row for the next point found in the fluid region
                fluidNum = fluidNum + 1;
            %if the point is in the myelin region
            elseif ele == 1
                %in the row myelinNum, sets the first entry to be the horizontal point coordinate
                myelinIndices(myelinNum, 1) = i;
                %in the row myelinNum, sets the second entry to be the vertical point coordinate
                myelinIndices(myelinNum, 2) = j;
                %increments myelinNum so it will move to the next row for the next point found in the myelin region
                myelinNum = myelinNum + 1;
            %if the point is in the axon region
            elseif ele == 2
                %in the row axonNum, sets the first entry to be the horizontal point coordinate
                axonIndices(axonNum, 1) = i;
                %in the row axonNum, sets the second entry to be the vertical point coordinate
                axonIndices(axonNum, 2) = j;
                %increments axonNum so it will move to the next row for the next point found in the axon region
                axonNum = axonNum + 1;
            end
    
        end
    end


    %these three loops below go through each of the matrices containing the point coordinates for a region
    %they are intended to shorten each of the coordinate matrices because they were each initialized to have more rows
        %(corresponding to more grid points) than would be needed (each having sidePoints*sidePoints rows)

    %upon further thought, this may have the unintended consequence of cutting everything after it finds a point
        %in the region of interest that lies along centered the vertical line x = 0 in point units
    %this doesn't appear to be happening in the larger code however, as each point in the 801x801 grid
        %is assigned a value and a transform matrix U

    a = 1;
    found = 0;

    while a < size(fluidIndices, 1) && found == 0
        if fluidIndices(a, 1) == 0
            fluidIndices = fluidIndices(1:a-1,1:2);
            found = 1;
        end
        a = a + 1;
    end

    a = 1;
    found = 0;

    while a < size(myelinIndices, 1) && found == 0
        if myelinIndices(a, 1) == 0
            myelinIndices = myelinIndices(1:a-1,1:2);
            found = 1;
        end
        a = a + 1;
    end

    a = 1;
    found = 0;

    while a < size(axonIndices, 1) && found == 0
        if axonIndices(a, 1) == 0
            axonIndices = axonIndices(1:a-1,1:2);
            found = 1;
        end
        a = a + 1;
    end








end



