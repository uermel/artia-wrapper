function outMotl = transformMotl(transforms, inMotl)
% transformMotl successively applies transforms found using the alignVols 
% function to each particle in a motive list. 
%
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
%   UE, 2020

     % File
    inMotl = nameOrFile(inMotl, 'em');
    
    % Apply transforms in order
    for j = 1:numel(transforms)
        
        shift = reshape(transforms{j}.shifts, 1, 3);
        rotation = transforms{j}.angles;
        
        for i = 1:size(inMotl, 2)
            % Rotation matrices
            M_rot_ref = artia.geo.euler2matrix([inMotl(17, i), inMotl(18, i), inMotl(19, i)]);
            M_rot_part = M_rot_ref';
            M_additional = artia.geo.euler2matrix([rotation(1), rotation(2), rotation(3)]);

            % Shift by rotated additional shift
            sr =  M_rot_part * (M_additional' * shift');

            % Combine rotations
            M_combine = M_additional * M_rot_ref;
            ang_final = artia.geo.matrix2euler(M_combine);

            % Store the result
            inMotl(11:13, i) = inMotl(11:13, i) - sr;
            inMotl(17:19, i) = ang_final;
        end
    end
    
    outMotl = inMotl;
end