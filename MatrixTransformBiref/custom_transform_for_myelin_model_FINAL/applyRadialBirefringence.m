
%This function applies radial birefringence to the collection of points in the myelin region.
%It obtains refractive index matrix and coordinate transformation matrix data for each point.

%Note this was loosely modelled after an example from the Lumerical website (treats non-diagonal refractive index matrix case), see link:
    %   https://support.lumerical.com/hc/en-us/articles/360034915173-Matrix-Transformation-Simulation-object

%Inputs required:
    %x position array (x, 1 x sidePoints double),
    %y position array (y, 1 x sidePoints double),
    %array of all points in myelin grid region by index (myelinPoints, A x 2 double, where A is the number of points within the myelin region),
    %extraordinary refractive index (n_e, double),
    %ordinary refractive index (n_o, double).

%Outputs: 
    %array containing diagonal elements of cylindrical refractive index matrix for each myelin point (n_diag, A x 3 double, where A is number of myelin points),
    %array containing transform matrix for each myelin point (U_list, A x 3 x 3),
    %cylindrical matrix array for each myelin point (n_cylindrical, A x 3 x 3 double),
    %numeric cartesian matrix array for each myelin point (n_cartesain_num, A x 3 x 3 double),
    %analytic cartesian matrix array for each myelin point (n_cartesain_an, A x 3 x 3 double).


function [n_diag, U_list, n_cylindrical, n_cartesian_num, n_cartesian_an] = applyRadialBirefringence(x, y, myelinPoints, n_e, n_o)

    
    %STORAGE ARRAYS TO STORE DATA FOR EACH MYELIN POINT


    %finds the number of points in the myelin region
    myelinNum = length(myelinPoints(:,1)); 


    %initializes an array so the three elements in the diagonalized (cylindrical) refractive index matrix can be stored for each myelin point
    n_diag = zeros(myelinNum, 3);
    %initializes an array so that the (3x3) transform matrix can be stored for each myelin point
    U_list = zeros(myelinNum,3,3);
    
    %initializes an array so that the (3x3) diagonal/cylindrical matrix can be stored for each myelin point  
    n_cylindrical = zeros(myelinNum, 3, 3);         %note this contains the same information as n_diag
    
    %initializes an array so the numerically-found (3x3) cartesian refractive index matrix can be stored for each myelin point
    n_cartesian_num = zeros(myelinNum, 3, 3);       %numerical (getting cartesian matrix from matrix operations)
    %initializes an array so the analytically-found (3x3) cartesian refractive index matrix can be stored for each myelin point
    n_cartesian_an = zeros(myelinNum, 3, 3);        %analytical (input from my paper calculations directly)
    
    
    
    
    %CONSTRUCTION OF CYLINDRICAL REFRACTIVE INDEX MATRIX
    %NOTE THE REFRACTIVE INDEX MATRIX FOR RADIAL BIREFRINGENCE IS NATURALLY DIAGONALIZED IN CYLINDRICAL COORDINATES
    
    
    %here diagonal (nonzero) elements are defined according to input parameters
    n_rr = n_e;         %radial element (highest value to indicate positive radial birefringence)
    n_phiphi = n_o;     %azimuthal element
    n_zz = n_o;         %z element

    %exaggerated values with biaxial birefringence (all three values are different) 
    %n_rr = 4; 
    %n_phiphi = 3; 
    %n_zz = 2; 
    
    
    
    %TRAVERSES EACH POINT
    %loop proceeds through each myelin grid point to calculate refractive index matrix (of multiple forms) and the coordinate transformation matrix
    for i = 1:myelinNum
        
        

        
        %FINDS PHYSICAL DIMENSIONS OF POINT AND CALCULATES JACOBIAN MATRIX FOR CHANGE OF COORDINATES (CYLINDRICAL TO CARTESIAN)
        
        
        %finds physical distances of x and y for the given point
        physX = x(myelinPoints(i,1)); %finds the physical x distance given the grid point x coordinate
        physY = y(myelinPoints(i,2)); %finds the physical y distance given the grid point y coordinate
        
        %calculates angle from positive x-axis (CCW by convention) using physical x and y distances
        %uses inverse tangent function that returns in the correct quadrant, atan2(y/x)
        phi = atan2(physY, physX); 
        

        %states the Jacobian matrix to be used for the transformation from cylindrical to cartesian coordinates for this point
        jacobian = [ cos(phi), - sin(phi), 0; sin(phi), cos(phi), 0; 0, 0, 1];
        
        
        
        
        %FOR EACH POINT REFRACTIVE INDEX MATRIX DATA WILL BE STORED AS:
            %DIAGONAL ELEMENTS (n_diag),
            %THE DIAGONAL MATRIX IN CYLINDRICAL COORDINATES (n_cylindrical),
            %THE MATRIX IN CARTESIAN COORDINATES FOUND NUMERICALLY (n_cartesian_num), 
            %AND AS THE MATRIX IN CARTESIAN COORDINATES FOUND ANALYTICALLY (n_cartesian_an).
        
        
        %for each point, stores elements for the diagonal (cylindrical) matrix (constant for all points)
        n_diag(i, 1) = n_rr;
        n_diag(i, 2) = n_phiphi;
        n_diag(i, 3) = n_zz;

        %n matrix in cylindrical coordinates
        n_cyl_matrix = [n_rr, 0, 0; 0, n_phiphi, 0; 0, 0, n_zz];
        %save matrix to big list
        n_cylindrical(i, 1:3,1:3) = n_cyl_matrix;
        
        
        %n cartesian matrix (numerically found)
        %to transform a matrix into a different coordinate system the relationship is: new_matrix = (inverse of jacobian) * matrix * jacobian
            %for the case of this Jacobian, the inverse is equal to the transpose
        n_cartesian_num(i, 1:3, 1:3) = jacobian' * n_cyl_matrix * jacobian;

        %alternate way to compute n cartesain matrix numerically
        %this is apparently the more efficient way to apply the inverse operation in MATLAB
        %n_cartesian(i, 1:3, 1:3) = jacobian \ n_diagonal_matrix(i, 1:3, 1:3) * jacobian;
        
        %cartesian matrix (analytically found)
        %this method calculates the cartesian matrix from the form found by hand
        n_cartesian_an(i, 1:3, 1:3) = [n_rr * (cos(phi))^2 + n_phiphi * (sin(phi))^2, (n_phiphi - n_rr) * cos(phi) * sin(phi), 0; (n_phiphi - n_rr) * cos(phi) * sin(phi), n_rr * (sin(phi))^2 + n_phiphi * (cos(phi))^2, 0; 0, 0, n_zz ];
        
        
        

        %FOR EACH POINT, THE TRANSFORM MATRIX WILL BE STORED
        
        
        %stores transform matrix U at this location
        U_list(i,1:3,1:3) = jacobian; 
        
        
        
    end

    %note function returns n_diag, U, n_cylindrical, n_cartesian_num, and n_cartesian_an


end