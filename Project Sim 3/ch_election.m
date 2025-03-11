function [active_nodes, energies] = ch_election(N, C, E_init, E_agg, E_tx, d0, R)
    % Initialize variables
    nodes_energy = ones(1, N) * E_init;  % All nodes start with 2 joules
    active_nodes = N;  % Start with all nodes as active
    energies = zeros(C, N);  % To store remaining energies after each cycle

    for cycle = 1:C
        chs = randperm(N, floor(0.05 * N));  % Randomly select 5% as CHs
        for node = 1:N
            if nodes_energy(node) > 0
                if is_ch(node, chs)  % Check if the node is a CH
                    nodes_energy(node) = nodes_energy(node) - E_agg;  % Energy for aggregation
                end
                % Check if node can transmit data (energy > 0)
                if nodes_energy(node) > E_tx
                    nodes_energy(node) = nodes_energy(node) - E_tx;  % Transmit data
                else
                    active_nodes = active_nodes - 1;  % Node dies
                end
            end
        end
        energies(cycle, :) = nodes_energy;  % Store energies at each cycle
    end
end
