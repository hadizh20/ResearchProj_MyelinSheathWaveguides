
clear
close all

%Changed to generate figures for each of the monitors.
index = 1;
pos = index * 25; %microns

load(pos + "\data_" + pos + "microns_Efield.mat");


realEx = real(Ex.'); 
realEy = real(Ey.');
realEz = real(Ez.');


xmesh = xmesh';
ymesh = ymesh';
zmesh = zmesh';



zCoord = zmesh(1,1);


res_x = 15;
res_y = 15;

x_lowres = linspace(x2(1), x2(length(x2)), res_x);
y_lowres = linspace(y2(1), y2(length(y2)), res_y);

[xmesh_lowres, ymesh_lowres] = meshgrid(x_lowres, y_lowres);
zmesh_lowres = ones(res_x,res_y,1)*zCoord;







Ex_lowres = interp2(xmesh, ymesh, realEx, xmesh_lowres, ymesh_lowres);

Ey_lowres = interp2(xmesh, ymesh, realEy, xmesh_lowres, ymesh_lowres);

Ez_lowres = interp2(xmesh, ymesh, realEz, xmesh_lowres, ymesh_lowres);


%used to normalize the data (make all arrows the same size)
magnitude_matrix = sqrt(Ex_lowres.^2 + Ey_lowres.^2 + Ez_lowres.^2);
magnitude_matrix_flat = sqrt(Ex_lowres.^2 + Ey_lowres.^2);
Ex_normalized = Ex_lowres./magnitude_matrix;
Ex_normalized_flat = Ex_lowres./magnitude_matrix_flat;
Ey_normalized = Ey_lowres./magnitude_matrix;
Ey_normalized_flat = Ey_lowres./magnitude_matrix_flat;
Ez_normalized = Ez_lowres./magnitude_matrix;

magnitude_matrix_highres = sqrt(realEx.^2 + realEy.^2 + realEz.^2);

Ez_normalized_highres = realEz ./ magnitude_matrix_highres;







fig0 = figure("Name", "Magnitude plot");
colormap jet ;
imagesc(x2,y2, flipud(sqrt(realEx.^2 + realEy.^2 + realEz.^2)) ); 

ax = gca;
ax.FontSize = 15;

xlim([-2e-06 2e-06]);
ylim([-2e-06 2e-06]);
xlabel("x(m)", "FontSize", 15, "FontWeight", "bold");
ylabel("y(m)", "FontSize", 15, "FontWeight", "bold");

h = colorbar;
h.Limits = [0, 100];


axis square

exportgraphics(fig0, "magnitudePlot_" + pos + "microns_B_standardized.eps");





fig3 = figure("Name", "Combination vector plot");
[M,c] = contour(xmesh, ymesh, realEz, FaceAlpha = 1.0);
c.LineWidth = 0.001;
%c.LineColor = "blue";
hold on;
quiver(xmesh_lowres, ymesh_lowres, Ex_normalized, Ey_normalized, 0.6, "Color", "black");
alpha(0.5);
hold on;
quiver(xmesh_lowres, ymesh_lowres, Ex_lowres, Ey_lowres, 1.0, "Color", "red");
caxis([-15, 15]);

ax = gca;
ax.FontSize = 15;

xlim([-2e-06 2e-06]);
ylim([-2e-06 2e-06]);
xlabel("x(m)", "FontSize", 15, "FontWeight", "bold");
ylabel("y(m)", "FontSize", 15, "FontWeight", "bold");

h2 = colorbar;
h2.Limits = [-15, 15];

axis square


exportgraphics(fig3, "vectorplot_combinationB" + pos + "_standard.eps");
