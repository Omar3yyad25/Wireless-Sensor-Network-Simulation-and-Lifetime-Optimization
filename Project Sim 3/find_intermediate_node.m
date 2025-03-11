function relay_idx = find_intermediate_node(source_idx, x_coords, y_coords, sink_position, energies ,R)

    N = length(x_coords); % Number of nodes
    min_distance_to_sink = inf; 
    relay_idx = -1; % Default: no valid relay node
    
    % Coordinates of the source node
    source_x = x_coords(source_idx);
    source_y = y_coords(source_idx);
    
    % Loop through all potential relay nodes
    for i = 1:N
        if i ~= source_idx && energies(i) > 0 % Node is not the source and is active
            distance_to_source = sqrt((x_coords(i) - source_x)^2 + (y_coords(i) - source_y)^2);
            if distance_to_source <= R
                distance_to_sink = sqrt((x_coords(i) - sink_position(1))^2 + (y_coords(i) - sink_position(2))^2);
                
                if distance_to_sink < min_distance_to_sink
                    min_distance_to_sink = distance_to_sink;
                    relay_idx = i; 
                end
            end
        end
    end
end
