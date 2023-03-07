%This function returns the refractive index matrix data and coordinate transform matrix data for a homogeneous material.
%Homogeneous material will have constant refractive index and no birefringent properties.
%Note this means refractive index matrices will naturally be diagonal (scaled by refractive index) and all coordinate transform matrices will be the identity matrix.

%Inputs required:
    %array of all points in region with refractive index n (materialCoords, A x 2 double where A is number of points in this region of constant index),
    %refractive index for region (n, double).

%Outputs: 
    %array containing diagonal elements of identity matrix scaled by refractive index n, for each region point, to represent uniform refractive index for region material  (n_list, A x 3 double, where A is number of region points);
    %array containing identity transform matrix for each myelin point (U_list, A x 3 x 3).


function [n_list, U_list] = applyConstantIndex(materialCoords, n)
    
    
    %finds the number of points in the region
    coordNum = length(materialCoords(:,1));

    %makes an array to hold all the diagonal elements of the refractive index matrix for each region point
    n_list = zeros(coordNum,3);
    %makes an array to hold all the coordinate transform matrices for each point
    U_list = zeros(coordNum,3,3);



    %traverses through each region point
    for i = 1:coordNum

        %assigns constant refractive index to each diagonal element for each region point 
        n_list(i, 1:3) = n;

        %assigns identity matrix as coordinate transform matrix for each region point
        %I've included zero imaginary components for the most general case here
        U_list(i, 1, 1) = 1 + 0i;
        U_list(i, 2, 2) = 1 + 0i;
        U_list(i, 3, 3) = 1 + 0i;

    end



end
