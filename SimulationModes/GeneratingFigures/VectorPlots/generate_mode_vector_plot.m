
clear
close all

index = 1; %changed to be every integer 1 - 12 and run to generate each mode's vector plot 


load("mode" + index + "\data_sourceM"+ index + "(nonbirefringent)_Efield.mat");


realEx = real(Ex.'); 
realEy = real(Ey.');
realEz = real(Ez.');


xmesh = xmesh';
ymesh = ymesh';
zmesh = zmesh';


%this creates an intensity plot that matches the magnitude plot perfectly
% figure("Name", "Intensity plot.");
% colormap jet ;
% imagesc(x2,y2, sqrt(realEx.^2 + realEy.^2 + realEz.^2) );
% colorbar



zCoord = zmesh(1,1);

%quiver3(xmesh, ymesh, zmesh, realEx, realEy, realEz);

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
Ex_normalized = Ex_lowres./magnitude_matrix;
Ey_normalized = Ey_lowres./magnitude_matrix;
Ez_normalized = Ez_lowres./magnitude_matrix;

magnitude_matrix_highres = sqrt(realEx.^2 + realEy.^2 + realEz.^2);

Ez_normalized_highres = realEz ./ magnitude_matrix_highres;





fig3 = figure("Name", "Combination vector plot");
quiver(xmesh_lowres, ymesh_lowres, Ex_normalized, Ey_normalized, 0.6, "Color", "black");
alpha(0.5);
hold on;
quiver(xmesh_lowres, ymesh_lowres, Ex_lowres, Ey_lowres, 1.0, "Color", "red");

ax = gca;
ax.FontSize = 15;

xlim([-2e-06 2e-06]);
ylim([-2e-06 2e-06]);
xlabel("x(m)", "FontSize", 15, "FontWeight", "bold");
ylabel("y(m)", "FontSize", 15, "FontWeight", "bold");

%colorbar

axis square


exportgraphics(fig3, "vectorplot_combinationM" + index + "_NB_standard.eps");







