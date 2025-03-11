N = 100; % Number of sensors
A = 100; % Area dimensions (100m x 100m)
sensor_positions = A * rand(N, 2); 

% Plot the random sensor distribution
figure; 
scatter(sensor_positions(:,1), sensor_positions(:,2), 'filled');
title('Random Distribution of Sensor Nodes');
xlabel('X Position (m)');
ylabel('Y Position (m)');

sink = [50, 50];
distances = sqrt((sensor_positions(:,1) - sink(1)).^2 + (sensor_positions(:,2) - sink(2)).^2);

% Initialize node energies to 2 joules
node_energy = 2 * ones(1, N);

% Initialize arrays to track the energy levels at T1, T2, and T3
T1_energy = []; 
T2_energy = []; 
T3_energy = []; 

% Initialize array to track the cycle when each node dies
death_cycles = -1 * ones(1, N); % -1 means node is still alive

% Network and energy parameters
d0 = sqrt(10/0.0013); 
Eelec = 50e-9; 
Eamp_short = 10e-9; 
Eamp_long = 0.0013e-9; 
data_size = 500 * 8; 

% Initialize simulation variables
dead_nodes = []; 
cycle = 0;

T1 = 0; 
T2 = 0; 
T3 = 0; 

% Simulation loop with while condition
while sum(dead_nodes) < 100
    cycle = cycle + 1;
    fprintf('Cycle %d: Active Nodes = %d\n', cycle, sum(node_energy > 0));
    
    % Expand the dead_nodes array dynamically
    dead_nodes(cycle) = 0; 

    for i = 1:N
        if node_energy(i) > 0 
            if distances(i) <= d0
                Etx = data_size * Eelec + data_size * Eamp_short * distances(i)^2;
            else
                Etx = data_size * Eelec + data_size * Eamp_long * distances(i)^4;
            end

            % Check if the energy required to transmit exceeds the remaining energy
            if Etx > node_energy(i)
                death_cycles(i) = cycle;  
                dead_nodes(cycle) = dead_nodes(cycle) + 1;
                node_energy(i) = 0;  
            else
                node_energy(i) = node_energy(i) - Etx; 
            end
        end
    end

    if T1 == 0 && sum(node_energy <= 0) >= 1
        T1 = cycle;
        T1_energy = node_energy; 
    end
    if T2 == 0 && sum(node_energy <= 0) >= N / 2
        T2 = cycle;
        T2_energy = node_energy; 
    end
    if T3 == 0 && sum(node_energy <= 0) >= N
        T3 = cycle; 
        T3_energy = node_energy; 
    end
end

% Plot active nodes vs cycles
figure;
active_nodes = N - cumsum(dead_nodes); 
plot(1:cycle, active_nodes);
title('Number of Active Nodes vs Number of Cycles');
xlabel('Number of Cycles');
ylabel('Active Nodes');

% Plot remaining energy after T1, T2, and T3
figure;
subplot(3,1,1);
bar(T1_energy);
title(['Remaining Energy After T1 (Cycle ' num2str(T1) ')']);
xlabel('Node Index');
ylabel('Remaining Energy (Joules)');

subplot(3,1,2);
bar(T2_energy);
title(['Remaining Energy After T2 (Cycle ' num2str(T2) ')']);
xlabel('Node Index');
ylabel('Remaining Energy (Joules)');

subplot(3,1,3);
bar(T3_energy);
title(['Remaining Energy After T3 (Cycle ' num2str(T3) ')']);
xlabel('Node Index');
ylabel('Remaining Energy (Joules)');
