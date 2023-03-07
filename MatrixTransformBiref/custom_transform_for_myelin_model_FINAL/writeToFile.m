
%This function writes refractive index matrix data and coordinate transform matrix data to two respective files.
%These files are formatted to be read by Lumerical software, for more information see links below.

%Importing custom refractive index data:
%   https://optics.ansys.com/hc/en-us/articles/360034901993-Spatial-n-k-data-Simulation-object

%Importing custom matrix transform:
%   https://optics.ansys.com/hc/en-us/articles/360034915173-Matrix-Transformation-Simulation-object
%(see also Lumerical script files which create a matrix transform object in Lumerical)

%Inputs required: 
    %refractive index matrix data array for cross-sectional grid (n_grid, sidePoints x sidePoints x 3 double),
    %transformation matrix data array for cross-sectional grid (U_grid, sidePoints x sidePoints x 3 x 3 double),
    %physical side length of simulation region (sideLength, double),
    %number of points sampled along side of simulation region (sidePoints, int8),
    %physical height of simulation region (height, double),
    %number of points sampled along height of simulation region (heightPoints, int8),
    %file name for refractive index matrix data file (nFileName, String),
    %file name for matrix transform data file (UFileName, String).

%Ouputs:
    %refractive index matrix data array for three-dimensional volume (n, (sidePoints*sidePoints*heightPoints) x 3 double),
    %transformation matrix data array for three-dimensional volume (U, sidePoints x sidePoints x heightPoints x 3 x 3 double),
    %refractive index data text file will be saved to workspace folder with name: nFileName + ".txt",
    %transform matrix data MATLAB file will be saved to workspace folder with name: UFileName + ".mat".

function [n, U] = writeToFile(n_grid, U_grid, sideLength, sidePoints, height, heightPoints, nFileName, UFileName)



    %IDENTIFIES THE NUMBER OF POINTS IN THE GRID (OR A LAYER)

    %finds the number of points in the two-dimensional grid
    gridPoints = sidePoints^2;


    

    %SETS UP AN ARRAY TO STORE REFRACTIVE INDEX DATA FOR EACH POINT IN THE THREE-DIMENSIONAL VOLUME

    %initializes a list with a row for each point in the three-dimensional volume
    %contains the elements of the diagonal refractive index matrix for each point
    n = zeros((gridPoints*heightPoints), 3);
    
    
    
    
    %SETS UP COUNTER TO INDEX EACH POINT IN THE THREE-DIMENSIONAL VOLUME
    %initializes index to traverse through each point in volume
    pointNum = 1;


    

    %NESTED LOOP TRAVERSES ALL POINTS IN THE GRID (FIRST LAYER) TO SAVE REFRACTIVE INDEX DATA FOR EACH
    for i = 1:sidePoints %traverses row in grid
        for j = 1:sidePoints %traverses column in grid
            
            %populates refractive index list for each point in the volume
            %each row encodes diagonal matrix elements for a grid point
            n(pointNum, 1:3) = n_grid(i,j, 1:3);

            %progresses to next row in refractive index list
            pointNum = pointNum + 1;

        end
    end
    
    
    

    %LOOP ESTABLISHES LAYERS (in amount heightPoints) WITH IDENTICAL REFRACTIVE INDEX MATRIX DATA TO THE INITIAL LAYER
    %NOTE THIS IS IMPLEMENTED SINCE THERE IS NO Z DEPENDENCE
    
    %traverses through layers in three-dimensional volume to save identical refractive index data for heightPoints layers (due to no z dependence)
    for k = 2:heightPoints
        
        %finds the start position for which refractive index data will be added to the array for a new (k-th) layer
        startIndex = gridPoints + 1;
        %finds the stop position which the refractive index data will end at for this current (k-th) layer
        stopIndex = startIndex + gridPoints - 1;

        %sets the refractive index data for the k-th layer as identical to the first layer (due to no z dependence)
        n(startIndex:stopIndex, 1:3) = n(1:gridPoints, 1:3);
        
        %increments the pointNum for a new layer (each layer having number of points gridPoints)
        pointNum = pointNum + gridPoints;

    end


    %old code for heightPoints = 2
