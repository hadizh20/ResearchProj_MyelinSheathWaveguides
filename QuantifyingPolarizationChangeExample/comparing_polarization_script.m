%Start of code to quantify polarization change between two cross-section monitors (at different z locations along the myelinated axon model with Ranvier nodes at z = 100, 200, 300, 400 microns).
%Emily Frede, March 2023



%loads the 75 micron E field data file (initial state)
load("data_75microns_Efield.mat");

%saves the electric field component matrices from the 75 micron file (so they don't get overwritten when loading the next file)
Ex_at75 = Ex;
Ey_at75 = Ey;
Ez_at75 = Ez;

%loads the 125 micron E field data file (after the first Ranvier node at z = 100)
load("data_125microns_Efield.mat");

%saves the electric field component matrices from the 125 micron file
Ex_at125 = Ex;
Ey_at125 = Ey;
Ez_at125 = Ez;

%note that all electric field components (in files with the ending "_Efield.mat") are defined on the uniform grid x2, y2, z2
%this uniform grid will be the same at all cross-sections (e.g., at 75 microns and also at 125 microns)
%x2 runs from -2 microns to +2 microns, y2 runs from -2 microns to +2 microns, z2 denotes the z location of the monitor (here, either 75 or 125 microns)

%(xmesh, ymesh, zmesh are matrices formed using x2, y2, z2, use these if they are helpful)

%element-wise multiplication 
Ex_product = Ex_at75 .* Ex_at125;
Ey_product = Ey_at75 .* Ey_at125;
Ez_product = Ez_at75 .* Ez_at125;


