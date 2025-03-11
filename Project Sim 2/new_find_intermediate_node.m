function relay_idx = new_find_intermediate_node(source_idx, x_coords, y_coords, sink_position, energies, R)
    % Number of nodes
    N = length(x_coords);
    best_cost = inf; 
    relay_idx = -1;  % Default: no valid relay node
    
    % Coordinates of the source node
    source_x = x_coords(source_idx);
    source_y = y_coords(source_idx);
    
    for i = 1:N
        if i ~= source_idx && energies(i) > 0 % Node is not the source and is active
            % Distance between the source node and the current node
            distance_to_source = sqrt((x_coords(i) - source_x)^2 + (y_coords(i) - source_y)^2);
            
            % Check if the node is within transmission radius
            if distance_to_source <= R
                % Distance from the current node to the sink
                distance_to_sink = sqrt((x_coords(i) - sink_position(1))^2 + (y_coords(i) - sink_position(2))^2);
                
                % Compute cost: prioritize nodes with higher energy and closer to the sink
                cost = distance_to_sink / energies(i); 
                
                % Update the best node if the cost is lower
                if cost < best_cost
                    best_cost = cost;
                    relay_idx = i;
                end
            end
        end
    end
end