%     additionStart = gridPoints + 1;
%     additionStop = additionStart + gridPoints - 1;
% 
%     n(additionStart:additionStop, 1:3) = n(1:gridPoints, 1:3);

    %formats the refractive index matrix data for each point according to requirements from Lumerical software
    %note refractive index matrix data is saved in a textfile 
    
    
    
    
    %ESTABLISHES X, Y, AND Z AXIS INFORMATION TO BE WRITTEN TO THE REFRACTIVE INDEX DATA FILE


    %finds the real dimensions which the leftmost and rightmost points describe (recall axon centered at origin)
    left = - (sideLength / 2);    %leftmost measurement
    right = - left;               %rightmost measurement  
    
    %creates three-element arrays for each dimension to hold the following information:
    %number of points (evenly spaced), minimum measurement value, maximum measurement value
    xDetails = [sidePoints, left, right];    %x information
    yDetails = [sidePoints, left, right];    %y information
    zDetails = [heightPoints, 0, height];    %z information
    
    
    
    
    %OPENS FILE WITH DESCRIPTIVE NAME FOR WRITING, WRITES X AND Y AXIS INFORMATION TO FILE
    
    
    %creates and opens a text file named nFileName, file opened with writing permission ("w")
    n_file = fopen(nFileName + ".txt", "w");
    %n_file = fopen("custom_material.txt", "w");

    %writes three lines which specify the x, y, and z information necessary
    %note this is formatted as desired by Lumerical (commas between these values, new line for each set) 
    fprintf(n_file, "%f,%f,%f\n", xDetails);        %x
    fprintf(n_file, "%f,%f,%f\n", yDetails);        %y
    fprintf(n_file, "%f,%f,%f\n", zDetails);        %z
    
    
    
    
    %TRAVERSES EVERY POINT IN THREE-DIMENSIONAL VOLUME AND WRITES REFRACTIVE INDEX DATA TO FILE
    %Each line 

    
    %traverses through all points in the three-dimensional volume, such that refractive index matrix information is written to file
    for i = 1:size(n)

        %extracts real and imaginary components of each of the diagonal elements in the refractive index matrix for each point
        %note imaginary components are included for generality, in current myelin model all refractive indices should be real
        realxx = real(n(i,1));      %real component of n_xx
        imagxx = imag(n(i,1));      %imaginary component of n_xx
        realyy = real(n(i,2));      %real component of n_yy
        imagyy = imag(n(i,2));      %imaginary component of n_yy
        realzz = real(n(i,3));      %real component of n_zz
        imagzz = imag(n(i,3));      %imaginary component of n_zz

        %writes real and imaginary components in required order (divided by commas)
        %each line holds information for a given point
        fprintf(n_file, "%f,%f,%f,%f,%f,%f\n", realxx, imagxx, realyy, imagyy, realzz, imagzz);

    end

    %closes refractive index matrix data file
    fclose(n_file);

    
    

    %WRITES MATRIX TRANSFORM DATA TO MATLAB FILE


    %creates a new array for the matrix transform that will specify the matrix transform for all points in the three-dimensional volume
    %the first and second dimensions correspond to point indices in the x and y directions, the third dimension now similarly corresponds to point index in the z direction
    %fourth and fifth dimensions will specify the coordinate transform matrix U itself, for the specified point
    U = zeros(size(U_grid,1), size(U_grid,2), heightPoints, size(U_grid, 3), size(U_grid,4));
    
    
    %traverses through all layers in three-dimensional volume to populate matrix transform array
    for k = 1:heightPoints
        
        %sets each layer to have identical matrix transform data as found for the original two-dimensional grid
        U(:,:,k,:,:) = U_grid;

    end
    
    %saves matrix transform data for three-dimensional volume to Matlab file named UFileName
    save(UFileName, "U");




end

