function emsartEuler = e2r_RELIONeuler2EMSARTeuler(relionEuler)
%e2r_RELIONeuler2EMSARTeuler(...) converts euler angles from RELION
%convention to EMSART convention. This includes:
%   (1) Conversion from ZYZ (RELION) to ZXZ (EMSART)
%   (2) Conversion from particle-based rotation to reference-based rotation
%       (EMSART). This is an inverse rotation.
%
% USAGE
% emsartEuler = e2r_RELIONeuler2EMSARTeuler(relionEuler)
%
% INPUT ARGUMENTS
%   -relionEuler
%                   Euler angles in RELION convention
%                   == [phi, psi, theta]
%                   == [rlnRot, rlnPsi, rlnTilt]
%                   == [rlnPhi, rlnPsi, rlnTheta]
%
% OUTPUT ARGUMENTS
%   -emsartEuler
%                   Euler angles in EMSART convention
%                   == [phi, psi, theta]
%                   == motl(17:19, x)
%
% Utz Ermel 2019

    %%% Init output
    emsartEuler = zeros(size(relionEuler));

    %%% Loop through angles
    for i = 1:size(relionEuler, 2)
        %%% Get rotation matrix
        R = e2r_RELIONeuler2matrix(relionEuler(:, i));
        
        %%% Convert angles (produces particle rotation)
        particleEuler = e2r_matrix2EMSARTeuler(R);
        
        %%% Invert rotation (produces ref rotation for EmSART)
        emsartEuler(:, i) = [-particleEuler(2), ...
                             -particleEuler(1), ...
                             -particleEuler(3)];
    end
end