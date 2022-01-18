function newref = symmetrize_oh(part)
    newref = zeros(size(part));
    for i = 0:2
        % First rotation is about axis [.5773502 .5773502 .5773502]
        % This is the diagonal from the center of the cube to the corner [1, 1, 1].
        % Assumption is that we deal with a cube in which the edges are
        % parallel to the axes and the z-axis runs through one face of the
        % cube. 
        %
        % To bring [.5773502 .5773502 .5773502] axis on z-axis:
        angles_axis1 = [-135 0 -54.7356];
        M1 = euler2matrix(angles_axis1);

        % Three-fold rotation about z-axis
        angles_three = [120*i 0 0];
        M2 = euler2matrix(angles_three);

        for j = 0:3
            % Bring four fold symmetry axis to z
            angles_next = [0 45 54.7356];
            M3 = euler2matrix(angles_next);

            % Four-fold rotation about z-axis
            angles_four = [90*j 0 0];
            M4 = euler2matrix(angles_four);

            for k = 0:1
                % Last rotation is about axis [1 0 0] (== mirror plane [0 1 1])
                % To bring that axis on z:
                angles_axis2 = [0 90 -90];
                M5 = euler2matrix(angles_axis2);

                % Two-fold rotation about z-axis
                angles_two = [k*180 0 0];
                M6 = euler2matrix(angles_two);

                % Now combine all the individual rotations
                ang = matrix2euler(M1 * M2 * M3 * M4 * M5 * M6);

                % Add the rotated volume
                part_x = rot(part, ang);
                newref = newref + part_x;
            end
        end
    end
end