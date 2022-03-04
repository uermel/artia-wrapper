function outMotl = transformMotl(transforms, inMotl)
% transformMotl successively applies transforms found using the alignVols 
% function to each particle in a motive list. 
%
% Parameters:
%   transforms (cell{struct}):
%       Cell array of transform structs. Structs need to contain fields 
%       'angles' and 'shifts', containing the rotation in euler angles 
%       (Phi, Psi, Theta) and shifts (x, y, z in pixels).
%   inMotl (double[20xN]):
%       Input motive list.
%
% Returns:
%   outMotl (double[20xN]): 
%       Output motive list.
%
% Author:
%   UE, 2022

 	% File
    inMotl = nameOrFile(inMotl, 'em');
    
    % Apply transforms in order
    for j = 1:numel(transforms)
        
        shift = reshape(transforms{j}.shifts, 1, 3);
        rotation = transforms{j}.angles;
        
        % Shift reference frame
        M_shift2 = [1 0 0 shift(1);
                    0 1 0 shift(2);
                    0 0 1 shift(3);
                    0 0 0        1];
        
        % Rotation reference frame
        [~, M_rot2] = eul2mat(rotation);
        
        for i = 1:size(inMotl, 2)
            
            % Shift particle frame -> reference frame (note negative sign)
            M_shift1 = [1 0 0 -inMotl(11, i);
                        0 1 0 -inMotl(12, i);
                        0 0 1 -inMotl(13, i);
                        0 0 0             1];
                    
            % Rotation particle frame -> reference frame (note
            % transposition)        
            [~, M_rot1] = eul2mat(inMotl(17:19, i));
            M_rot1 = M_rot1';
            
            % Combine transformations
            M_total = M_shift2 * M_rot2 * M_rot1 * M_shift1;
            
            % Total transformation is now from particle frame to new reference
            % frame. We need to store the inverse.
            % Invert
            M_new = inv(M_total);
            
            [phi, psi, the] = mat2eul(M_new);

            % Store the result
            inMotl(11:13, i) = [M_new(1, 4), M_new(2, 4), M_new(3, 4)];
            inMotl(17:19, i) = [phi, psi, the];
        end
    end
    
    outMotl = inMotl;
end
