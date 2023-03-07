%Generates custom matrix transform for each point in a grid to be used in the Lumerical software.
%One may specify a diagonal refractive index matrix (in cylindrical coordinates) for a material in the Lumerical software,
%  which will be non-diagonal in Cartesian coordinates. Our matrix transform, denote it Q, is position-dependent
%  and tells the software how to put the diagonal cylindrical matrix into Cartesian coordinates such that
%  n_{Cart} = Q^{\dag} n_{cyl, diag} Q



clear 
clc



%sets up a grid of points on the XY plane so the coordinate transform can be calculated at each point


%MYELIN MODEL 

%sizes are specified in micrometers, to convert to meters add e-06 after the value

%sets dimensions of myelin model (specify axon-myelin boundary and myelin-fluid boundary)
myelinRadius = 1;%e-06;     %outer radius of myelin (myelin-fluid boundary)
axonRadius = 0.6;%e-06;     %radius of axon (axon-myelin boundary)

%sets dimensions for simulation region (note axon will be centered in XY plane, and taken to be uniform along the Z axis)
sideLength = 2;%e-06;       %side length of simulation region
height = 2;%e-06;           %height of the simulation region (note this model is independent of Z)



%SET REFRACTIVE INDICES
%these are biologically realistic refractive index values

%biological myelin sheath has been observed to have positive birefringence along radial optical axes with magnitude b ~ 0.011
%radial refractive index of myelin sheath (n_rr)
n_m_radial = 1.451;
%other refractive index of myelin sheath (n_phiphi and n_zz)
n_m_other = 1.440;

%uniform refractive index of axon
n_a = 1.38;

%uniform refractive index of interstitial fluid
n_f = 1.34;



%SETTING UP GRID

%sets resolutions for grid in the XY plane and the Z axis
%note heightPoints specifies the number of cross-section layers that information will be recorded for, for two-dimensional problems Lumerical software requires 2 or more
sidePoints = 801;          %sets number of points along X and Y axes (odd number allows for a point at the origin)
heightPoints =  2;         %sets number of points along Z axis (if there were any significant z dependence, increase this resolution)

%establishes X and Y coordinates of all points in the XY plane of the grid (units of micrometers)
x = linspace(-sideLength/2, sideLength/2, sidePoints);
y = linspace(-sideLength/2, sideLength/2, sidePoints);


%creates descriptive file names to which the refractive index and coordinate transform matrix data will be saved
%this helps keep track of settings -- can include refractive index in title if so desired, etc.
nFileName = "nData_myelinRad" + myelinRadius + "_res" + sidePoints;
UFileName = "UData_myelinRad" + myelinRadius + "_res" + sidePoints;



%GETS COORDINATES FOR EACH POINT IN GRID, SORTS INTO THREE REGIONS

%gets array of coordinates for each point in the two-dimensional grid, and sorts the points into three regions (fluid, myelin, and axon)
    %the array for each region (fluid, myelin, axon, and total) will contain information on all the points in the region
    %each row will correspond to a point, the first column entry being the X index and the second column entry being the Y index
%this is accomplished according to the myelin and axon radii, the simulation side length, and the resolution of the X and Y axes
[fluid, myelin, axon, total] = getRegionCoords(myelinRadius, axonRadius, sideLength, sidePoints);




%FOR EACH POINT, ASSIGNS DIAGONAL REFRACTIVE INDEX MATRIX AND COORDINATE TRANSFORM MATRIX ACCORDING TO REGION
    %each region is processed by its own function to specify the refractive index and coordinates in that region
    %for each output array, the first dimension index specifies the point of that region (e.g., 5th point in the axon region)
        %diagonal refractive index matrices are input as three values along the second dimension of the array
        %full refractive index matrices and all coordinate transform matrices are encoded along the second and third dimensions of the array


%calculates refractive index matrix and coordinate transform matrix according to positive radial birefringence (for each point in the myelin region)

%points in the myelin region will specify positive (n_e > n_o) radial birefringence
    %in cylindrical coordinates the refractive index matrix is n_{cyl} = [n_e, 0, 0; 0, n_o, 0; 0, 0, n_o]
    %input n_e and n_o respectively in the function parameters
%this function returns the diagonal (n_{cylindrical}) and non-diagonal (n_{Cartesian}) refractive index matrices and the coordinate transform matrix U
    %these are all related by n_{Cartesian} = U^{-1} n_{cyl} U; equivalently n_{cyl} = U n_{Cartesian} U^{-1}
[n_list_myelin, U_list_myelin, n_list_myelin_cyl, n_list_myelin_cart_num, n_list_myelin_cart_an] = applyRadialBirefringence(x, y, myelin, n_m_radial, n_m_other); %n_e then n_o



%specifies refractive index matrix and (identity) coordinate transform matrix according to uniform material (for points in the axon and fluid regions)  

%gets refractive index matrix and coordinate transform matrix for each point in axon region
%specify refractive index of axon as parameter
[n_list_axon, U_list_axon] = applyConstantIndex(axon, n_a);

%gets refractive index and matrix transform lists for each coordinate in fluid region
%specify refractive index of fluid as parameter
[n_list_fluid, U_list_fluid] = applyConstantIndex(fluid, n_f);


%COMBINE DATA FROM ALL REGIONS INTO ORIGINAL GRID

%combines data from all regions and formats it back into the format of the original grid
    %refractive index matrices from all three regions are condensed into n_grid
    %coordinate transform matrices from all three regions are condensed into U_grid
    %these are indexed according to the grid -- e.g., the U matrix for the top left point of the grid is U_grid(0,0,:,:)
[n_grid, U_grid, n_grid_cyl, n_grid_cart_num, n_grid_cart_an] = organizeToGrid(sidePoints, fluid, myelin, axon, n_list_fluid, n_list_myelin, n_list_axon, U_list_fluid, U_list_myelin, U_list_axon, n_list_myelin_cyl, n_list_myelin_cart_num, n_list_myelin_cart_an);



%GENERATES GRID FIGURES

%this function generates a figure with 9 subplots, each subplot corresponding to an element of a 3x3 matrix
    %each subplot is the original grid (axes will correspond to sidePoints) shown as a contour map with legend

generateMatrixFigure(n_grid_cart_num, "Refractive index matrix, Cartesian numerical.");    %displays Cartesian refractive index matrix that was found numerically
generateMatrixFigure(n_grid_cart_an, "Refractive index matrix, Cartesian analytical.");     %displays Cartesian refractive index matrix that was found analytically
generateMatrixFigure(U_grid, "Matrix transform.");             %displays coordinate transform matrix



%WRITES DATA TO FILE 

%writes diagonal refractive index matrices and coordinate transform matrices to two respective files (input file names as parameters)
    %this function writes files that can be read by Lumerical software (see links in comments in function)
    %data is written to the files for each point in a three-dimensional grid according to grid parameters
    %(note heightPoints specifies number of identical layers of the cross-sectional grid, since there is no z dependence)
[n, U] = writeToFile(n_grid, U_grid, sideLength, sidePoints, height, heightPoints, nFileName, UFileName);



