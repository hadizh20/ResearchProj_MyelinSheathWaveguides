
clc
clear 
clear all 

T_list_nonbirefringent = zeros(20,1);

index = 1;

for i = 25:25:500
    position = i;

    load(i + "\data_" + i + "microns_mainSets.mat");
    T = T.T;
    T_list_nonbirefringent(index) = T;
    index = index + 1;

end


per_node_T_drop = T_list_nonbirefringent(5);

T_list_theo = zeros(size(T_list_nonbirefringent));

for a = 1:4
    T_list_theo(a) = 1;
end
for b = 5:8
    T_list_theo(b) = per_node_T_drop;
end
for c = 9:12
    T_list_theo(c) = per_node_T_drop^2;
end
for d = 13:16
    T_list_theo(d) = per_node_T_drop^3;
end
for e = 17:20
    T_list_theo(e) = per_node_T_drop^4;
end
    

f = figure(1);

plot(linspace(25,500,20), log(T_list_theo), "Marker", "x", "LineWidth", 3, "Color", "green");
hold on;
plot(linspace(25, 500, 20), log(T_list_nonbirefringent), "Marker", "x", "LineWidth", 3, "Color", "blue");

legend('Exponentiated loss','Simulation data');

f.Position = [100, 100, 1500, 1000];

set(gca, 'FontSize', 26); %added to make tick descriptors on axes and colorbar bigger

set(get(gca, 'XLabel'), 'String', 'z (µm)')
set(get(gca, 'XLabel'), 'FontSize', 32) %used to say 16, changing this
set(get(gca, 'XLabel'), 'FontWeight', 'bold')
set(get(gca, 'YLabel'), 'String', 'ln(T)')
set(get(gca, 'YLabel'), 'FontSize', 32) %used to be 16
set(get(gca, 'YLabel'), 'FontWeight', 'bold')

%set(get(gca, 'Title'), 'String', 'Transmission as a function of position, log plot.') 
set(get(gca, 'Title'), 'FontSize', 28) %used to be 18
%set(get(gca, 'Title'), 'FontWeight', 'bold')

exportgraphics(f, "transmission_plot_LOGPLOT_W_Theoretical_noBiref.eps");



