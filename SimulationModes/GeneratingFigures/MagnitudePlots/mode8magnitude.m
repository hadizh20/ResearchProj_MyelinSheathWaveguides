load C:/Users/Mike/Documents/EF/598projectfiles/test/birefirngent_myelin_long/guidedmode(s)/500/simsForModes/birefringent_modes_magnitudePlots/mode8magnitude.mat;
x =lum.x;
y =lum.y;
A =lum.z;
colormap jet ;
x2 = linspace(min(x),max(x),293);
y2 = linspace(min(y),max(y),293);
[X,Y] = meshgrid(y,x);
[X2, Y2] = meshgrid(y2,x2);
A2 = interp2(X,Y,A,X2,Y2,'nearest');
A3 = A2.';
imagesc(x2, y2, real(A3));

set(gca, 'FontSize', 15); %added to make tick descriptors on axes and colorbar bigger


set(get(gca, 'XLabel'), 'String', 'x(m)')
set(get(gca, 'XLabel'), 'FontSize', 15) %used to say 16, changing this
set(get(gca, 'XLabel'), 'FontWeight', 'bold')
set(get(gca, 'YLabel'), 'String', 'y(m)')
set(get(gca, 'YLabel'), 'FontSize', 15) %used to be 16
set(get(gca, 'YLabel'), 'FontWeight', 'bold')
set(gca, 'XLim', [-2e-06 2e-06])
set(gca, 'YLim', [-2e-06 2e-06])
set(get(gca, 'Title'), 'String', '') %don't have a title in here, can add one
set(get(gca, 'Title'), 'FontSize', 20) %used to be 18
set(get(gca, 'Title'), 'FontWeight', 'bold')
colorbar;
set(gca, 'YDir','normal');

axis square

exportgraphics(gca, "magnitudeplot_mode_8_B.eps");
