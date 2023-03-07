
%This function organizes all the matrices containing the n data (refractive index) and U data (matrix transform) back into the form of the grid to be used in Lumerical software.
%This function takes the coordinate matrices of each of the regions (fluid, myelin, axon) and the corresponding n and U matrices for each of the regions, to arrange them in two overall matrices n_grid and U_grid.
%The final n and U matrices will define n and U data at each sample point in the 801x801 grid across the cross-section of the model.
%This function also populates additional final matrices n_grid_cyl, n_grid_cart_num, and n_grid_cart_an such that it is convenient to view the n data in different ways later on.
%Note that the Cartesian n matrix is never input to the Lumerical software, but it is nice to have to see what is going on and as a figure in the paper.


function [n_grid, U_grid, n_grid_cyl, n_grid_cart_num, n_grid_cart_an] = organizeToGrid(sidePoints, fluid, myelin, axon, n_list_fluid, n_list_myelin, n_list_axon, U_list_fluid, U_list_myelin, U_list_axon, n_list_myelin_cyl, n_list_myelin_cart_num, n_list_myelin_cart_an)

    %makes a matrix with the first two dimensions forming the grid (sidePoints by sidePoints), 
        %the third dimension allows 3 entries for each grid point, which are the elements of the diagonal refractive index matrix 
    n_grid = zeros(sidePoints, sidePoints, 3);

    %makes a matrix with the first two dimensions forming the grid (sidePoints by sidePoints),
        %the third and fourth dimensions allow for a 3x3 matrix to be assigned to each grid point,
        %which is the transform matrix U for each point, which must be specified into Lumerical software 
    U_grid = zeros(sidePoints, sidePoints, 3, 3);


    %similarly makes a matrix with first and second dimensions corresponding to the grid,
        %third and fourth dimensions allow each grid point to have a 3x3 diagonal/cylindrical refractive index matrix assigned to it
    n_grid_cyl = zeros(sidePoints, sidePoints, 3, 3);

    %similarly makes a matrix with first and second dimensions corresponding to the grid,
        %third and fourth dimensions allow each grid point to have a 3x3 Cartesian refractive index matrix assigned to it
        %this Cartesian refractive index matrix for the myelin region will be as found from the matrix multiplication in the applyRadialBirefringence function
    n_grid_cart_num = zeros(sidePoints, sidePoints, 3, 3);

    %similarly makes a matrix with first and second dimensions corresponding to the grid,
        %third and fourth dimensions allow each grid point to have a 3x3 Cartesian refractive index matrix assigned to it
        %the Cartesian refractive index matrix for the myelin region will be as found from the direct expression in the applyRadialBirefringence function
    n_grid_cart_an = zeros(sidePoints, sidePoints, 3, 3);


    
    %traverses through all the points in the fluid region
    for i = 1:length(fluid(:,1))

        %extracts the point x position of the point
        xIndex = fluid(i, 1);
        %extracts the point y position of the point
        yIndex = fluid(i, 2);
        
        %finds the 3 entries constituting the diagonal refractive index matrix at this point
        n = n_list_fluid(i, 1:3);
        %saves these 3 entries at the appropriate fluid point in the grid
        n_grid(xIndex, yIndex, 1:3) = n;
    
        %finds the 3x3 transform matrix at this point
        U = U_list_fluid(i, 1:3, 1:3);
        %saves this 3x3 transform matrix at the appropriate fluid point in the grid
        U_grid(xIndex, yIndex, 1:3, 1:3) = U;
        
        %saves the 3 entries constituting the diagonal refractive index matrix at this point,
            %as a 3x3 diagonal matrix -- while n_list_cyl contains the same information as n_list,
            %it saves it as a 3x3 matrix at the appropriate point (in this loop, in the fluid region)
        n_grid_cyl(xIndex, yIndex, 1:3, 1:3) = [ n(1), 0, 0; 0, n(2), 0; 0, 0, n(3)];
        
        %creates a 3x3 diagonal refractive matrix for the point
        %note this matrix is diagonal and yet in Cartesian coordinates because we are in the fluid region (not the myelin region)
        n_matrix = [ n(1), 0, 0; 0, n(2), 0; 0, 0, n(3)];

        %saves the 3x3 Cartesian matrix for this point to the appropriate fluid point in the grid holding ("numerical") Cartesian refractive index matrices
        n_grid_cart_num(xIndex, yIndex, 1:3, 1:3) = n_matrix;
        
        %saves the 3x3 Cartesian matrix for this point to the appropriate fluid point in the grid holding ("analytical") Cartesian refractive index matrices 
        n_grid_cart_an(xIndex, yIndex, 1:3, 1:3) = n_matrix;


    end
    
    %traverses through all the points in the myelin region
    for i = 1:length(myelin(:,1))

        %extracts the point x position of the point
        xIndex = myelin(i, 1);
        %extracts the point y position of the point
        yIndex = myelin(i, 2);
        
        %finds the 3 entries constituting the diagonal refractive index matrix at this point
        n = n_list_myelin(i, 1:3);
        %saves these 3 entries at the appropriate myelin point in the grid
        n_grid(xIndex, yIndex, 1:3) = n;
        
        %finds the 3x3 transform matrix at this point
        U = U_list_myelin(i, 1:3, 1:3);
        %saves this 3x3 transform matrix at the appropriate myelin point in the grid
        U_grid(xIndex, yIndex, 1:3, 1:3) = U;
        
        %saves the 3 entries constituting the diagonal refractive index matrix at this point,
            %as a 3x3 diagonal matrix -- while n_list_cyl contains the same information as n_list,
            %it saves it as a 3x3 matrix at the appropriate point (in this loop, in the myelin region).
            %for redundancy we take this 3x3 cylindrical matrix from the appropriate input of n_list_myelin_cyl
                %which is output from the applyRadialBirefringence function
        n_grid_cyl(xIndex, yIndex, 1:3, 1:3) = n_list_myelin_cyl(i,:,:); %this NEEDS the two colons, if you don't specify this it truncates it weirdly and its wrong
        
        %finds the Cartesian refractive index matrix (found "numerically", see applyRadialBirefringence) for this myelin point
        n_matrix_num = n_list_myelin_cart_num(i,:,:);
        %assigns this matrix to its corresponding point in the grid, into the matrix n_grid_cart_num designated for these matrices  
        n_grid_cart_num(xIndex, yIndex, 1:3, 1:3) = n_matrix_num;
        
        %finds the Cartesian refractive index matrix (found "analytically", see applyRadialBirefringence) for this myelin point
        n_matrix_an = n_list_myelin_cart_an(i,:,:);
        %assigns this matrix to its corresponding point in the grid, into the matrix n_grid_cart_an designated for these matrices  
        n_grid_cart_an(xIndex, yIndex, 1:3, 1:3) = n_matrix_an;

    end
    
    %traverses through all the points in the axon region
    for i = 1:length(axon(:,1))

        %extracts the point x position of the point
        xIndex = axon(i, 1);
        %extracts the point y position of the point
        yIndex = axon(i, 2);
        
        %finds the 3 entries constituting the diagonal refractive index matrix at this point
        n = n_list_axon(i, 1:3);
        %saves these 3 entries at the appropriate axon point in the grid
        n_grid(xIndex, yIndex, 1:3) = n;
        
        %finds the 3x3 transform matrix at this point
        U = U_list_axon(i, 1:3, 1:3);
        %saves this 3x3 transform matrix at the appropriate axon point in the grid
        U_grid(xIndex, yIndex, 1:3, 1:3) = U;
        
        %saves the 3 entries constituting the diagonal refractive index matrix at this point,
            %as a 3x3 diagonal matrix -- while n_list_cyl contains the same information as n_list,
            %it saves it as a 3x3 matrix at the appropriate point (in this loop, in the axon region)
        n_grid_cyl(xIndex, yIndex, 1:3, 1:3) = [ n(1), 0, 0; 0, n(2), 0; 0, 0, n(3)];

        %creates a 3x3 diagonal refractive matrix for the point
        %note this matrix is diagonal and yet in Cartesian coordinates because we are in the axon region (not the myelin region)
        n_matrix = [ n(1), 0, 0; 0, n(2), 0; 0, 0, n(3)];

        %saves the 3x3 Cartesian matrix for this point to the appropriate axon point in the grid holding ("numerical") Cartesian refractive index matrices
        n_grid_cart_num(xIndex, yIndex, 1:3, 1:3) = n_matrix;
    
        %saves the 3x3 Cartesian matrix for this point to the appropriate axon point in the grid holding ("analytical") Cartesian refractive index matrices 
        n_grid_cart_an(xIndex, yIndex, 1:3, 1:3) = n_matrix;

    end
    


end

