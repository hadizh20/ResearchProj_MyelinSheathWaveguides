To generate a matrix transform file (and custom refractive index data file) for input into the software, run the script "generate_custom_transform.m"
The rest of the MATLAB code included here are functions that this script uses.

In the main script "generate_custom_transform.m" one may alter the parameters of axon radius, outer myelin radius, refractive indices of materials, and resolution (higher resolution is more accurate but will make Lumerical simulations much longer). Parameters are currently set for the model described in the paper.

When you run this script as is, you will get the refractive index data file "nData_myelinRad1_res801.txt" and the matrix transform data file "UData_myelinRad1_res801.mat". 

When you run "generate_custom_transform.m" you will get the file "nData_myelinRad1_res801.txt", I cannot upload it here because it is too big. Note that while the refractive index data file is correct up to the given resolution, it is more accurate to directly specify refractive indices of each material (axon, myelin, fluid) in cylindrical coordinates for each material in the Lumerical software. Therefore this refractive index data file was not used (except in preliminary Lumerical simulations I didn't save and are not included in this GitHub folder).

The matrix transform data file "UData_myelinRad1_res801.mat" is also output from this main script, since it is smaller I have uploaded it here. It was used to ensure that while the coordinate system outside the myelin cross-section is Cartesian (i.e., in the axon and the interstitial fluid), the coordinate system within the myelin is cylindrical. Since you can input a diagonal refractive index matrix directly for a material in the software (which is the most accurate), n_xx under the matrix transform will map to n_rr, and similarly n_yy maps to n_phiphi and trivially n_zz maps to n_zz.  

