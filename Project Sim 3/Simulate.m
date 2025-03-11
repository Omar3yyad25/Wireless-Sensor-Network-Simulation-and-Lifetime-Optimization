function [energies,T1,T1_energies,active_nodes,cycle] = Simulate(sink_position,R,x_coords,y_coords,plotting)

    N = 100;
    initial_energy = 2;        % Initial energy (Joules)
    E_elec = 50e-9;            
    epsilon_short = 10e-9;     
    epsilon_long = 0.0013e-9; 
    d0 = sqrt(10/0.0013); 
    packet_size = 500 * 8;      % Packet size in bits
    % Initialize energy levels
    energies = initial_energy * ones(N, 1);
    % Calculate distances to the sink
    distances_to_sink = sqrt((x_coords - sink_position(1)).^2 + (y_coords - sink_position(2)).^2);
    % Simulation loop
    active_nodes = [];
    T1_energies = []; 
    cycle = 1;
    T1 = 0;
    while true
        num_active = sum(energies > 0); % Count active nodes
        active_nodes = [active_nodes; num_active]; % Store active node count
    
        if num_active == 0 % Stop when all nodes are dead
            break;
        end
    
        for i = 1:N
            if energies(i) > 0
                if distances_to_sink(i) <= R
                    % Direct transmission
                    if distances_to_sink(i) <= d0
                        % Short-range transmission
                        energy_consumed = packet_size * E_elec + ...
                            packet_size * epsilon_short * (distances_to_sink(i)^2);
                    else
                        % Long-range transmission
                        energy_consumed = packet_size * E_elec + ...
                            packet_size * epsilon_long * (distances_to_sink(i)^4);
                    end
                else
                    % Dual-hop transmission
                    relay_idx = find_intermediate_node(i, x_coords, y_coords, sink_position, energies, R);
                    if relay_idx > 0 && energies(relay_idx) > 0
                        % Source to relay
                        distance_src_relay = sqrt((x_coords(i) - x_coords(relay_idx))^2 + ...
                                                  (y_coords(i) - y_coords(relay_idx))^2);
                        if distance_src_relay <= d0
                            energy_to_relay = packet_size * E_elec + ...
                                packet_size * epsilon_short * (distance_src_relay^2);
                        else
                            energy_to_relay = packet_size * E_elec + ...
                                packet_size * epsilon_long * (distance_src_relay^4);
                        end
    
                        % Relay to sink
                        distance_relay_sink = sqrt((x_coords(relay_idx) - sink_position(1))^2 + ...
                                                   (y_coords(relay_idx) - sink_position(2))^2);
                        if distance_relay_sink <= d0
                            energy_to_sink = packet_size * E_elec + ...
                                packet_size * epsilon_short * (distance_relay_sink^2);
                        else
                            energy_to_sink = packet_size * E_elec + ...
                                packet_size * epsilon_long * (distance_relay_sink^4);
                        end
    
                        % Deduct energy for relay node
                        energies(relay_idx) = energies(relay_idx) - energy_to_sink;
                        if energies(relay_idx) < 0
                            energies(relay_idx) = 0;
                        end
                    else
                        energy_to_relay = Inf; % Invalid relay node
                    end
                    % Deduct energy for source node
                    energy_consumed = energy_to_relay;
                    if energies(i) < 0
                        energies(i) = 0;
                    end
                end
    
                % Deduct energy for the source node
                energies(i) = energies(i) - energy_consumed;
                if energies(i) < 0
                    energies(i) = 0; % Ensure energy doesn't go negative
                end
            end
        end
    
        % Track T1 (Cycle when the first node dies)
        if T1 == 0 && sum(energies <= 0) >= 1
            T1 = cycle; % Update T1 to the current cycle
            T1_energies = energies; % Save energy levels at T1
        end
    
        cycle = cycle + 1;
    end

if plotting == true 
    % Create dynamic strings for sink, radius, and T1
    sink_str = sprintf('Sink: (%.1f, %.1f)', sink_position(1), sink_position(2));
    R_str = sprintf('Radius: %d m', R);
    T1_str = sprintf('T1: %d Cycles', T1);

    % Plot number of active nodes vs. cycles
    figure;
    plot(1:cycle, active_nodes, 'LineWidth', 2);
    xlabel('Number of Cycles');
    ylabel('Number of Active Nodes');
    title(sprintf('Active Nodes vs. Cycles\n%s, %s, %s', sink_str, R_str, T1_str));
    grid on;

    % Save the plot
    saveas(gcf, sprintf('active_nodes_vs_cycles_sink_(%.1f_%.1f)_R_%d_T1_%d.fig', ...
                        sink_position(1), sink_position(2), R, T1));

    % Display T1 in console
    fprintf('T1 (Cycle where first node dies): %d\n', T1);

    % Plot remaining energies at T1
    figure;
    bar(1:N, T1_energies, 'b');
    xlabel('Node Number');
    ylabel('Remaining Energy (Joules)');
    title(sprintf('Remaining Energies After T1\n%s, %s, %s', sink_str, R_str, T1_str));
    grid on;

    % Save the plot
    saveas(gcf, sprintf('remaining_energies_at_T1_sink_(%.1f_%.1f)_R_%d_T1_%d.fig', ...
                        sink_position(1), sink_position(2), R, T1));
end


end