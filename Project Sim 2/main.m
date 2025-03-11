clc;
clear all;
% Part A: Generate a WSN with 100 nodes in a 100m x 100m area
N = 100;               
area_size = 100;     
sink_position = [50, 50]; % Sink node
x_coords = area_size * rand(N, 1);
y_coords = area_size * rand(N, 1);
% network topology
figure;
scatter(x_coords, y_coords, 50, 'b', 'filled'); % Sensor nodes as blue circles
hold on;
scatter(sink_position(1), sink_position(2), 100, 'r', 'filled'); % Sink as a red circle
title('Wireless Sensor Network Topology');
xlabel('X (meters)');
ylabel('Y (meters)');
xlim([0 area_size]);
ylim([0 area_size]);
grid on;
legend('Sensor Nodes', 'Sink Node', 'Location', 'best');
hold off;

% Part B , C: Dual-Hop Transmission Simulation
R = 30; % Radius for direct transmission (meters)
[energies,T1,T1_energies,active_nodes,cycle] = Simulate(sink_position,R,x_coords,y_coords,true);






%part D :
%if center is at center [50 ,50] then maxR=70
R_values = 10:10:70; % Range of R values to test
T1_values = zeros(size(R_values)); 
optimal_energies = [];
for r_idx = 1:length(R_values)
    R = R_values(r_idx); 
    [energies, T1, T1_energies, ~, ~] = Simulate(sink_position, R, x_coords, y_coords, false);
    T1_values(r_idx) = T1;
    if T1 == max(T1_values)
        optimal_energies = T1_energies;
    end
end

[max_T1, opt_idx] = max(T1_values);
opt_R = R_values(opt_idx);
fprintf('Maximum T1: %d cycles at R = %d meters\n', max_T1, opt_R);

% Plot T1 vs R
figure;
plot(R_values, T1_values, '-o', 'LineWidth', 2);
xlabel('Transmission Radius R (meters)');
ylabel('T1 (Cycles)');
title('T1 vs. Transmission Radius R');
grid on;
saveas(gcf, 'T1_vs_R.fig');

% Plot Remaining Energies for Optimal R
figure;
bar(optimal_energies, 'b');
xlabel('Node Index');
ylabel('Remaining Energy (Joules)');
title(sprintf('Remaining Energies After T1 (Optimal R = %d, T1 = %d)', opt_R, max_T1));
grid on;
saveas(gcf, sprintf('Remaining_Energies_Optimal_R_%d_sink_(%d_%d).fig', opt_R, sink_position(1), sink_position(2)));

%part E :  
R=30
new_sink_position = [50, 225];
[energies,T1,T1_energies,active_nodes,cycle] = Simulate(new_sink_position,R,x_coords,y_coords,true);

distances_to_sink = sqrt((x_coords - new_sink_position(1)).^2 + (y_coords - new_sink_position(2)).^2);
maxR = ceil(max(distances_to_sink));

% Define R values
R_values = 10:10:maxR;

optimal_energies=[];
T1_values = zeros(size(R_values));
total_T1_energies = zeros(size(R_values)); 
% Loop over R values
fprintf('Simulating for sink at (%d, %d)...\n', new_sink_position(1), new_sink_position(2));
for r_idx = 1:length(R_values)
    R = R_values(r_idx);
    [energies, T1, T1_energies, active_nodes, cycle] = Simulate(new_sink_position, R, x_coords, y_coords, false);
    T1_values(r_idx) = T1;
    total_T1_energies(r_idx) = sum(T1_energies);
    if total_T1_energies(r_idx) == max(total_T1_energies)
        optimal_energies = T1_energies;
    end
end
% Find the optimal R
[max_total_energy, opt_idx] = max(total_T1_energies);
opt_R = R_values(opt_idx);
max_T1 =  T1_values(opt_idx)
% Display results
fprintf('Maximum T1: %d cycles at R = %d meters\n', max_T1, opt_R);
fprintf('For sink at (%d, %d), maxR = %d meters\n', new_sink_position(1), new_sink_position(2), maxR);

% Plot T1 vs R
figure;
plot(R_values, T1_values, '-o', 'LineWidth', 2);
xlabel('Transmission Radius R (meters)');
ylabel('T1 (Cycles)');
title(sprintf('T1 vs. Transmission Radius R (Sink at [%d, %d])', new_sink_position(1), new_sink_position(2)));
grid on;
% Save the plot
saveas(gcf, sprintf('T1_vs_R_sink_(%d_%d).fig', new_sink_position(1), new_sink_position(2)));

% Plot Remaining Energies for Optimal R
figure;
bar(optimal_energies, 'b');
xlabel('Node Index');
ylabel('Remaining Energy (Joules)');
title(sprintf('Remaining Energies After T1 (Optimal R = %d, T1 = %d)', opt_R, max_T1));
grid on;
saveas(gcf, sprintf('Remaining_Energies_Optimal_R_%d_sink_(%d_%d).fig', opt_R, new_sink_position(1), new_sink_position(2)));



% % part F:
% replace find_intermediate_node() with new_find_intermediate_node()
% in the Simulate function